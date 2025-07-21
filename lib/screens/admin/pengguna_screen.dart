import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/supabase_service.dart';
import 'admin_sidebar.dart';

class PenggunaScreen extends StatefulWidget {
  const PenggunaScreen({super.key});

  @override
  State<PenggunaScreen> createState() => _PenggunaScreenState();
}

class _PenggunaScreenState extends State<PenggunaScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  final Color backgroundColor = Colors.black;
  final Color goldColor = const Color(0xFFFFD700);
  final TextStyle goldTextStyle = const TextStyle(color: Color(0xFFFFD700));

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabaseService.getAll('profiles');
      setState(() {
        _users = data;
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data pengguna: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          const AdminSidebar(),
          Expanded(
            child: Scaffold(
              backgroundColor: backgroundColor,
              appBar: AppBar(
                backgroundColor: backgroundColor,
                title: Text('Daftar Pengguna', style: TextStyle(color: goldColor)),
                automaticallyImplyLeading: false,
                iconTheme: IconThemeData(color: goldColor),
              ),
              body: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
                  : _users.isEmpty
                      ? Center(
                          child: Text(
                            'Belum ada data pengguna.',
                            style: goldTextStyle.copyWith(fontSize: 16),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(Colors.grey.shade900),
                            dataRowColor: WidgetStateProperty.all(Colors.black),
                            dividerThickness: 0.8,
                            columnSpacing: 24,
                            columns: const [
                              DataColumn(label: Text('No.', style: TextStyle(color: Color(0xFFFFD700)))),
                              DataColumn(label: Text('ID', style: TextStyle(color: Color(0xFFFFD700)))),
                              DataColumn(label: Text('Username', style: TextStyle(color: Color(0xFFFFD700)))),
                            ],
                            rows: List.generate(_users.length, (index) {
                              final user = _users[index];
                              return DataRow(
                                cells: [
                                  DataCell(Text('${index + 1}', style: goldTextStyle)),
                                  DataCell(Text(user['id'] ?? '-', style: goldTextStyle)),
                                  DataCell(Text(user['username'] ?? '-', style: goldTextStyle)),
                                ],
                              );
                            }),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
