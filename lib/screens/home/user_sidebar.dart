import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import 'profile_bottom_sheet.dart';

class UserSidebar extends StatefulWidget {
  final VoidCallback onProfileUpdated;

  const UserSidebar({
    super.key,
    required this.onProfileUpdated,
  });

  @override
  State<UserSidebar> createState() => _UserSidebarState();
}

class _UserSidebarState extends State<UserSidebar> {
  final SupabaseService _supabaseService = SupabaseService();
  bool isLoading = true;
  String? avatarUrl;
  String? username;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => isLoading = true);
    try {
      final data = await _supabaseService.getProfile();
      setState(() {
        avatarUrl = data?['avatar_url'];
        username = data?['username'];
      });
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat profil: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250, // ← diperlebar dari 220
      child: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Color(0xFF1A1A1A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                isLoading
                    ? const CircularProgressIndicator(color: Colors.amber)
                    : Column(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                                ? NetworkImage(avatarUrl!)
                                : const NetworkImage('https://via.placeholder.com/150'),
                            backgroundColor: Colors.white,
                            child: (avatarUrl == null || avatarUrl!.isEmpty)
                                ? const Icon(Icons.person, size: 40, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Good Morning',
                            style: TextStyle(color: Colors.amber, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            username ?? 'Pengguna',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500, // ← sedikit kurangi bold
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                const SizedBox(height: 12),

                TextButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return DraggableScrollableSheet(
                          expand: false,
                          initialChildSize: 0.6,
                          minChildSize: 0.5,
                          maxChildSize: 0.9,
                          builder: (context, scrollController) => ProfileBottomSheet(
                            onProfileUpdated: () {
                              widget.onProfileUpdated();
                              _loadProfile();
                            },
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.edit, color: Colors.amber, size: 18),
                  label: const Text('Edit Profil', style: TextStyle(color: Colors.amber)),
                ),

                const Divider(color: Colors.amber, thickness: 0.8, indent: 16, endIndent: 16),
                const Spacer(),

                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.amber),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    await Supabase.instance.client.auth.signOut();
                    Get.offAllNamed(AppRoutes.splash);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
