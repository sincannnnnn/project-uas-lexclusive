import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';

class DetailPromoScreen extends StatefulWidget {
  const DetailPromoScreen({super.key});

  @override
  State<DetailPromoScreen> createState() => _DetailPromoScreenState();
}

class _DetailPromoScreenState extends State<DetailPromoScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> promo = {};
  List<String> selectedJam = [];
  List<String> jamTersedia = [];
  List<String> jamDipakai = [];
  bool isLoading = true;

  final namaController = TextEditingController();
  final telpController = TextEditingController();

  final List<String> _slotJam = [
    '15.00-16.00',
    '16.00-17.00',
    '17.00-18.00',
    '18.00-19.00',
    '19.00-20.00',
    '20.00-21.00',
    '21.00-22.00',
    '22.00-23.00',
    '23.00-00.00',
  ];

  @override
  void initState() {
    super.initState();
    promo = Get.arguments;
    _initData();
  }

  Future<void> _initData() async {
    final kamarId = promo['kamar_id'];
    jamDipakai = await _supabaseService.getJamTerpakai(kamarId);
    jamTersedia = _slotJam.where((slot) => !jamDipakai.contains(slot)).toList();

    final minumanRaw = promo['minuman'] as List<dynamic>;
    final minumanFinal = await _getMinumanWithNama(minumanRaw);
    promo['minuman'] = minumanFinal;

    setState(() => isLoading = false);
  }

  Future<List<Map<String, dynamic>>> _getMinumanWithNama(List minumanJson) async {
    final allMinuman = await _supabaseService.getMinumanList();
    return minumanJson.map<Map<String, dynamic>>((item) {
      final id = item['id'];
      final jumlah = item['jumlah'] ?? 0;
      final nama = allMinuman.firstWhere(
        (m) => m['id'] == id,
        orElse: () => {'nama': 'Minuman'},
      )['nama'];
      return {'id': id, 'jumlah': jumlah, 'nama': nama};
    }).toList();
  }

  Future<void> _submitReservasi() async {
    if (!_formKey.currentState!.validate()) return;

    final nama = namaController.text;
    final telp = telpController.text;
    final kamarId = promo['kamar_id'];
    final lc = promo['lc'] == true;
    final hargaPromo = promo['harga'];
    final namaPromo = promo['nama'];
    final durasi = promo['durasi'] ?? 1;

    if (selectedJam.length != durasi) {
      Get.snackbar('Error', 'Pilih $durasi jam!',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final List<Map<String, dynamic>> minumanList = (promo['minuman'] as List)
        .map((e) => {
              'id': e['id'],
              'nama': e['nama'],
              'jumlah': e['jumlah'],
            })
        .toList();

    try {
      await _supabaseService.buatReservasi(
        nama: nama,
        telp: telp,
        jam: selectedJam,
        lc: lc,
        minumanDipilih: minumanList,
        kamarId: kamarId,
        total: hargaPromo,
        tipe: 'promo',
        namaPromo: namaPromo,
      );

      Get.snackbar('Berhasil', 'Reservasi berhasil dikirim',
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.offAllNamed(AppRoutes.riwayat);
    } catch (e) {
      Get.snackbar('Error', 'Gagal melakukan reservasi: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kamar = promo['kamar'];
    final imageUrl = kamar?['gambar_url'] ?? '';
    final minumanList = (promo['minuman'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        title: Text(promo['nama']),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Kamar
                  if (imageUrl.isNotEmpty)
                    Center(
                      child: Container(
                        width: 147,
                        height: 217,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.amber, width: 3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(imageUrl, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Informasi
                  Text('Nama Kamar: ${kamar?['nama'] ?? ''}',
                      style: const TextStyle(color: Colors.white)),
                  Text('Kapasitas: ${promo['kapasitas']} orang',
                      style: const TextStyle(color: Colors.white)),

                  const SizedBox(height: 12),
                  const Text('Paket:',
                      style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  if (promo['lc'] == true)
                    const Text('+ LC', style: TextStyle(color: Colors.white)),

                  const SizedBox(height: 9),
                  Text('Durasi: ${promo['durasi']} jam',
                      style: const TextStyle(color: Colors.white)),

                  const SizedBox(height: 12),
                  const Text('Minuman:',
                      style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  ...minumanList.map((m) {
                    return Text(
                      '${m['nama']} x${m['jumlah']}',
                      style: const TextStyle(color: Colors.white),
                    );
                  }),

                  const SizedBox(height: 12),
                  Text('Harga Promo: Rp${promo['harga']}',
                      style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold)),

                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: namaController,
                          decoration: const InputDecoration(
                            labelText: 'Nama',
                            labelStyle: TextStyle(color: Colors.white70),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (val) =>
                              val!.isEmpty ? 'Nama wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: telpController,
                          decoration: const InputDecoration(
                            labelText: 'No Telp',
                            labelStyle: TextStyle(color: Colors.white70),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (val) =>
                              val!.isEmpty ? 'No Telp wajib diisi' : null,
                        ),
                        const SizedBox(height: 20),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text('Pilih Jam:',
                              style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: jamTersedia.map((jam) {
                            final isSelected = selectedJam.contains(jam);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedJam.remove(jam);
                                  } else {
                                    selectedJam.add(jam);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.amber
                                      : Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: isSelected
                                          ? Colors.amber
                                          : Colors.white30),
                                ),
                                child: Text(
                                  jam,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24)),
                          onPressed: _submitReservasi,
                          child: const Text('Reservasi Sekarang',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
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
