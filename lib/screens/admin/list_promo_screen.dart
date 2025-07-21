import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/supabase_service.dart';
import 'form_promo_screen.dart' as promo;
import 'admin_sidebar.dart'; // pastikan file ini ada dan memiliki widget AdminSidebar

class ListPromoScreen extends StatefulWidget {
  const ListPromoScreen({super.key});

  @override
  State<ListPromoScreen> createState() => _ListPromoScreenState();
}

class _ListPromoScreenState extends State<ListPromoScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _promoList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPromo();
  }

  Future<void> _loadPromo() async {
    setState(() => _isLoading = true);
    final promos = await _supabaseService.getAll('promo');
    setState(() {
      _promoList = promos;
      _isLoading = false;
    });
  }

  Future<void> _hapusPromo(String id) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menghapus promo ini?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Batal')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true) {
      await _supabaseService.deleteRow('promo', 'id', id);
      _loadPromo();
    }
  }

  Future<void> _editPromo(Map<String, dynamic> promoData) async {
    final result = await Get.to(() => promo.FormPromoScreen(editData: promoData));
    if (result == true) _loadPromo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // ✅ Sidebar Admin
          const AdminSidebar(),

          // ✅ Konten List Promo
          Expanded(
            child: Column(
              children: [
                AppBar(
                  automaticallyImplyLeading: false, // ❌ hilangkan tombol back
                  title: const Text('List Promo'),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.amber,
                  actions: [
                    IconButton(
                      onPressed: () async {
                        final result = await Get.to(() => const promo.FormPromoScreen());
                        if (result == true) _loadPromo();
                      },
                      icon: const Icon(Icons.add, color: Colors.amber),
                    ),
                  ],
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                      : ListView.builder(
                          itemCount: _promoList.length,
                          itemBuilder: (context, index) {
                            final promoItem = _promoList[index];
                            return Card(
                              color: const Color(0xFF1E1E1E),
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Text(promoItem['nama'],
                                    style: const TextStyle(color: Colors.amber)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Durasi: ${promoItem['durasi']} jam',
                                        style: const TextStyle(color: Colors.white70)),
                                    Text('Harga: Rp${promoItem['harga']}',
                                        style: const TextStyle(color: Colors.white70)),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _editPromo(promoItem),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _hapusPromo(promoItem['id']),
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
    );
  }
}
