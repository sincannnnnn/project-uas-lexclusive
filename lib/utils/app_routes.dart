import 'package:get/get.dart';

// Screens: Auth
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

// Screens: User
import '../screens/home/home_screen.dart';
import '../screens/home/detail_kamar_screen.dart';
import '../screens/home/detail_promo_screen.dart';
import '../screens/home/riwayat_screen.dart';
import '../screens/home/detail_riwayat_kamar_screen.dart';
import '../screens/home/detail_riwayat_promo_screen.dart';
import '../screens/home/notifikasi_screen.dart';
import '../screens/home/detail_notifikasi_screen.dart';

// Screens: Admin
import '../screens/admin/list_kamar_screen.dart';
import '../screens/admin/form_kamar_screen.dart';
import '../screens/admin/list_minuman_screen.dart';
import '../screens/admin/form_minuman_screen.dart';
import '../screens/admin/pengguna_screen.dart';
import '../screens/admin/verifikasi_reservasi_screen.dart';
import '../screens/admin/admin_notifikasi_screen.dart';
import '../screens/admin/list_promo_screen.dart';
import '../screens/admin/form_promo_screen.dart' ;

// Splash
import '../screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // User
  static const String home = '/home';
  static const String riwayat = '/riwayat';
  static const String detailKamar = '/home/detail-kamar';
  static const String detailPromo = '/promo/detail';
  static const String detailRiwayatKamar = '/riwayat/detail-kamar';
  static const String detailRiwayatPromo = '/riwayat/detail-promo';
  static const String notifikasi = '/notifikasi';
  static const String detailNotifikasi = '/notifikasi/detail';

  // Admin
  static const String kamar = '/admin/kamar';
  static const String formKamar = '/admin/kamar/form';
  static const String minuman = '/admin/minuman';
  static const String formMinuman = '/admin/minuman/form';
  static const String pengguna = '/admin/pengguna';
  static const String verifikasiReservasi = '/admin/verifikasi';
  static const String adminNotifikasi = '/admin/notifikasi';
  static const String listPromo = '/admin/promo';
  static const String formPromo = '/admin/promo/form';

  static final routes = [
    // Splash & Auth
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),

    // User
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: detailKamar, page: () => const DetailKamarScreen()),
    GetPage(name: detailPromo, page: () => const DetailPromoScreen()),
    GetPage(name: riwayat, page: () => const RiwayatScreen()),
    GetPage(name: detailRiwayatKamar, page: () => const DetailRiwayatKamarScreen()),
    GetPage(name: detailRiwayatPromo, page: () => const DetailRiwayatPromoScreen()),
    GetPage(name: notifikasi, page: () => const NotifikasiScreen()),
    GetPage(
      name: detailNotifikasi,
      page: () {
        final data = Get.arguments as Map<String, dynamic>;
        return DetailNotifikasiScreen(data: data);
      },
    ),

    // Admin
    GetPage(name: kamar, page: () => const ListKamarScreen()),
    GetPage(name: formKamar, page: () => const FormKamarScreen()),
    GetPage(name: minuman, page: () => const ListMinumanScreen()),
    GetPage(name: formMinuman, page: () => const FormMinumanScreen()),
    GetPage(name: pengguna, page: () => const PenggunaScreen()),
    GetPage(name: verifikasiReservasi, page: () => const VerifikasiReservasiScreen()),
    GetPage(name: adminNotifikasi, page: () => const AdminNotifikasiScreen()),
    GetPage(name: listPromo, page: () => const ListPromoScreen()),
    GetPage(
      name: formPromo,
      page: () {
        final data = Get.arguments as Map<String, dynamic>?;
        return FormPromoScreen(editData: data);
      }, 
    ),
  ];
}
