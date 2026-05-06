import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.16:5098/api/auth';

  Future<bool> sendOtp(String phone) async {
    print("🔥 Gọi API send-otp với phone: $phone");
    print("URL: $baseUrl/send-otp");

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      ).timeout(const Duration(seconds: 10));   // giới hạn 10 giây

      print("✅ Status code: ${response.statusCode}");
      print("Body response: ${response.body}");

      if (response.statusCode == 200) {
        print("Gửi OTP thành công!");
        return true;
      } else {
        print("Lỗi server: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ LỖI KẾT NỐI: $e");
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );
    return response.statusCode == 200;
  }

  Future<bool> register(String phone, String password, String fullName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'password': password,
        'fullName': fullName,
        'role': 'Patient'
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('role', data['role']);
      return true;
    }
    return false;
  }

  Future<bool> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('role', data['role']);
      return true;
    }
    return false;
  }
}