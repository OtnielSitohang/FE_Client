import 'dart:convert';
import 'package:client_front/models/user.dart';
import 'package:client_front/utils/DateUtils.dart';
import 'package:http/http.dart' as http;
import '../global/url.dart';

class AuthService {
  Future<User?> login(String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      final response = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          return User.fromJson(data['data']);
        } else {
          throw Exception('Invalid response: Data not complete');
        }
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during login: $e');
      throw Exception('Failed to login: $e');
    }
  }

  Future<Map<String, dynamic>?> updateProfile(User updatedUser) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/pengguna/${updatedUser.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'foto_base64': updatedUser.foto_base64,
          'email': updatedUser.email,
          'tempat_tinggal': updatedUser.tempat_tinggal,
          'tanggal_lahir': DateUtils.formatDateTime(updatedUser.tanggal_lahir),
        }),
      );

      print('Update Profile Response status: ${response.statusCode}');
      print('Update Profile Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['data'] != null) {
          return responseData['data'];
        } else {
          throw Exception('Failed to update profile: Data not complete');
        }
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> register(
    String username,
    String password,
    String namaLengkap,
    String email,
    String tempatTinggal,
    DateTime tanggalLahir,
  ) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
        'nama_lengkap': namaLengkap,
        'email': email,
        'tempat_tinggal': tempatTinggal,
        'tanggal_lahir': tanggalLahir.toIso8601String(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to register');
    }
  }
}
