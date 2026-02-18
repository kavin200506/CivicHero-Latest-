import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class NominatimService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  // Search for a location by query string
  Future<List<Map<String, dynamic>>> search(String query) async {
    final url = Uri.parse('$_baseUrl/search?q=$query&format=json&addressdetails=1&limit=5');
    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'com.civichero.admin', // Identify your app
      });

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        print('Failed to search location: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error searching location: $e');
      return [];
    }
  }

  // Reverse geocode a location (lat, lon) to get address
  Future<Map<String, dynamic>?> reverse(double lat, double lon) async {
    final url = Uri.parse('$_baseUrl/reverse?lat=$lat&lon=$lon&format=json&addressdetails=1');
    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'com.civichero.admin',
      });

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(response.body));
      } else {
        print('Failed to reverse geocode: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
      return null;
    }
  }
}
