import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:5257/api/Auth';

  Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5257/api/User'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return [];
  }

  Future<bool> sendOtp(String phone) async {
    print("🔥 Gọi API send-otp với phone: $phone");
    print("URL: $baseUrl/send-otp");

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      ).timeout(const Duration(seconds: 10));

      print("Status code: ${response.statusCode}");
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
      await prefs.setInt('userId', data['userId']);
      await prefs.setString('fullName', data['fullName']);
      await prefs.setString('token', data['token']);
      await prefs.setString('role', data['role']);

      return true;
    }

    return false;
  }

  //=======================
  //LOG OT
  //=======================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('fullName');
    await prefs.remove('userId');
  }

  //====================
  //CHANGE PASSWORD
  //====================

  Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Essential for authentication
        },
        body: jsonEncode({
          'CurrentPassword': oldPassword,
          'NewPassword': newPassword,
        }),
      );

      print("URL: $baseUrl");
      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
      print("New password: $newPassword");
      print("Old password: $oldPassword");

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Có lỗi xảy ra',
      };
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  //========================================================
  //FORGOT PASWORD
  //========================================================
  Future<bool> resetPassword(
      String phone,
      String newPassword,
      ) async {

    try {

      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'newPassword': newPassword,
        }),
      );

      print(response.body);

      return response.statusCode == 200;

    } catch (e) {

      print(e);

      return false;
    }
  }

  //==========================================================
  //ChangPhone
  //==========================================================

  Future<Map<String, dynamic>> changePhone(
      String currentPassword,
      String newPhone,
      ) async {

    try {

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/change-phone'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPhone': newPhone,
        }),
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': data['message'],
      };

    } catch (e) {

      return {
        'success': false,
        'message': e.toString(),
      };

    }
  }

  //===========================================
  //CHECKPASSWORD
  //===========================================
  Future<bool> checkPassword(String password) async {

    try {

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.post(
        Uri.parse("$baseUrl/checkpassword"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "pass": password,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }

      return false;

    } catch (e) {

      print("Lỗi checkPassword: $e");
      return false;

    }
  }

}