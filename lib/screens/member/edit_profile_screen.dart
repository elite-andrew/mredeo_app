import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mredeo_app/widgets/common/custom_app_bar.dart';
import 'package:mredeo_app/widgets/common/app_button.dart';
import 'package:mredeo_app/widgets/common/validated_text_field.dart';
import 'package:mredeo_app/core/theme/app_colors.dart';
import 'package:mredeo_app/providers/profile_provider.dart';
import 'package:mredeo_app/providers/auth_provider.dart';
import 'package:mredeo_app/data/models/user_model.dart';
import 'package:mredeo_app/core/utils/app_logger.dart';
import 'package:mredeo_app/core/utils/image_cache_manager.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _selectedImage;
  bool _isUpdatingPicture = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    try {
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Set up connection between providers for cross-updates
      profileProvider.setAuthProvider(authProvider);

      final user = profileProvider.user;

      if (user != null) {
        _fullNameController.text = user.fullName;
        _emailController.text = user.email ?? '';
        _phoneController.text = user.phoneNumber;
      }

      // Only listen for changes on the phone controller since others are read-only
      _phoneController.addListener(_onFieldChange);
    } catch (e) {
      // Handle provider access errors gracefully
      debugPrint('Error initializing form: $e');
    }
  }

  void _onFieldChange() {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final user = profileProvider.user;

    if (user != null) {
      // Only check phone number changes since full name and email are read-only
      final hasTextChanges = _phoneController.text != user.phoneNumber;

      AppLogger.debug(
        'Field changed - hasTextChanges: $hasTextChanges, _hasChanges: $_hasChanges',
        'EditProfileScreen',
      );
      AppLogger.debug(
        'phone: "${_phoneController.text}" vs "${user.phoneNumber}"',
        'EditProfileScreen',
      );

      if (hasTextChanges != _hasChanges) {
        setState(() {
          _hasChanges = hasTextChanges || _selectedImage != null;
        });
        AppLogger.debug(
          'Updated _hasChanges to: $_hasChanges',
          'EditProfileScreen',
        );
      }
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onFieldChange);
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
                    'Choose Image Source',
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

        if (image != null) {
          setState(() {
            _selectedImage = File(image.path);
            _hasChanges = true;
          });
        }
      }
    } catch (e) {
      AppLogger.error('Error picking image', 'EditProfileScreen', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
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

  Future<void> _saveChanges() async {
    AppLogger.debug('_saveChanges called!', 'EditProfileScreen');
    if (!_formKey.currentState!.validate()) {
      AppLogger.warning('Form validation failed', 'EditProfileScreen');
      return;
    }

    AppLogger.debug(
      'Form validation passed, proceeding with save',
      'EditProfileScreen',
    );
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    try {
      // Upload profile picture first if selected
      if (_selectedImage != null) {
        setState(() => _isUpdatingPicture = true);

        final result = await profileProvider.uploadProfilePicture(
          _selectedImage!.path,
        );

        setState(() => _isUpdatingPicture = false);

        if (!result['success']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message']),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
      }

      // Update profile information (only phone number is editable)
      final result = await profileProvider.updateProfile(
        phoneNumber: _phoneController.text.trim(),
      );

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Profile updated successfully',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop(); // Go back to profile screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to update profile'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error saving profile changes', 'EditProfileScreen', e);
      if (mounted) {
        setState(() => _isUpdatingPicture = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving changes: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildProfilePictureSection(User? user) {
    // Use the full URL from the User model
    String? profilePictureUrl = user?.profilePictureUrl;
    if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
      final separator = profilePictureUrl.contains('?') ? '&' : '?';
      profilePictureUrl =
          '$profilePictureUrl${separator}t=${DateTime.now().millisecondsSinceEpoch}';
    }

    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 57,
                backgroundColor: AppColors.primary,
                child:
                    _selectedImage != null
                        ? ClipOval(
                          child: Image.file(
                            _selectedImage!,
                            width: 114,
                            height: 114,
                            fit: BoxFit.cover,
                          ),
                        )
                        : (profilePictureUrl != null
                            ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: profilePictureUrl,
                                width: 114,
                                height: 114,
                                fit: BoxFit.cover,
                                cacheManager: ImageCacheManager.instance,
                                placeholder:
                                    (context, url) => Container(
                                      width: 114,
                                      height: 114,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primary,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                errorWidget: (context, url, error) {
                                  AppLogger.warning(
                                    'Failed to load profile picture in edit screen: $url, Error: $error',
                                    'EditProfileScreen',
                                  );
                                  return Container(
                                    width: 114,
                                    height: 114,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        user?.initials ?? '?',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                fadeInDuration: const Duration(
                                  milliseconds: 300,
                                ),
                                fadeOutDuration: const Duration(
                                  milliseconds: 100,
                                ),
                              ),
                            )
                            : Text(
                              user?.initials ?? '?',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
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
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          if (_isUpdatingPicture)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomAppBar(title: 'Edit Profile'),
          Expanded(
            child: Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                final user = profileProvider.user;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Profile Picture Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(26),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildProfilePictureSection(user),
                              const SizedBox(height: 16),
                              Text(
                                'Tap to change profile picture',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Form Fields
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(26),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Editable Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You can edit your phone number and profile picture',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 20),

                              ValidatedTextField(
                                controller: _fullNameController,
                                label: 'Full Name',
                                hintText: 'Your full name',
                                prefixIcon: Icons.person,
                                readOnly: true,
                                validator: (value) {
                                  // Read-only field doesn't need validation
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              ValidatedTextField(
                                controller: _phoneController,
                                label: 'Phone Number',
                                hintText: 'Enter your phone number',
                                prefixIcon: Icons.phone,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  if (!RegExp(
                                    r'^\+?[0-9]{10,15}$',
                                  ).hasMatch(value.trim())) {
                                    return 'Please enter a valid phone number';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              ValidatedTextField(
                                controller: _emailController,
                                label: 'Email',
                                hintText: 'Your email address',
                                prefixIcon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
                                readOnly: true,
                                validator: (value) {
                                  // Read-only field doesn't need validation
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Save Button
                        Consumer<ProfileProvider>(
                          builder: (context, profileProvider, child) {
                            AppLogger.debug(
                              'Building save button - _hasChanges: $_hasChanges, isLoading: ${profileProvider.isLoading}',
                              'EditProfileScreen',
                            );
                            return AppButton(
                              text: 'Save Changes',
                              onPressed:
                                  _hasChanges
                                      ? () {
                                        AppLogger.debug(
                                          'Save button pressed!',
                                          'EditProfileScreen',
                                        );
                                        _saveChanges();
                                      }
                                      : null,
                              isLoading:
                                  profileProvider.isLoading ||
                                  _isUpdatingPicture,
                            );
                          },
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
