import 'package:flutter/material.dart';
import 'package:mredeo_app/data/services/notification_service.dart';
import 'package:mredeo_app/data/models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = false;
  String? _errorMessage;
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  // Load notifications
  Future<void> loadNotifications({int page = 1}) async {
    _setLoading(true);
    _clearError();

    final result = await _notificationService.getNotifications(page: page);

    if (result['success']) {
      final notificationList =
          (result['data']['data']['notifications'] as List)
              .map((json) => AppNotification.fromJson(json))
              .toList();

      if (page == 1) {
        _notifications = notificationList;
      } else {
        _notifications.addAll(notificationList);
      }

      _updateUnreadCount();
    } else {
      // Don't show error for empty data - just set empty list
      if (result['message']?.toString().toLowerCase().contains('no') == true ||
          result['message']?.toString().toLowerCase().contains('empty') ==
              true) {
        _notifications = [];
        _unreadCount = 0;
      } else {
        _setError(result['message']);
      }
    }

    _setLoading(false);
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    final result = await _notificationService.markAsRead(notificationId);

    if (result['success']) {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
        _updateUnreadCount();
        notifyListeners();
      }
      return true;
    } else {
      _setError(result['message']);
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    final result = await _notificationService.markAllAsRead();

    if (result['success']) {
      _notifications =
          _notifications
              .map(
                (notification) =>
                    notification.copyWith(isRead: true, readAt: DateTime.now()),
              )
              .toList();
      _unreadCount = 0;
      notifyListeners();
      return true;
    } else {
      _setError(result['message']);
      return false;
    }
  }

  // Load unread count
  Future<void> loadUnreadCount() async {
    final result = await _notificationService.getUnreadCount();

    if (result['success'] && result['data'] != null) {
      _unreadCount = result['data']['count'] ?? 0;
      notifyListeners();
    }
  }

  // Get unread notifications
  List<AppNotification> get unreadNotifications {
    return _notifications
        .where((notification) => !notification.isRead)
        .toList();
  }

  // Get read notifications
  List<AppNotification> get readNotifications {
    return _notifications.where((notification) => notification.isRead).toList();
  }

  // Add new notification (for real-time updates)
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _unreadCount++;
    }
    notifyListeners();
  }

  // Update unread count from current notifications
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Clear all notifications (for logout)
  void clearNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    _clearError();
    notifyListeners();
  }
}
