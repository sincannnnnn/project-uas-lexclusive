import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import '../../widgets/custom_input_field.dart';

class FormKamarScreen extends StatefulWidget {
  const FormKamarScreen({super.key});

  @override
  State<FormKamarScreen> createState() => _FormKamarScreenState();
}

class _FormKamarScreenState extends State<FormKamarScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _deskripsiController = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _existingKamar;
  XFile? _imageFile;
  String? _existingImageUrl;
  String? _kapasitasValue;

  @override
  void initState() {
    super.initState();
    if (Get.arguments is Map<String, dynamic>) {
      _existingKamar = Get.arguments as Map<String, dynamic>;
      _namaController.text = _existingKamar!['nama'] ?? '';
      _hargaController.text = _existingKamar!['harga'].toString();
      _deskripsiController.text = _existingKamar!['deskripsi'] ?? '';
      _kapasitasValue = _existingKamar!['kapasitas']?.toString();
      _existingImageUrl = _existingKamar!['gambar_url'];
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  int _parseHarga(String text) {
    return int.tryParse(text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        String? imageUrl = _existingImageUrl;

        if (_imageFile != null) {
          final fileName = 'kamar_${DateTime.now().millisecondsSinceEpoch}.jpg';
          if (kIsWeb) {
            final bytes = await _imageFile!.readAsBytes();

            // ✅ URUTAN DIBENARKAN: bytes, fileName, 'kamar'
            imageUrl = await _supabaseService.uploadImageBytes(
              bytes,
              fileName,
              'kamar',
            );
          } else {
            final file = File(_imageFile!.path);
            imageUrl = await _supabaseService.uploadImage(
              file,
              fileName,
              'kamar',
            );
          }

          if (imageUrl == null) throw 'Upload gambar gagal';
        }

        final data = {
          'nama': _namaController.text,
          'kapasitas': _kapasitasValue,
          'harga': _parseHarga(_hargaController.text),
          'deskripsi': _deskripsiController.text,
          'gambar_url': imageUrl,
        };

        if (_existingKamar != null) {
          await _supabaseService.updateRow('kamar', data, _existingKamar!['id']);
        } else {
          await _supabaseService.insertRow('kamar', data);
        }

        Get.snackbar(
          'Sukses',
          'Kamar berhasil disimpan',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offNamed(AppRoutes.kamar);
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal menyimpan kamar: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_existingKamar == null ? 'Tambah Kamar' : 'Edit Kamar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _imageFile != null
                  ? (kIsWeb
                      ? Image.network(_imageFile!.path, height: 150, fit: BoxFit.cover)
                      : Image.file(File(_imageFile!.path), height: 150, fit: BoxFit.cover))
                  : (_existingImageUrl != null
                      ? Image.network(_existingImageUrl!, height: 150, fit: BoxFit.cover)
                      : Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 50, color: Colors.grey),
                        )),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pilih Gambar'),
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _namaController,
                labelText: 'Nama Kamar',
                validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _kapasitasValue,
                decoration: const InputDecoration(
                  labelText: 'Kapasitas',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: '6 orang', child: Text('6 orang')),
                  DropdownMenuItem(value: '12 orang', child: Text('12 orang')),
                ],
                onChanged: (value) => setState(() => _kapasitasValue = value),
                validator: (value) => value == null ? 'Pilih kapasitas' : null,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _hargaController,
                labelText: 'Harga',
                keyboardType: TextInputType.number,
                prefixText: 'Rp. ',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value!.isEmpty ? 'Harga tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _deskripsiController,
                labelText: 'Deskripsi',
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save),
                      label: Text(_existingKamar == null ? 'Simpan Kamar' : 'Update Kamar'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
