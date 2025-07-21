import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/supabase_service.dart';
import 'admin_sidebar.dart';

class VerifikasiReservasiScreen extends StatefulWidget {
  const VerifikasiReservasiScreen({super.key});

  @override
  State<VerifikasiReservasiScreen> createState() => _VerifikasiReservasiScreenState();
}

class _VerifikasiReservasiScreenState extends State<VerifikasiReservasiScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  List<Map<String, dynamic>> belumBayarList = [];
  List<Map<String, dynamic>> sudahBayarList = [];
  List<Map<String, dynamic>> selesaiList = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservasi();
  }

  Future<void> _loadReservasi() async {
    setState(() => isLoading = true);
    final allData = await _supabaseService.getAll('reservasi');

    setState(() {
      belumBayarList = allData.where((e) => e['status'] == 'belum bayar').toList();
      sudahBayarList = allData.where((e) => e['status'] == 'sudah bayar').toList();
      selesaiList = allData.where((e) => e['status'] == 'selesai').toList();
      isLoading = false;
    });
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    await _supabaseService.updateRow('reservasi', {'status': newStatus}, id);
    await _loadReservasi();
    Get.snackbar('Sukses', 'Status berhasil diubah ke $newStatus',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  Widget _buildReservasiItem(Map<String, dynamic> item, String status) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(item['nama'] ?? '-', style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          'No Telp: ${item['telp']}\nTipe: ${item['tipe'] ?? '-'}\nTotal: Rp${item['harga_total'] ?? 0}',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: status != 'selesai'
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () {
                  if (status == 'belum bayar') {
                    _updateStatus(item['id'], 'sudah bayar');
                  } else if (status == 'sudah bayar') {
                    _updateStatus(item['id'], 'selesai');
                  }
                },
                child: Text(
                  status == 'belum bayar' ? 'Verifikasi' : 'Selesaikan',
                  style: const TextStyle(color: Colors.black),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildTabContent(List<Map<String, dynamic>> list, String status) {
    if (list.isEmpty) {
      return const Center(
        child: Text('Tidak ada data', style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, index) => _buildReservasiItem(list[index], status),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Row(
          children: [
            const AdminSidebar(), // Sidebar kiri

            Expanded(
              child: Column(
                children: [
                  Container(
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Verifikasi Reservasi',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const TabBar(
                    labelColor: Colors.amber,
                    unselectedLabelColor: Colors.white54,
                    indicatorColor: Colors.amber,
                    tabs: [
                      Tab(text: 'Belum Bayar'),
                      Tab(text: 'Sudah Bayar'),
                      Tab(text: 'Selesai'),
                    ],
                  ),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                        : TabBarView(
                            children: [
                              _buildTabContent(belumBayarList, 'belum bayar'),
                              _buildTabContent(sudahBayarList, 'sudah bayar'),
                              _buildTabContent(selesaiList, 'selesai'),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
