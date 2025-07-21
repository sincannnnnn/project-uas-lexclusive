import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_routes.dart';
import '../home/menu.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> with SingleTickerProviderStateMixin {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _semuaReservasi = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _fetchReservasi();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _fetchReservasi() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase
          .from('reservasi')
          .select('*, kamar(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        _semuaReservasi = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  List<Map<String, dynamic>> getReservasiByStatus(String status) {
    return _semuaReservasi.where((r) => (r['status'] ?? '') == status).toList();
  }

  void _navigateToDetail(Map<String, dynamic> reservasi) {
    final tipe = reservasi['tipe'];
    if (tipe == 'kamar') {
      Get.toNamed(AppRoutes.detailRiwayatKamar, arguments: reservasi);
    } else {
      Get.toNamed(AppRoutes.detailRiwayatPromo, arguments: reservasi);
    }
  }

  Future<void> _batalkanReservasi(String id) async {
    try {
      await supabase.from('reservasi').update({'status': 'batal'}).eq('id', id);
      await _fetchReservasi();
      Get.snackbar('Berhasil', 'Reservasi dibatalkan',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Gagal membatalkan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _hapusReservasi(String id) async {
    try {
      await supabase.from('reservasi').delete().eq('id', id);
      await _fetchReservasi();
      Get.snackbar('Dihapus', 'Reservasi berhasil dihapus',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Widget _buildReservasiList(List<Map<String, dynamic>> data, String status) {
    if (data.isEmpty) {
      return const Center(child: Text("Tidak ada data", style: TextStyle(color: Colors.white70)));
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final reservasi = data[index];
        final kamar = reservasi['kamar'];
        final namaKamar = kamar?['nama'] ?? '-';
        final jam = (reservasi['jam'] as List).join(', ');
        final harga = reservasi['harga_total'];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber, width: 1),
          ),
          child: InkWell(
            onTap: () => _navigateToDetail(reservasi),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Nama dan Harga
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reservasi['nama'] ?? '',
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                    Text('Rp $harga', style: const TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Kamar: $namaKamar', style: const TextStyle(color: Colors.white70)),
                // Baris Jam dan Aksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Jam: $jam', style: const TextStyle(color: Colors.white70)),
                    if (status == 'belum bayar')
                      TextButton.icon(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text("Batalkan", style: TextStyle(color: Colors.red)),
                        onPressed: () => _batalkanReservasi(reservasi['id']),
                      ),
                    if (status == 'selesai')
                      TextButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text("Hapus", style: TextStyle(color: Colors.red)),
                        onPressed: () => _hapusReservasi(reservasi['id']),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Riwayat Reservasi', style: TextStyle(color: Colors.amber)),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(text: 'Belum Bayar'),
            Tab(text: 'Sudah Bayar'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildReservasiList(getReservasiByStatus('belum bayar'), 'belum bayar'),
                _buildReservasiList(getReservasiByStatus('sudah bayar'), 'sudah bayar'),
                _buildReservasiList(getReservasiByStatus('selesai'), 'selesai'),
              ],
            ),
      bottomNavigationBar: Menu(currentIndex: 2, onTap: (index) {
        if (index == 0) {
          Get.offAllNamed(AppRoutes.home);
        } else if (index == 1) {
          Get.offAllNamed(AppRoutes.notifikasi);
        }
      }),
    );
  }
}
