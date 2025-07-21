import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/supabase_service.dart';

class FormPromoScreen extends StatefulWidget {
  final Map<String, dynamic>? editData;

  const FormPromoScreen({super.key, this.editData});

  @override
  State<FormPromoScreen> createState() => _FormPromoScreenState();
}

class _FormPromoScreenState extends State<FormPromoScreen> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseService _supabaseService = SupabaseService();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _durasiController = TextEditingController();
  final TextEditingController _kapasitasController = TextEditingController();

  List<Map<String, dynamic>> kamarList = [];
  List<Map<String, dynamic>> minumanList = [];
  final Map<String, int> _minumanTerpilih = {};

  String? selectedKamarId;
  bool _pakaiLc = false;
  bool _isLoading = false;
  String? editId;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.editData != null) {
      final data = widget.editData!;
      editId = data['id'];
      _namaController.text = data['nama'] ?? '';
      _hargaController.text = '${data['harga'] ?? ''}';
      _durasiController.text = '${data['durasi'] ?? ''}';
      _kapasitasController.text = '${data['kapasitas'] ?? ''}';
      selectedKamarId = data['kamar_id'];
      _pakaiLc = data['lc'] ?? false;

      if (data['minuman'] is List) {
        for (var item in data['minuman']) {
          _minumanTerpilih[item['id']] = item['jumlah'];
        }
      }
    }
  }

  Future<void> _loadData() async {
    final kamar = await _supabaseService.getAll('kamar');
    final minuman = await _supabaseService.getAll('minuman');
    setState(() {
      kamarList = kamar;
      minumanList = minuman;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedKamarId == null) {
      Get.snackbar('Error', 'Pilih kamar terlebih dahulu',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'nama': _namaController.text,
      'kamar_id': selectedKamarId,
      'kapasitas': int.tryParse(_kapasitasController.text) ?? 0,
      'lc': _pakaiLc,
      'minuman': _minumanTerpilih.entries.map((e) => {'id': e.key, 'jumlah': e.value}).toList(),
      'harga': int.tryParse(_hargaController.text) ?? 0,
      'durasi': int.tryParse(_durasiController.text) ?? 1,
    };

    try {
      if (editId != null) {
        await _supabaseService.updateRow('promo', data, editId!);
      } else {
        await _supabaseService.insertRow('promo', data);
      }
      Get.back(result: true);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan promo: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _durasiController.dispose();
    _kapasitasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(editId != null ? 'Edit Promo' : 'Tambah Promo'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
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
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                          labelText: 'Nama Promo',
                          labelStyle: TextStyle(color: Colors.white70)),
                      style: const TextStyle(color: Colors.white),
                      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedKamarId,
                      decoration: const InputDecoration(
                          labelText: 'Pilih Kamar',
                          labelStyle: TextStyle(color: Colors.white70)),
                      dropdownColor: Colors.grey[900],
                      style: const TextStyle(color: Colors.white),
                      items: kamarList.map<DropdownMenuItem<String>>((kamar) {
                        return DropdownMenuItem<String>(
                          value: kamar['id'],
                          child: Text(kamar['nama']),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => selectedKamarId = val);
                      },
                      validator: (val) => val == null ? 'Wajib dipilih' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _kapasitasController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Kapasitas (jumlah orang)',
                          labelStyle: TextStyle(color: Colors.white70)),
                      style: const TextStyle(color: Colors.white),
                      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pakai LC', style: TextStyle(color: Colors.white)),
                        Switch(
                          value: _pakaiLc,
                          onChanged: (val) => setState(() => _pakaiLc = val),
                          activeColor: Colors.amber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Minuman:', style: TextStyle(color: Colors.white70)),
                    ...minumanList.map((minum) {
                      final id = minum['id'];
                      final jumlah = _minumanTerpilih[id] ?? 0;
                      return Row(
                        children: [
                          Expanded(
                            child: Text(minum['nama'], style: const TextStyle(color: Colors.white)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                if (jumlah > 0) _minumanTerpilih[id] = jumlah - 1;
                                if (_minumanTerpilih[id] == 0) _minumanTerpilih.remove(id);
                              });
                            },
                          ),
                          Text('$jumlah', style: const TextStyle(color: Colors.white)),
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
                    }).toList(),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _durasiController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Durasi (jam)',
                          labelStyle: TextStyle(color: Colors.white70)),
                      style: const TextStyle(color: Colors.white),
                      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _hargaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Harga Promo',
                          labelStyle: TextStyle(color: Colors.white70)),
                      style: const TextStyle(color: Colors.white),
                      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                        onPressed: _submit,
                        child: Text(editId != null ? 'Update Promo' : 'Simpan Promo'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
