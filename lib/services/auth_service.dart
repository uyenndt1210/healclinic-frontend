import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:5257/api/Auth';

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

  Future<bool> register(
      String phone,
      String password,
      String fullName,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'password': password,
          'fullName': fullName,
          'role': 'P',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        // Lưu token
        await prefs.setString('token', data['token']);

        // Lưu role
        await prefs.setString('role', data['role']);

        // Lưu tên người dùng
        await prefs.setString('fullName', data['fullName']);

        return true;
      } else {
        print('Register failed: ${data['message']}');
        return false;
      }
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }


  Future<bool> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'password': password,
      }),
    );

    print("URL: $baseUrl");
    print("Phone: $phone");
    print("Password: $password");
    print("Status code: ${response.statusCode}");
    print("Response body: ${response.body}");

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