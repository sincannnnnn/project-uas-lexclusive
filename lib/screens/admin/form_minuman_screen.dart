import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_input_field.dart';

class FormMinumanScreen extends StatefulWidget {
  const FormMinumanScreen({super.key});

  @override
  State<FormMinumanScreen> createState() => _FormMinumanScreenState();
}

class _FormMinumanScreenState extends State<FormMinumanScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();

  Map<String, dynamic>? _existingMinuman;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (Get.arguments is Map<String, dynamic>) {
      _existingMinuman = Get.arguments as Map<String, dynamic>;
      _namaController.text = _existingMinuman!['nama'] ?? '';
      _hargaController.text = _existingMinuman!['harga'].toString();
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final data = {
          'nama': _namaController.text,
          'harga': int.tryParse(_hargaController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        };

        if (_existingMinuman != null) {
          await _supabaseService.updateRow('minuman', data, _existingMinuman!['id']);
        } else {
          await _supabaseService.insertRow('minuman', data);
        }

        Get.back(result: true);
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal menyimpan minuman: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_existingMinuman == null ? 'Tambah Minuman' : 'Edit Minuman')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomInputField(
                controller: _namaController,
                labelText: 'Nama Minuman',
                validator: (value) => value!.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _hargaController,
                labelText: 'Harga (Rp)',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value!.isEmpty ? 'Harga wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}