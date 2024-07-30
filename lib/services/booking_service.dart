// lib/services/api_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/jenis_lapangan.dart';
import '../models/lapangan.dart';
import '../global/url.dart';

class ApiService {
  // Method untuk fetch jenis lapangan dari API
  static Future<List<JenisLapangan>> fetchJenisLapangan() async {
    final response = await http.get(Uri.parse('$baseUrl/lapangan/all'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      List<JenisLapangan> jenisLapangans =
          jsonList.map((json) => JenisLapangan.fromJson(json)).toList();
      return jenisLapangans;
    } else {
      throw Exception('Failed to load jenis lapangan');
    }
  }

  // Method untuk melakukan booking lapangan
  static Future<void> bookField({
    required int pengguna_id,
    required int lapangan_id,
    required int jenis_lapangan_id,
    required String tanggal_booking,
    required String tanggal_penggunaan,
    required String sesi,
    required String foto_base64,
    required double harga,
  }) async {
    final url = Uri.parse('$baseUrl/lapangan/book');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'pengguna_id': pengguna_id,
        'lapangan_id': lapangan_id,
        'jenis_lapangan_id': jenis_lapangan_id,
        'tanggal_booking': tanggal_booking,
        'tanggal_penggunaan': tanggal_penggunaan,
        'sesi': sesi,
        'foto_base64': foto_base64,
        'harga': harga,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create booking');
    }
  }

  // Method untuk mengecek ketersediaan lapangan
  static Future<List<Lapangan>> fetchAvailableLapangan(
      int jenisLapanganId, String tanggalPenggunaan, String sesi) async {
    final url = Uri.parse('$baseUrl/lapangan/available');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'jenis_lapangan_id': jenisLapanganId,
      'tanggal_penggunaan': tanggalPenggunaan,
      'sesi': sesi,
    });

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      List<Lapangan> lapangans =
          jsonList.map((json) => Lapangan.fromJson(json)).toList();
      return lapangans;
    } else {
      throw Exception('Failed to fetch available lapangan');
    }
  }
}
