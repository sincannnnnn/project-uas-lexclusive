import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_sidebar.dart';

class AdminNotifikasiScreen extends StatefulWidget {
  const AdminNotifikasiScreen({super.key});

  @override
  State<AdminNotifikasiScreen> createState() => _AdminNotifikasiScreenState();
}

class _AdminNotifikasiScreenState extends State<AdminNotifikasiScreen> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _pesanController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> notifikasiList = [];
  Set<String> expandedItems = {}; // Untuk menandai notifikasi yang terbuka

  @override
  void initState() {
    super.initState();
    fetchNotifikasi();
  }

  Future<void> fetchNotifikasi() async {
    final result = await supabase
        .from('notifikasi')
        .select()
        .order('created_at', ascending: false);

    if (!mounted) return;
    setState(() {
      notifikasiList = List<Map<String, dynamic>>.from(result);
    });
  }

  Future<void> kirimNotifikasi() async {
    final judul = _judulController.text.trim();
    final pesan = _pesanController.text.trim();

    if (judul.isEmpty || pesan.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul dan pesan tidak boleh kosong")),
      );
      return;
    }

    try {
      await supabase.from('notifikasi').insert({
        'judul': judul,
        'pesan': pesan,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      _judulController.clear();
      _pesanController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notifikasi berhasil dikirim")),
      );
      fetchNotifikasi();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengirim notifikasi: $e")),
      );
    }
  }

  Future<void> hapusNotifikasi(String id) async {
    try {
      await supabase.from('notifikasi').delete().eq('id', id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notifikasi berhasil dihapus")),
      );
      fetchNotifikasi();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus notifikasi: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AdminSidebar(),
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                title: const Text("Notifikasi",
                    style: TextStyle(color: Color(0xFFFFD700))),
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _judulController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Judul Notifikasi',
                        labelStyle:
                            const TextStyle(color: Color(0xFFFFD700)),
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFFD700)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _pesanController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Isi Notifikasi',
                        labelStyle:
                            const TextStyle(color: Color(0xFFFFD700)),
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFFD700)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: kirimNotifikasi,
                      icon: const Icon(Icons.send),
                      label: const Text("Kirim Notifikasi"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFFFD700)),
                    const SizedBox(height: 8),
                    const Text(
                      "Riwayat Notifikasi",
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: notifikasiList.isEmpty
                          ? const Center(
                              child: Text("Belum ada notifikasi",
                                  style:
                                      TextStyle(color: Colors.white54)),
                            )
                          : ListView.builder(
                              itemCount: notifikasiList.length,
                              itemBuilder: (context, index) {
                                final item = notifikasiList[index];
                                final id = item['id']?.toString() ?? '';
                                final isExpanded =
                                    expandedItems.contains(id);

                                final pesan = item['pesan'] ?? '';
                                final isiPendek = pesan.length > 40
                                    ? pesan.substring(0, 40) + '...'
                                    : pesan;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isExpanded) {
                                        expandedItems.remove(id);
                                      } else {
                                        expandedItems.add(id);
                                      }
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 300),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[850],
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.white24),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item['judul'] ?? '-',
                                                style: const TextStyle(
                                                  color: Color(0xFFFFD700),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () =>
                                                  hapusNotifikasi(id),
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.redAccent),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isExpanded
                                              ? pesan
                                              : isiPendek,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['created_at'] ?? '',
                                          style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
