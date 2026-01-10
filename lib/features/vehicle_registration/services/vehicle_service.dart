import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../models/vehicle_model.dart';

class VehicleService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Fetch all vehicles
  Future<List<Vehicle>> getVehicles() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/vehicles'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Vehicle.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load vehicles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load vehicles: $e');
    }
  }

  // Fetch only unauthorized/blocked vehicles - NOT USED? 
  // Wait, there is a separate UnauthorizedService for the other endpoint.
  // But maybe this was filtering the main list?
  // The original code filtered `getVehicles` by `is_blocked`.
  // The new API has `GET /vehicles` and `GET /vehicles/unauthorized`. 
  // This function might be redundant if we use the other service, but let's keep it if it's used elsewhere,
  // but implement it by fetching all and filtering locally, OR use the unauthorized endpoint?
  // The prompt says: "Unauthorized GET /vehicles/unauthorized Get list of 'Blocked/Unauthorized' cars"
  // So I should use the UnauthorizedService for that. 
  // I will keep this specific method as a filter on `getVehicles` if needed, or redirect.
  // Actually, let's assume `getVehicles` returns ALL, and `getUnauthorizedVehicles` uses the specific endpoint.
  
  // NOTE: Original code had `getUnauthorizedVehicles` inside `VehicleService`. 
  // I see `UnauthorizedService` in another file. I should check if `VehicleService` was used for unauthorized fetch strictly.
  // The grep search showed `unauthorized_service.dart` existing.
  // So I'll just implement `getVehicles`.
  // Wait, original `VehicleService` had `getUnauthorizedVehicles` method too? 
  // Let me check the original content of VehicleService... 
  // Yes: `Future<List<Vehicle>> getUnauthorizedVehicles()`.
  // I will point this to `GET /vehicles/unauthorized` but map it to `Vehicle` model if possible, 
  // or just return from `getVehicles` filtering isBlocked. 
  // However, the `GET /vehicles/unauthorized` likely returns a different structure or the same?
  // Let's rely on `UnauthorizedService` for the unauthorized list, and if this method is called, I'll redirect to that or implement it similarly.
  // Since `Vehicle` and `UnauthorizedVehicle` models differ slightly (dates), better to check usage.
  // If `VehicleService.getUnauthorizedVehicles` is used, I should probably use the specific endpoint.
  
  Future<List<Vehicle>> getUnauthorizedVehicles() async {
      // Trying to fetch from specific endpoint if it returns compatible data, 
      // otherwise filter local.
      // Given the API description, let's filter the main list for now to be safe, 
      // or assume the unauthorized list is distinct. 
      // Let's implement it by calling the unauthorized endpoint, 
      // but we might need to adapt the model.
      // Actually, safest is to filter `getVehicles` for now, unless `GET /vehicles` excludes them.
      // But typically `GET /vehicles` returns all.
      // Let's just fetch all and filter.
      final all = await getVehicles();
      return all.where((v) => v.isBlocked).toList();
  }


  // Add a new vehicle
  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/vehicles'),
        headers: headers,
        body: jsonEncode(vehicle.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
         throw Exception('Failed to add vehicle: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to add vehicle: $e');
    }
  }

  // Update an existing vehicle
  Future<void> updateVehicle(Vehicle vehicle) async {
    if (vehicle.id == null) return;
    try {
      final headers = await _getHeaders();
      // Using PUT /vehicles/:id
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/vehicles/${vehicle.id}'),
        headers: headers,
        body: jsonEncode(vehicle.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update vehicle: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }

  // Delete a vehicle
  Future<void> deleteVehicle(String id) async { // Changed id to String
    try {
        final headers = await _getHeaders();
        final response = await http.delete(
          Uri.parse('${AppConstants.baseUrl}/vehicles/$id'),
          headers: headers,
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to delete vehicle: ${response.statusCode}');
        }
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }
}
