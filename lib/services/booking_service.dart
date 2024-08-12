import 'dart:convert';
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
    required double harga,
    required String foto_base64,
    required voucher_id, // voucher_id sekarang opsional
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/lapangan/book'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'pengguna_id': pengguna_id,
        'lapangan_id': lapangan_id,
        'jenis_lapangan_id': jenis_lapangan_id,
        'tanggal_booking': tanggal_booking,
        'tanggal_penggunaan': tanggal_penggunaan,
        'sesi': sesi,
        'harga': harga,
        'foto_base64': foto_base64,
        'voucher_id': voucher_id, // Kirim voucher_id jika ada
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

  // Method untuk mengecek voucher code
  static Future<Map<String, dynamic>> checkVoucherCode(
      String voucherCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/voucher/check'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'voucher_code': voucherCode,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to check voucher code');
    }
  }

  // Method untuk mengklaim voucher
  static Future<void> claimVoucher({
    required String voucherCode,
    required int penggunaId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/voucher/klaim'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'voucher_code': voucherCode,
        'pengguna_id': penggunaId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to claim voucher');
    }
  }
}
