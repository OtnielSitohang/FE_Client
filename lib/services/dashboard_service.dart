import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardService {
  final String baseUrl;

  DashboardService(this.baseUrl);

  Future<Map<String, dynamic>> fetchBookings(int userId) async {
    final url = '$baseUrl/bookings/$userId'; 
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      throw Exception('Failed to load bookings: $e');
    }
  }
}
