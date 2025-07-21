import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import '../../main.dart';
import '../home/menu.dart';
import '../home/user_sidebar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _kamarList = [];
  List<Map<String, dynamic>> _promoList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final kamarData = await _supabaseService.getAll('kamar');
      final promoData = await supabase
          .from('promo')
          .select('*, kamar:kamar_id(id, nama, gambar_url), minuman')
          .order('created_at', ascending: false);

      setState(() {
        _kamarList = kamarData;
        _promoList = List<Map<String, dynamic>>.from(promoData);
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
      setState(() => _isLoading = false);
    }
  }

  void _refreshProfile() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Image.asset('assets/images/logo.png', width: 130),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.amber),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: UserSidebar(
        onProfileUpdated: _refreshProfile,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('View Room',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _kamarList.isEmpty
                      ? const Center(
                          child: Text("Tidak ada kamar tersedia",
                              style: TextStyle(color: Colors.white)),
                        )
                      : SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _kamarList.length,
                            itemBuilder: (context, index) {
                              final kamar = _kamarList[index];
                              return GestureDetector(
                                onTap: () => Get.toNamed(
                                  AppRoutes.detailKamar,
                                  arguments: kamar,
                                ),
                                child: roomCard(
                                  imageUrl: kamar['gambar_url'] ?? '',
                                  namaKamar: kamar['nama'] ?? '',
                                  tipeKamar: kamar['tipe'] ?? '',
                                  harga: (kamar['harga'] as num?)?.toInt() ?? 0,
                                ),
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 24),
                  const Text('Promo',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _promoList.isEmpty
                      ? const Text("Belum ada promo tersedia",
                          style: TextStyle(color: Colors.white))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _promoList.map((promo) {
                              return GestureDetector(
                                onTap: () => Get.toNamed(
                                  AppRoutes.detailPromo,
                                  arguments: promo,
                                ),
                                child: promoCard(promo),
                              );
                            }).toList(),
                          ),
                        ),
                ],
              ),
            ),
      bottomNavigationBar: Menu(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Get.offAllNamed(AppRoutes.notifikasi);
          } else if (index == 2) {
            Get.offAllNamed(AppRoutes.riwayat);
          }
        },
      ),
    );
  }

  Widget roomCard({
    required String imageUrl,
    required String namaKamar,
    required String tipeKamar,
    required int harga,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: imageUrl.startsWith('http')
              ? NetworkImage(imageUrl)
              : const AssetImage('assets/images/default_room.jpg')
                  as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tipeKamar,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              Text(namaKamar,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const Text('Room',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              Text('Rp $harga',
                  style: const TextStyle(color: Color(0xFFD9A441))),
            ],
          ),
        ),
      ),
    );
  }

  Widget promoCard(Map<String, dynamic> promo) {
    final kamar = promo['kamar'];
    final imageUrl = kamar?['gambar_url'] ?? '';
    final namaPromo = promo['nama'] ?? 'Promo';
    final namaKamar = kamar?['nama'] ?? '';
    final harga = promo['harga'] ?? 0;
    final durasi = promo['durasi'] ?? 0;
    final lc = promo['lc'] == true;
    final minumanList = promo['minuman'] as List<dynamic>?;

    List<String> itemList = [];

    itemList.add('$namaKamar Room');

    if (minumanList != null && minumanList.isNotEmpty) {
      itemList.add('+ Minuman');
    }

    if (lc) {
      itemList.add('+ LC');
    }

    itemList.add('Durasi $durasi jam');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      width: 360,
      height: 170,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 130,
            height: 160,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: imageUrl.startsWith('http')
                    ? NetworkImage(imageUrl)
                    : const AssetImage('assets/images/default_room.jpg')
                        as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(namaKamar,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const Text('Room',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(namaPromo,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...List.generate(itemList.length, (index) {
                    return Text(
                      '${index + 1}. ${itemList[index]}',
                      style: const TextStyle(color: Colors.white70),
                    );
                  }),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'Rp.$harga',
                      style: const TextStyle(
                          color: Color(0xFFD9A441),
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
