import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../main.dart';
import '../../utils/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash delay

    final user = supabase.auth.currentUser;

    if (user != null) {
      Get.offAllNamed(AppRoutes.home); // Login sukses → HomeScreen
    } else {
      Get.offAllNamed(AppRoutes.login); // Belum login → LoginScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gambar tengah
            Image.network(
              'https://wydrubcbcfzkciyxwndo.supabase.co/storage/v1/object/public/kamar//kamar_1752425643351.jpg',
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            // Loading indicator
            const CircularProgressIndicator(color: Color(0xFFD9A441)),
          ],
        ),
      ),
    );
  }
}
