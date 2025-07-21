import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import 'admin_sidebar.dart';

class ListMinumanScreen extends StatefulWidget {
  const ListMinumanScreen({super.key});

  @override
  State<ListMinumanScreen> createState() => _ListMinumanScreenState();
}

class _ListMinumanScreenState extends State<ListMinumanScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _minumanList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMinuman();
  }

  Future<void> _fetchMinuman() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabaseService.getAll('minuman');
      setState(() => _minumanList = data);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat minuman: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMinuman(String id) async {
    try {
      await _supabaseService.deleteRow('minuman', 'id', id);
      Get.snackbar('Sukses', 'Minuman dihapus',
          backgroundColor: Colors.green, colorText: Colors.white);
      _fetchMinuman();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus minuman: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _showDeleteDialog(String id) {
    Get.defaultDialog(
      backgroundColor: Colors.black87,
      titleStyle: const TextStyle(color: Color(0xFFFFD700)),
      title: 'Hapus Minuman',
      middleText: 'Yakin ingin menghapus minuman ini?',
      middleTextStyle: const TextStyle(color: Colors.white),
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFFFD700),
      onConfirm: () {
        Get.back();
        _deleteMinuman(id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          const AdminSidebar(),
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                foregroundColor: const Color(0xFFFFD700),
                title: const Text(
                  'Daftar Minuman',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                automaticallyImplyLeading: false,
              ),
              body: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
                  : _minumanList.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada minuman.',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _minumanList.length,
                          itemBuilder: (context, index) {
                            final minuman = _minumanList[index];
                            return Card(
                              color: Colors.grey[900],
                              margin: const EdgeInsets.all(8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Color(0xFFFFD700), width: 1),
                              ),
                              child: ListTile(
                                title: Text(
                                  minuman['nama'] ?? 'Tanpa Nama',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Harga: Rp ${minuman['harga']}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Color(0xFFFFD700)),
                                      onPressed: () async {
                                        final result = await Get.toNamed(
                                          AppRoutes.formMinuman,
                                          arguments: minuman,
                                        );
                                        if (result == true) _fetchMinuman();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _showDeleteDialog(minuman['id'].toString()),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: const Color(0xFFFFD700),
                onPressed: () async {
                  final result = await Get.toNamed(AppRoutes.formMinuman);
                  if (result == true) _fetchMinuman();
                },
                child: const Icon(Icons.add, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
