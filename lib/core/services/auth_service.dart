import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Login
  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/auth/login');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        // The API might return user details, but based on docs it returns a token.
        // We'll store the token.
         
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, token);
          // Store dummy user data if API doesn't provide it, just to have something
          await prefs.setString(_userKey, username); 
        } else {
             throw Exception('Token not found in response');
        }

      } else {
         final errorData = jsonDecode(response.body);
         throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Logout
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }

  // Get Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}
