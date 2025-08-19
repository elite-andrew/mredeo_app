import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Modern Header Section
          _buildModernHeader(context),
          Expanded(
            child: Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                if (profileProvider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Updating profile...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final user = profileProvider.user;
                if (user == null) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow.withAlpha(13),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.error.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Unable to load profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please try again',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Profile Picture Section
                        _buildModernProfilePictureSection(user),
                        const SizedBox(height: 32),

                        // Profile Information Card
                        _buildModernProfileInfoCard(user),
                        const SizedBox(height: 24),

                        // Action Buttons
                        if (_hasChanges || _selectedImage != null)
                          _buildModernActionButtons(profileProvider),
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

  Widget _buildModernHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        30,
      ),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Update your information',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildModernProfilePictureSection(User? user) {
    // Use the full URL from the User model
    String? profilePictureUrl = user?.profilePictureUrl;
    if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
      final separator = profilePictureUrl.contains('?') ? '&' : '?';
      profilePictureUrl =
          '$profilePictureUrl${separator}t=${DateTime.now().millisecondsSinceEpoch}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withAlpha(51),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 58,
                      backgroundColor: AppColors.primary.withAlpha(30),
                      child:
                          _selectedImage != null
                              ? ClipOval(
                                child: Image.file(
                                  _selectedImage!,
                                  width: 116,
                                  height: 116,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : (profilePictureUrl != null
                                  ? ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: profilePictureUrl,
                                      width: 116,
                                      height: 116,
                                      fit: BoxFit.cover,
                                      cacheManager: ImageCacheManager.instance,
                                      placeholder:
                                          (context, url) => Container(
                                            width: 116,
                                            height: 116,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withAlpha(20),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.camera_alt,
                                              size: 40,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                      errorWidget:
                                          (context, url, error) => Container(
                                            width: 116,
                                            height: 116,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withAlpha(20),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.camera_alt,
                                              size: 40,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                    ),
                                  )
                                  : Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: AppColors.primary,
                                  )),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child:
                        _isUpdatingPicture
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withAlpha(30)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Tap to change profile picture',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernProfileInfoCard(User? user) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(10),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.edit, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Profile Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildModernInfoField(
                  'Full Name',
                  _fullNameController,
                  Icons.person,
                  enabled: false,
                  validator: null,
                ),
                const SizedBox(height: 16),
                _buildModernInfoField(
                  'Phone Number',
                  _phoneController,
                  Icons.phone,
                  enabled: true,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    final phoneRegex = RegExp(r'^\+255\d{9}$|^0\d{9}$');
                    if (!phoneRegex.hasMatch(value.trim())) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildModernInfoField(
                  'Email',
                  _emailController,
                  Icons.email,
                  enabled: false,
                  validator: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoField(
    String title,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color:
            enabled
                ? AppColors.background
                : AppColors.background.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              enabled
                  ? AppColors.primary.withAlpha(26)
                  : AppColors.textSecondary.withAlpha(51),
        ),
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          fontSize: 16,
          color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: title,
          labelStyle: TextStyle(
            fontSize: 14,
            color: enabled ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  enabled
                      ? AppColors.primary.withAlpha(20)
                      : AppColors.textSecondary.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: enabled ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildModernActionButtons(ProfileProvider profileProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withAlpha(200)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(51),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap:
                    profileProvider.isLoading || _isUpdatingPicture
                        ? null
                        : _saveChanges,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (profileProvider.isLoading || _isUpdatingPicture)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else
                        const Icon(Icons.save, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        profileProvider.isLoading || _isUpdatingPicture
                            ? 'Updating...'
                            : 'Save Changes',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _selectedImage != null
                ? 'Profile picture and information will be updated'
                : 'Your phone number will be updated',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
