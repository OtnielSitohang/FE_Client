import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiResponse {
  final Status status;
  final dynamic data;
  final String message;

  ApiResponse(this.status, {this.data, required this.message});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      Status.SUCCESS,
      data: json['data'],
      message: json['message'],
    );
  }

  factory ApiResponse.error(String message) {
    return ApiResponse(Status.ERROR, message: message);
  }
}

enum Status { SUCCESS, ERROR }

class UbahPasswordService {
  static const String baseUrl =
      'http://localhost:3000/auth'; // Ganti dengan URL backend Anda

  Future<ApiResponse> ubahPassword(
      int userId, String oldPassword, String newPassword) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/ubahPassword/$userId'),
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(jsonDecode(response.body));
      } else {
        return ApiResponse.error('Failed to change password');
      }
    } catch (e) {
      return ApiResponse.error('Exception occurred: $e');
    }
  }
}
