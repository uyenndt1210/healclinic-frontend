import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookingService {
  final String baseUrl = "http://10.0.2.2:5257/api";

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> getSpecialties() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$baseUrl/Specialty'), headers: headers);
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCurrentPatientInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId") ?? 0;
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$baseUrl/User/$userId'), headers: headers);
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        if (userData['patients'] != null && (userData['patients'] as List).isNotEmpty) {
          return userData['patients'][0] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>> getDoctorsBySpecialty(String specialtyId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/Doctor/specialty/${specialtyId.trim()}'),
        headers: headers,
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createAppointment({
    required int patientId,
    required int doctorId,
    required String specialtyId,
    required DateTime date,
    required String timeSlot,
    required bool isCover,
    required double price,
  }) async {
    final headers = await _getHeaders();

    // ĐỒNG BỘ CHUẨN: Toàn bộ Key viết thường chữ cái đầu (camelCase) gửi lên API
    final Map<String, dynamic> bodyData = {
      "patientId": patientId,
      "doctorId": doctorId,
      "specialtyId": specialtyId.trim(),
      "appointmentDate": date.toIso8601String(),
      "timeExpected": timeSlot.split(':').length == 2 ? "$timeSlot:00" : timeSlot,
      "isCover": isCover,
      "price": price,
      "note": "Đặt lịch trực tuyến theo ca trực bác sĩ",
      "status": "Chờ khám"
    };

    final response = await http.post(
      Uri.parse('$baseUrl/Appointment'),
      headers: headers,
      body: jsonEncode(bodyData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      print("API Error Body: ${response.body}");
      try {
        final errorData = jsonDecode(response.body);
        String msg = errorData['message'] ?? "Lỗi cú pháp dữ liệu đầu vào";
        throw Exception(msg);
      } catch (e) {
        throw Exception("Lỗi hệ thống (Status: ${response.statusCode})");
      }
    }
  }
}
