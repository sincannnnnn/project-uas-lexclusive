import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailNotifikasiScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailNotifikasiScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.parse(data['created_at']);
    final judul = data['judul'] ?? '-';
    final isi = data['pesan'] ?? '-';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Detail Notifikasi", style: TextStyle(color: Colors.amber)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Gambar, Judul, Tanggal & Jam
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipOval(
                    child: Image.network(
                      'https://wydrubcbcfzkciyxwndo.supabase.co/storage/v1/object/public/kamar//kamar_1752295663753.jpg',
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          judul,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('dd MMM yyyy').format(createdAt),
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('HH:mm').format(createdAt),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(color: Colors.white24, thickness: 1),
              const SizedBox(height: 12),

              // Isi notifikasi
              Text(
                isi,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
