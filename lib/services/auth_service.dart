import 'dart:convert';
import 'package:client_front/models/user.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'http://localhost:3000/auth';

  Future<User?> login(String username, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/login');
      print('URL: $url');

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
        Uri.parse('$_baseUrl/pengguna/${updatedUser.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updatedUser.toJson()),
      );

      print('Update Profile Response status: ${response.statusCode}');
      print('Update Profile Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse the response body
        final responseData = jsonDecode(response.body);

        // Check if responseData contains 'data' field
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
}
