import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import screens
import 'list_kamar_screen.dart';
import 'list_minuman_screen.dart';
import 'pengguna_screen.dart';
import 'verifikasi_reservasi_screen.dart';
import 'admin_notifikasi_screen.dart';
import 'list_promo_screen.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 50, 50, 50),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(137, 39, 37, 37),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFD700), // Warna emas
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  "LEXCLUSIVE",
                  style: TextStyle(
                    color: Color(0xFFFFD700), // Warna emas
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          _buildMenuItem("Pengguna", Icons.person, () {
            Get.to(() => const PenggunaScreen());
          }),

          _buildMenuItem("Kamar", Icons.meeting_room, () {
            Get.to(() => const ListKamarScreen());
          }),

          _buildMenuItem("Minuman", Icons.local_drink, () {
            Get.to(() => const ListMinumanScreen());
          }),

          _buildMenuItem("Verifikasi Reservasi", Icons.verified_user, () {
            Get.to(() => const VerifikasiReservasiScreen());
          }),

          _buildMenuItem("Notifikasi", Icons.notifications, () {
            Get.to(() => const AdminNotifikasiScreen());
          }),

          _buildMenuItem("Promo", Icons.discount, () {
            Get.to(() => const ListPromoScreen());
          }),

          const Spacer(),
          const Divider(color: Colors.white24),

          _buildMenuItem("Logout", Icons.logout, () {
            Get.offAllNamed('/login');
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFFFFD700)), // Warna emas
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      hoverColor: Colors.white10,
      onTap: onTap,
    );
  }
}
