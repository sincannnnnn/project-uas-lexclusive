import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../main.dart';
import '../../utils/app_routes.dart';
import '../../services/supabase_service.dart';

class DetailKamarScreen extends StatefulWidget {
  const DetailKamarScreen({super.key});

  @override
  State<DetailKamarScreen> createState() => _DetailKamarScreenState();
}

class _DetailKamarScreenState extends State<DetailKamarScreen> {
  final Map<String, dynamic> kamar = Get.arguments;
  final _formKey = GlobalKey<FormState>();
  final SupabaseService _supabaseService = SupabaseService();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();

  final List<String> _selectedJam = [];
  List<String> _jamTerpakai = [];
  bool _pakaiLc = false;
  List<Map<String, dynamic>> _minumanList = [];
  final Map<String, int> _minumanTerpilih = {};

  bool _isLoading = false;

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
    _loadMinuman();
    _loadJamTerpakai();
  }

  Future<void> _loadMinuman() async {
    final result = await _supabaseService.getAll('minuman');
    setState(() {
      _minumanList = result;
    });
  }

  Future<void> _loadJamTerpakai() async {
    final response = await supabase
        .from('reservasi')
        .select('jam, status')
        .eq('kamar_id', kamar['id']);

    final List<String> jamDipakai = [];

    for (var item in response) {
      if (item['status'] != 'selesai' && item['status'] != 'batal') {
        final List<dynamic> jamList = item['jam'];
        jamDipakai.addAll(jamList.cast<String>());
      }
    }

    setState(() {
      _jamTerpakai = jamDipakai.toSet().toList();
    });
  }

  int get durasi => _selectedJam.length;
  int get hargaKamar => ((kamar['harga'] ?? 0) as num).toInt() * durasi;
  int get hargaLc => _pakaiLc ? 100000 : 0;

  int get hargaMinuman {
    int total = 0;
    _minumanTerpilih.forEach((id, jumlah) {
      final data = _minumanList.firstWhere((e) => e['id'] == id, orElse: () => {});
      final harga = (data['harga'] ?? 0) as num;
      total += (harga * jumlah).toInt();
    });
    return total;
  }

  int get totalPembayaran => hargaKamar + hargaLc + hargaMinuman;

  Future<void> _submitReservasi() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedJam.isEmpty) {
      Get.snackbar('Peringatan', 'Pilih minimal 1 jam.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final List<Map<String, dynamic>> hargaMinumanList = _minumanTerpilih.entries.map((e) {
        final minuman = _minumanList.firstWhere((m) => m['id'] == e.key, orElse: () => {});
        return {
          'id': e.key,
          'harga': minuman['harga'] ?? 0,
          'nama': minuman['nama'] ?? '',
        };
      }).toList();

      await supabase.from('reservasi').insert({
        'user_id': supabase.auth.currentUser!.id,
        'kamar_id': kamar['id'],
        'nama': _namaController.text,
        'telp': _telpController.text,
        'jam': _selectedJam,
        'durasi': durasi,
        'lc': _pakaiLc,
        'minuman': _minumanTerpilih.entries
            .map((e) => {'id': e.key, 'jumlah': e.value})
            .toList(),
        'harga_minum': hargaMinumanList,
        'harga_total': totalPembayaran,
        'status': 'belum bayar',
        'tipe': 'kamar',
      });

      Get.offAllNamed(AppRoutes.riwayat);
    } catch (e) {
      Get.snackbar('Error', 'Gagal reservasi: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => Get.back(),
        ),
        title: const Text('Room',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 147,
                        height: 227,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.amber, width: 3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            kamar['gambar_url'] ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(kamar['nama'] ?? '',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text("Kapasitas: ${kamar['kapasitas'] ?? '-'}",
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text(kamar['deskripsi'] ?? '',
                        style: const TextStyle(color: Colors.white)),
                    const Divider(color: Colors.white54),
                    TextFormField(
                      controller: _namaController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          labelText: 'Nama',
                          labelStyle: TextStyle(color: Colors.white70)),
                      validator: (value) =>
                          value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    TextFormField(
                      controller: _telpController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          labelText: 'No Telepon',
                          labelStyle: TextStyle(color: Colors.white70)),
                      validator: (value) =>
                          value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    const Text('Pilih Jam:',
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: _slotJam.map((jam) {
                        final isSelected = _selectedJam.contains(jam);
                        final isDisabled = _jamTerpakai.contains(jam);

                        Color bgColor;
                        Color textColor;

                        if (isDisabled) {
                          bgColor = Colors.grey.shade700;
                          textColor = Colors.grey.shade400;
                        } else if (isSelected) {
                          bgColor = Colors.amber;
                          textColor = Colors.black;
                        } else {
                          bgColor = Colors.grey.shade800;
                          textColor = Colors.white;
                        }

                        return GestureDetector(
                          onTap: isDisabled
                              ? null
                              : () {
                                  setState(() {
                                    isSelected
                                        ? _selectedJam.remove(jam)
                                        : _selectedJam.add(jam);
                                  });
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.amber
                                    : Colors.white30,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              jam,
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                   
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pakai LC (+Rp100.000)',
                            style: TextStyle(color: Colors.white)),
                        Switch(
                          value: _pakaiLc,
                          onChanged: (val) => setState(() => _pakaiLc = val),
                          activeColor: Colors.amber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Minuman',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    ..._minumanList.map((minum) {
                      final id = minum['id'];
                      final jumlah = _minumanTerpilih[id] ?? 0;
                      return Row(
                        children: [
                          Expanded(
                            child: Text(minum['nama'],
                                style: const TextStyle(color: Colors.white)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                if (jumlah > 0) _minumanTerpilih[id] = jumlah - 1;
                                if (_minumanTerpilih[id] == 0) {
                                  _minumanTerpilih.remove(id);
                                }
                              });
                            },
                          ),
                          Text('$jumlah',
                              style: const TextStyle(color: Colors.white)),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _minumanTerpilih[id] = jumlah + 1;
                              });
                            },
                          ),
                        ],
                      );
                    }),
                     const Text('Rincian Pembayaran',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.amber,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Harga Kamar: Rp$hargaKamar',
                        style: const TextStyle(color: Colors.white)),
                    if (_pakaiLc)
                      const Text('Biaya LC: Rp100000',
                          style: TextStyle(color: Colors.white)),
                    const Divider(color: Colors.white),
                    if (_minumanTerpilih.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _minumanTerpilih.entries.map((e) {
                          final data = _minumanList.firstWhere(
                              (m) => m['id'] == e.key,
                              orElse: () => {});
                          return Text(
                              '${data['nama']} x ${e.value} = Rp${((data['harga'] ?? 0) * e.value).toInt()}',
                              style: const TextStyle(color: Colors.white));
                        }).toList(),
                      ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('Total: Rp$totalPembayaran',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber)),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber),
                        onPressed: _submitReservasi,
                        child: const Text('Reservasi Sekarang'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
