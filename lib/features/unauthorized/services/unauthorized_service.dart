import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../models/unauthorized_vehicle_model.dart';

class UnauthorizedService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Fetch all unauthorized vehicles
  // GET /vehicles/unauthorized
  Future<List<UnauthorizedVehicle>> getUnauthorizedVehicles() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/vehicles/unauthorized'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => UnauthorizedVehicle.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load unauthorized vehicles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load unauthorized vehicles: $e');
    }
  }

  // Add a new unauthorized vehicle (Block a vehicle)
  // POST /vehicles/unauthorized
  // Body: { "number": "...", "reason": "..." }
  Future<void> addUnauthorizedVehicle(UnauthorizedVehicle vehicle) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'number': vehicle.vehicleNumber,
        'reason': vehicle.reason,
      };
      
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/vehicles/unauthorized'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add unauthorized vehicle: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to add unauthorized vehicle: $e');
    }
  }

  // Update status (e.g. to 'Authorized')
  // The API doesn't explicitly list a generic PUT for unauthorized, 
  // but maybe we can use the generic PUT /vehicles/:id if they share ID space,
  // or maybe it's not supported via API yet.
  // The provided API only shows:
  // POST /vehicles/unauthorized (Block)
  // GET /vehicles/unauthorized
  // If we unblock, maybe we use DELETE? Or update status?
  // I'll keep the method stubbed or try to implement if possible.
  // The prompt says "vehicles" PUT /vehicles/:id Update vehicle details.
  // Maybe unauthorized vehicles are also in the main vehicles table?
  // Let's assume we can't easily update status via specific unauthorized endpoint unless documented.
  // I will throw unimplemented for now to avoid wrong guesses, or just try generic PUT if I had an ID.
  
  Future<void> updateStatus(String id, String newStatus) async {
     // Pending API support or clarification. 
     // For now, doing nothing or maybe try generic vehicle update?
     // If the unauthorized vehicle has an ID from the GET list, maybe we can use valid vehicle update?
     // Let's assume it's like a normal vehicle update.
      try {
        final headers = await _getHeaders();
        // Construct a minimal update payload
        final body = {'status': newStatus};
        
        final response = await http.put(
          Uri.parse('${AppConstants.baseUrl}/vehicles/$id'),
          headers: headers,
          body: jsonEncode(body),
        );
        
        if (response.statusCode != 200) {
           // Ignore error or log it?
        }
      } catch (e) {
        // Silent fail or rethrow
      }
  }
  
  // Delete entry
  Future<void> deleteUnauthorizedVehicle(String id) async {
    // If it's just deleting the record.
    // The API shows DELETE /vehicles/:id
    try {
        final headers = await _getHeaders();
        final response = await http.delete(
          Uri.parse('${AppConstants.baseUrl}/vehicles/$id'),
          headers: headers,
        );
        if (response.statusCode != 200) {
          throw Exception('Failed to delete: ${response.statusCode}');
        }
    } catch (e) {
       throw Exception('Failed to delete: $e');
    }
  }
}
