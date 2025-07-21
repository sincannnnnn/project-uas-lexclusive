import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ------------------------ Upload Gambar ------------------------

  Future<String> uploadImage(
    File file,
    String fileName,
    String bucketName,
  ) async {
    final bytes = await file.readAsBytes();
    await supabase.storage.from(bucketName).uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
    );
    return supabase.storage.from(bucketName).getPublicUrl(fileName);
  }

  Future<String> uploadImageBytes(
    Uint8List bytes,
    String fileName,
    String bucketName,
  ) async {
    await supabase.storage.from(bucketName).uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
    );
    return supabase.storage.from(bucketName).getPublicUrl(fileName);
  }

  // ------------------------ Profiles ------------------------

  Future<Map<String, dynamic>?> getProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;
    return await supabase.from('profiles').select().eq('id', userId).single();
  }

  Future<void> updateProfile({
    required String username,
    String? avatarUrl,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    await supabase.from('profiles').upsert({
      'id': userId,
      'username': username,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ------------------------ Generic CRUD ------------------------

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final data = await supabase
        .from(table)
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> insertRow(String table, Map<String, dynamic> data) async {
    await supabase.from(table).insert(data);
  }

  Future<void> updateRow(
      String table, Map<String, dynamic> data, String id) async {
    await supabase.from(table).update(data).eq('id', id);
  }

  Future<void> deleteRow(String table, String idField, String id) async {
    await supabase.from(table).delete().eq(idField, id);
  }

  Future<void> insert(String table, Map<String, dynamic> data) async {
    await supabase.from(table).insert(data);
  }

  Future<void> delete(String table, String id) async {
    await supabase.from(table).delete().match({'id': id});
  }

  // ------------------------ Reservasi Karaoke ------------------------

  Future<List<Map<String, dynamic>>> getMinumanList() async {
    final res = await supabase.from('minuman').select();
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<String>> getJamTerpakai(String kamarId) async {
    final res = await supabase
        .from('reservasi')
        .select('jam')
        .eq('kamar_id', kamarId)
        .inFilter('status', ['pending', 'acc']);
    final List jamData = res;
    final List<String> allJam = [];
    for (var row in jamData) {
      if (row['jam'] != null) {
        final List jamList = row['jam'];
        for (var j in jamList) {
          allJam.add(j.toString());
        }
      }
    }
    return allJam;
  }

  Future<void> buatReservasi({
    required String nama,
    required String telp,
    required List<String> jam,
    required bool lc,
    required List<Map<String, dynamic>> minumanDipilih,
    required String kamarId,
    required int total,
    String tipe = 'kamar',
    String? namaPromo,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase.from('reservasi').insert({
      'user_id': userId,
      'kamar_id': kamarId,
      'nama': nama,
      'telp': telp,
      'jam': jam,
      'durasi': jam.length,
      'lc': lc,
      'minuman': minumanDipilih,
      'harga_minum': [],
      'harga_total': total,
      'status': 'belum bayar',
      'tipe': tipe,
      if (namaPromo != null) 'nama_promo': namaPromo,
    });
  }

  Future<List<Map<String, dynamic>>> getReservasiByUser() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final res = await supabase
        .from('reservasi')
        .select('*, kamar(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getReservasiPending() async {
    final res = await supabase
        .from('reservasi')
        .select('*, kamar(*)')
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> verifikasiReservasi(String reservasiId) async {
    await supabase
        .from('reservasi')
        .update({'status': 'acc'}).eq('id', reservasiId);
  }
}
