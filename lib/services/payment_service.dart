import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentHistoryService {
  final String baseUrl = "http://10.0.2.2:5257/api";

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  /// Lấy danh sách hóa đơn từ PaymentController thông qua UserId
  Future<List<dynamic>> getPaymentHistoryByType(String type) async {
    try {
      final headers = await _getHeaders();
      final prefs = await SharedPreferences.getInstance();

      // Lấy trực tiếp userId (Key này tài khoản nào đăng nhập cũng đã có sẵn và chuẩn 100%)
      final int currentUserId = prefs.getInt("userId") ?? 0;

      print("DEBUG: Đang gọi danh sách hóa đơn cho UserId = $currentUserId");
      if (currentUserId == 0) {
        print("CẢNH BÁO: Không tìm thấy userId trên thiết bị.");
        return [];
      }

      // ĐỔI ROUTE: Gọi sang đầu /user/$currentUserId mới viết ở Backend
      final response = await http.get(

          Uri.parse('$baseUrl/Payment/user/$currentUserId'),
          headers: headers
      );
      print("RAW RESPONSE:");
      print(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> allPayments = jsonDecode(response.body);
        print("DEBUG: Tải thành công ${allPayments.length} hóa đơn từ UserId!");

        print(allPayments);

        // Phân phối danh sách vào các Tab dựa theo trường "paymentType" trong DB
        if (type == 'dat_lich') {
          return allPayments.where((item) => item['paymentType'] == 'Đặt lịch').toList();
        }
        else if (type == 'thuoc') {
          return allPayments.where((item) => item['paymentType'] == 'Đơn thuốc').toList();
        }
        else if (type == 'dich_vu') {
          return allPayments.where((item) => item['paymentType'] == 'Dịch vụ').toList();
        }
      }
      return [];
    } catch (e) {
      print("Lỗi kết nối API Payment Service ($type): $e");
      return [];
    }
  }

  /// Lấy danh sách các hóa đơn CHƯA thanh toán của User hiện tại
  Future<List<dynamic>> getUnpaidPayments() async {
    try {
      final headers = await _getHeaders();
      final prefs = await SharedPreferences.getInstance();
      final int currentUserId = prefs.getInt("userId") ?? 0;

      if (currentUserId == 0) return [];

      final response = await http.get(
          Uri.parse('$baseUrl/Payment/unpaid/user/$currentUserId'),
          headers: headers
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Lỗi kết nối API lấy hóa đơn chưa thanh toán: $e");
      return [];
    }
  }

  /// Gọi API cập nhật trạng thái hóa đơn sang Đã thanh toán
  Future<bool> updatePaymentToPaid(int paymentId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
          Uri.parse('$baseUrl/Payment/confirm-paid/$paymentId'),
          headers: headers
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi khi gọi API confirm-paid: $e");
      return false;
    }
  }

  Future<String?> getPaymentStatus(int paymentId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/Payment/status/$paymentId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'];
      }

      return null;
    } catch (e) {
      print("Lỗi lấy trạng thái hóa đơn: $e");
      return null;
    }
  }

}