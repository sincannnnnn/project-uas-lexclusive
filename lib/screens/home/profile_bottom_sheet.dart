import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../main.dart';
import '../../models/profile_model.dart';
import '../../services/supabase_service.dart';

class ProfileBottomSheet extends StatefulWidget {
  final VoidCallback onProfileUpdated;

  const ProfileBottomSheet({super.key, required this.onProfileUpdated});

  @override
  State<ProfileBottomSheet> createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends State<ProfileBottomSheet> {
  final SupabaseService _supabaseService = SupabaseService();
  Profile? _profile;
  bool _isLoading = true;
  final TextEditingController _usernameController = TextEditingController();

  XFile? _selectedImage;
  Uint8List? _webImageBytes;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabaseService.getProfile();
      if (mounted && data != null) {
        setState(() {
          _profile = Profile.fromJson(data);
          _usernameController.text = _profile?.username ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Gagal memuat profil: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );

    if (imageFile != null) {
      if (mounted) {
        setState(() {
          _selectedImage = imageFile;
        });
      }

      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        if (mounted) {
          setState(() {
            _webImageBytes = bytes;
          });
        }
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_usernameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Username tidak boleh kosong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);
    String? avatarUrl;

    try {
      if (_selectedImage != null) {
        final fileName =
            '${supabase.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

        avatarUrl = kIsWeb && _webImageBytes != null
            ? await _supabaseService.uploadImageBytes(
                _webImageBytes!, fileName, 'avatars')
            : await _supabaseService.uploadImage(
                File(_selectedImage!.path), fileName, 'avatars');
      }

      await _supabaseService.updateProfile(
        username: _usernameController.text,
        avatarUrl: avatarUrl ?? _profile?.avatarUrl,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onProfileUpdated();
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Gagal memperbarui profil: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarPreview;

    if (_selectedImage != null) {
      if (kIsWeb && _webImageBytes != null) {
        avatarPreview = MemoryImage(_webImageBytes!);
      } else if (!kIsWeb) {
        avatarPreview = FileImage(File(_selectedImage!.path));
      }
    } else if (_profile?.avatarUrl != null) {
      avatarPreview = NetworkImage(_profile!.avatarUrl!);
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 500),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        const Text(
                          'Profil Saya',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: avatarPreview,
                        backgroundColor: Colors.grey[800],
                        child: avatarPreview == null
                            ? const Icon(Icons.person, size: 50, color: Colors.white70)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _pickAvatar,
                      icon: const Icon(Icons.camera_alt, color: Color(0xFFFFD700)),
                      label: const Text(
                        'Ganti Avatar',
                        style: TextStyle(color: Color(0xFFFFD700)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: const TextStyle(color: Color(0xFFFFD700)),
                        filled: true,
                        fillColor: Colors.grey[850],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFFD700)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _updateProfile,
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan Perubahan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
