import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';

class DashboardService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET /dashboard/stats
  Future<Map<String, dynamic>> getStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/dashboard/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load stats: $e');
    }
  }

  // GET /dashboard/graph
  Future<List<dynamic>> getGraphData() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/dashboard/graph'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Assuming it returns a list of data points
        final data = jsonDecode(response.body);
        if (data is List) return data;
        // If it's wrapped in an object
        return []; 
      } else {
        throw Exception('Failed to load graph data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load graph data: $e');
    }
  }

  // GET /reports
  Future<List<dynamic>> getRecentActivity() async {
    try {
      final headers = await _getHeaders();
      final now = DateTime.now();
      // Fetch for last 7 days
      final from = now.subtract(const Duration(days: 7)).toIso8601String().split('T')[0];
      final to = now.toIso8601String().split('T')[0];
      
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/reports?from=$from&to=$to'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) return data;
        return [];
      } else {
        return []; 
      }
    } catch (e) {
      return [];
    }
  }
}
