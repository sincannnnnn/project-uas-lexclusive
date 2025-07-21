import 'package:flutter/material.dart';
import 'riwayat_screen.dart';

class NotaScreen extends StatelessWidget {
  final Map<String, dynamic> reservasi;
  final Map<String, dynamic> kamar;

  const NotaScreen({
    super.key,
    required this.reservasi,
    required this.kamar,
  });

  @override
  Widget build(BuildContext context) {
    final bool gunakanLc = reservasi['gunakan_lc'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        title: const Text('Nota Reservasi', style: TextStyle(color: Color(0xFFFFD700))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama: ${reservasi['nama']}'),
              Text('No Telp: ${reservasi['no_telp']}'),
              Text('Kamar: ${kamar['nama']}'),
              Text('Jam: ${reservasi['jam_mulai']} - ${reservasi['jam_selesai']}'),
              Text('Durasi: ${reservasi['durasi']} jam'),
              if (gunakanLc) Text('Gunakan LC: Ya'),
              if ((reservasi['total_minuman'] ?? 0) > 0)
                Text('Total Minuman: Rp${reservasi['total_minuman']}'),

              const SizedBox(height: 16),
              const Divider(color: Color(0xFFFFD700)),
              Text(
                'Total Harga: Rp${reservasi['total_harga']}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '⚠️ Jika 10 menit sebelum waktu yang dipesan belum dilakukan verifikasi, maka reservasi akan dibatalkan.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const RiwayatScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('Kembali ke Riwayat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
