import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailRiwayatPromoScreen extends StatelessWidget {
  const DetailRiwayatPromoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Get.arguments as Map<String, dynamic>;
    final kamar = data['kamar'] ?? {};
    final minumanList = List<Map<String, dynamic>>.from(data['minuman'] ?? []);
    final lc = data['lc'] == true;
    final total = data['harga_total'] ?? 0;
    final durasi = data['durasi']?.toString() ?? '-';
    final status = data['status'] ?? '';

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
        title: const Text('Detail Promo'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber, width: 1),
          ),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildItem('Nama', data['nama']),
              _buildItem('No Telp', data['telp']),
              _buildItem('Nama Promo', data['nama_promo']),
              _buildItem('Nama Kamar', kamar['nama']),
              _buildItem('Kapasitas', '${kamar['kapasitas']} orang'),
              const SizedBox(height: 6),
              const Text(
                'Paket:',
                style: TextStyle(
                    color: Colors.amber,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                lc ? '+ LC' : 'Tidak',
                style: const TextStyle(color: Colors.white),
              ),
              _buildItem('Durasi', '$durasi jam'),
              if (minumanList.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Minuman:',
                  style: TextStyle(
                      color: Colors.amber,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...minumanList.map((m) {
                  final nama = m['nama'] ?? '';
                  final jumlah = m['jumlah'] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$nama x$jumlah',
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  );
                }),
              ],
              const SizedBox(height: 14),
              const Divider(color: Colors.white24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Bayar:',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  Text('Rp$total',
                      style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              _buildItem('Status', status),
              if (statusMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.amber),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black45,
                    ),
                    child: Text(
                      statusMessage,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(String title, dynamic value) {
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
