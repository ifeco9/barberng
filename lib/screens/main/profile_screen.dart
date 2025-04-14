import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel? userData;

  const ProfileScreen({
    Key? key,
    this.userData,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  File? _imageFile;
  String? _profileImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _profileImageUrl = widget.userData?.profileImageUrl;
  }

  Future<void> _pickAndUploadImage() async {
    setState(() => _isLoading = true);
    try {
      final image = await _storageService.pickImage();
      if (image != null) {
        setState(() => _imageFile = image);
        
        // Delete old image if exists
        if (_profileImageUrl != null) {
          await _storageService.deleteProfileImage(_profileImageUrl!);
        }

        // Upload new image
        final imageUrl = await _storageService.uploadProfileImage(
          _imageFile!,
          widget.userData?.uid ?? '',
        );

        if (imageUrl != null) {
          setState(() => _profileImageUrl = imageUrl);
          // Update user profile in database
          await _authService.updateUserProfile(
            widget.userData?.uid ?? '',
            {'profileImageUrl': imageUrl},
          );
        }
      }
    } catch (e) {
      print('Error updating profile image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile image')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (_profileImageUrl != null
                                  ? NetworkImage(_profileImageUrl!)
                                  : null) as ImageProvider?,
                          child: _imageFile == null && _profileImageUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (widget.userData != null) ...[
                    Text(
                      widget.userData!.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.userData!.email,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (widget.userData!.phoneNumber != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.userData!.phoneNumber!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ],
                ],
              ),
            ),
    );
  }
} 