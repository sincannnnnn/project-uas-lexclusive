import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import '../admin/admin_sidebar.dart';

class ListKamarScreen extends StatefulWidget {
  const ListKamarScreen({super.key});

  @override
  State<ListKamarScreen> createState() => _ListKamarScreenState();
}

class _ListKamarScreenState extends State<ListKamarScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _kamarList = [];
  bool _isLoading = true;

  final NumberFormat formatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _fetchKamar();
  }

  Future<void> _fetchKamar() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabaseService.getAll('kamar');
      setState(() => _kamarList = data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data kamar: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteKamar(String id) async {
    try {
      await _supabaseService.deleteRow('kamar', 'id', id);
      Get.snackbar(
        'Sukses',
        'Kamar berhasil dihapus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _fetchKamar();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus kamar: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showDeleteConfirmation(String id) {
    Get.defaultDialog(
      backgroundColor: Colors.black87,
      title: "Hapus Kamar",
      titleStyle: const TextStyle(color: Color(0xFFFFD700)),
      middleText: "Apakah Anda yakin ingin menghapus kamar ini?",
      middleTextStyle: const TextStyle(color: Colors.white),
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFFFD700),
      onConfirm: () {
        Get.back();
        _deleteKamar(id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          const SizedBox(
            width: 240,
            child: AdminSidebar(),
          ),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.black,
                  foregroundColor: const Color(0xFFFFD700),
                  title: const Text(
                    'Daftar Kamar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  automaticallyImplyLeading: false,
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
                      : _kamarList.isEmpty
                          ? const Center(
                              child: Text(
                                'Belum ada kamar. Tambahkan sekarang!',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _kamarList.length,
                              itemBuilder: (context, index) {
                                final kamar = _kamarList[index];
                                return Card(
                                  color: Colors.grey[900],
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(color: Color(0xFFFFD700), width: 1),
                                  ),
                                  child: ListTile(
                                    leading: kamar['gambar_url'] != null &&
                                            kamar['gambar_url'].toString().isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              kamar['gambar_url'],
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Icon(Icons.image_not_supported,
                                            size: 50, color: Colors.white70),
                                    title: Text(
                                      kamar['nama'] ?? 'Tanpa Nama',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      'Kapasitas: ${kamar['kapasitas']} • Harga: ${formatter.format(kamar['harga'])}',
                                      style: const TextStyle(color: Colors.white70),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Color(0xFFFFD700)),
                                          onPressed: () async {
                                            final result = await Get.toNamed(
                                              AppRoutes.formKamar,
                                              arguments: kamar,
                                            );
                                            if (result == true) _fetchKamar();
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _showDeleteConfirmation(kamar['id'].toString()),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFD700),
        onPressed: () async {
          final result = await Get.toNamed(AppRoutes.formKamar);
          if (result == true) _fetchKamar();
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
