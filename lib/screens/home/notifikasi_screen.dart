import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detail_notifikasi_screen.dart';
import '../home/menu.dart'; // pastikan path ke menu.dart sesuai

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  int _selectedIndex = 1;

  Future<List<Map<String, dynamic>>> fetchNotifikasi() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return [];

    final profile = await supabase
        .from('profiles')
        .select('created_at')
        .eq('id', user.id)
        .single();

    final userCreatedAt = DateTime.parse(profile['created_at']);

    final data = await supabase
        .from('notifikasi')
        .select()
        .gte('created_at', userCreatedAt.toIso8601String())
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigasi ke halaman sesuai index
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // sudah di halaman Notifikasi
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/riwayat');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Notifikasi', style: TextStyle(color: Colors.amber)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchNotifikasi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.amber));
          }

          if (snapshot.hasError) {
            return const Center(
                child: Text('Gagal memuat data',
                    style: TextStyle(color: Colors.white)));
          }

          final notifs = snapshot.data ?? [];
          if (notifs.isEmpty) {
            return const Center(
                child: Text('Tidak ada notifikasi',
                    style: TextStyle(color: Colors.white)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notifs.length,
            itemBuilder: (context, index) {
              final notif = notifs[index];
              final createdAt = DateTime.parse(notif['created_at']);
              final isiPendek = (notif['pesan'] ?? '').toString();
              final isiTampil =
                  isiPendek.length > 60 ? isiPendek.substring(0, 60) + '...' : isiPendek;

              return Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailNotifikasiScreen(data: notif),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipOval(
                          child: Image.network(
                            'https://wydrubcbcfzkciyxwndo.supabase.co/storage/v1/object/public/kamar//kamar_1752295663753.jpg',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif['judul'] ?? '-',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd MMM yyyy • HH:mm')
                                    .format(createdAt),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isiTampil,
                                style: const TextStyle(color: Colors.white),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Menu(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
