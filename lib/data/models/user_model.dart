class User {
  final String id;
  final String fullName;
  final String username;
  final String? email;
  final String phoneNumber;
  final String? profilePicture;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.fullName,
    required this.username,
    this.email,
    required this.phoneNumber,
    this.profilePicture,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      phoneNumber: json['phone_number'] ?? '',
      profilePicture: json['profile_picture'],
      role: json['role'] ?? 'member',
      isActive: json['is_active'] ?? false,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? fullName,
    String? username,
    String? email,
    String? phoneNumber,
    String? profilePicture,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAdmin => role.contains('admin');
  bool get isMember => role == 'member';

  String get initials {
    final names = fullName.split(' ').where((n) => n.isNotEmpty).toList();
    if (names.length >= 2 && names[0].isNotEmpty && names[1].isNotEmpty) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty && names[0].isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }
}

class UserSettings {
  final String id;
  final String userId;
  final String language;
  final bool darkMode;
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool consentToTerms;
  final String timezone;
  final String currency;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserSettings({
    required this.id,
    required this.userId,
    this.language = 'en',
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.smsNotifications = true,
    this.consentToTerms = false,
    this.timezone = 'UTC',
    this.currency = 'USD',
    this.createdAt,
    this.updatedAt,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      language: json['language'] ?? 'en',
      darkMode: json['dark_mode'] ?? false,
      notificationsEnabled: json['notifications_enabled'] ?? true,
      emailNotifications: json['email_notifications'] ?? true,
      smsNotifications: json['sms_notifications'] ?? true,
      consentToTerms: json['consent_to_terms'] ?? false,
      timezone: json['timezone'] ?? 'UTC',
      currency: json['currency'] ?? 'USD',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'language': language,
      'dark_mode': darkMode,
      'notifications_enabled': notificationsEnabled,
      'email_notifications': emailNotifications,
      'sms_notifications': smsNotifications,
      'consent_to_terms': consentToTerms,
      'timezone': timezone,
      'currency': currency,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserSettings copyWith({
    String? id,
    String? userId,
    String? language,
    bool? darkMode,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? consentToTerms,
    String? timezone,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      consentToTerms: consentToTerms ?? this.consentToTerms,
      timezone: timezone ?? this.timezone,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserSettings(id: $id, userId: $userId, language: $language, darkMode: $darkMode, notificationsEnabled: $notificationsEnabled)';
  }
}
