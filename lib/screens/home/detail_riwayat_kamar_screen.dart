import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailRiwayatKamarScreen extends StatelessWidget {
  const DetailRiwayatKamarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reservasi = Get.arguments as Map<String, dynamic>;
    final kamar = reservasi['kamar'] ?? {};
    final minumanList = List<Map<String, dynamic>>.from(reservasi['minuman'] ?? []);
    final hargaMinumanList = List<Map<String, dynamic>>.from(reservasi['harga_minum'] ?? []);
    final status = reservasi['status'] ?? '';

    String statusMessage = '';
    if (status == 'belum bayar') {
      statusMessage =
          'Jika tidak melakukan pembayaran kurang dari waktu reservasi,\nmaka akan otomatis dibatalkan.\n(Lakukan pembayaran secara offline)';
    } else if (status == 'sudah bayar') {
      statusMessage = 'Selamat menikmati layanan kami.';
    } else if (status == 'selesai') {
      statusMessage = 'Terima kasih.';
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Detail Reservasi Kamar'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.amber, width: 1),
          ),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildDetailItem('Nama', reservasi['nama']),
              _buildDetailItem('No Telepon', reservasi['telp']),
              _buildDetailItem('Kamar', kamar['nama']),
              _buildDetailItem('Kapasitas', kamar['kapasitas']),
              _buildDetailItem('Harga Kamar', 'Rp ${kamar['harga']}'),
              _buildDetailItem('Durasi', '${reservasi['durasi']} jam'),
              _buildDetailItem('Jam', (reservasi['jam'] as List).join(', ')),
              _buildDetailItem('LC', reservasi['lc'] == true ? 'Ya (Rp100.000)' : 'Tidak'),
              const SizedBox(height: 8),
              const Text('Minuman:',
                  style: TextStyle(color: Colors.amber, fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...minumanList.map((item) {
                final jumlah = item['jumlah'] ?? 0;
                final id = item['id'] ?? '-';
                final hargaData = hargaMinumanList.firstWhere(
                  (e) => e['id'] == id,
                  orElse: () => {'nama': 'Tidak diketahui', 'harga': 0},
                );
                final nama = hargaData['nama'];
                final harga = hargaData['harga'];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$nama x$jumlah', style: const TextStyle(color: Colors.white70)),
                      Text('Rp$harga x $jumlah', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              }),
              const Divider(color: Colors.white24, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Bayar:',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('Rp ${reservasi['harga_total']}',
                      style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              _buildDetailItem('Status', status),
              const SizedBox(height: 8),
              if (statusMessage.isNotEmpty)
                Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      border: Border.all(color: Colors.amber),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusMessage,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$title:',
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          Flexible(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
