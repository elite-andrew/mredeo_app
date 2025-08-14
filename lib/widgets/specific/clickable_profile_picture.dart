import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:redeo_app/core/theme/app_colors.dart';
import 'package:redeo_app/providers/profile_provider.dart';
import 'package:redeo_app/data/models/user_model.dart';
import 'package:redeo_app/core/utils/app_logger.dart';

class ClickableProfilePicture extends StatefulWidget {
  final User? user;
  final double radius;
  final bool enableEdit;
  final VoidCallback? onImageChanged;

  const ClickableProfilePicture({
    super.key,
    required this.user,
    this.radius = 50,
    this.enableEdit = true,
    this.onImageChanged,
  });

  @override
  State<ClickableProfilePicture> createState() =>
      _ClickableProfilePictureState();
}

class _ClickableProfilePictureState extends State<ClickableProfilePicture> {
  bool _isUpdating = false;

  Future<void> _pickAndUploadImage() async {
    if (!widget.enableEdit) return;

    try {
      final ImagePicker picker = ImagePicker();

      // Show bottom sheet for image source selection
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder:
            (context) => Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Update Profile Picture',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildImageSourceOption(
                          icon: Icons.photo_library,
                          label: 'Gallery',
                          onTap:
                              () => Navigator.pop(context, ImageSource.gallery),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildImageSourceOption(
                          icon: Icons.camera_alt,
                          label: 'Camera',
                          onTap:
                              () => Navigator.pop(context, ImageSource.camera),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
      );

      if (source != null) {
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80,
        );

        if (image != null && mounted) {
          setState(() => _isUpdating = true);

          final profileProvider = Provider.of<ProfileProvider>(
            context,
            listen: false,
          );
          final result = await profileProvider.uploadProfilePicture(image.path);

          if (mounted) {
            setState(() => _isUpdating = false);

            if (result['success']) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message']),
                  backgroundColor: AppColors.success,
                ),
              );
              widget.onImageChanged?.call();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message']),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      AppLogger.error(
        'Error updating profile picture',
        'ClickableProfilePicture',
        e,
      );
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile picture: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use the full URL from the User model
    String? profilePictureUrl = widget.user?.profilePictureUrl;
    if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
      final separator = profilePictureUrl.contains('?') ? '&' : '?';
      profilePictureUrl =
          '$profilePictureUrl${separator}t=${DateTime.now().millisecondsSinceEpoch}';
    }

    return GestureDetector(
      onTap: widget.enableEdit ? _pickAndUploadImage : null,
      child: Stack(
        children: [
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: AppColors.primary,
            backgroundImage:
                profilePictureUrl != null
                    ? NetworkImage(profilePictureUrl)
                    : null,
            child:
                widget.user?.profilePictureUrl == null
                    ? Text(
                      widget.user?.initials ?? '?',
                      style: TextStyle(
                        fontSize: widget.radius * 0.48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                    : null,
          ),
          if (widget.enableEdit)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: widget.radius * 0.72,
                height: widget.radius * 0.72,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: widget.radius * 0.36,
                ),
              ),
            ),
          if (_isUpdating)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(128),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
