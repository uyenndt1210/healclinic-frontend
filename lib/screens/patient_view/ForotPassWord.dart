import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Hàm xử lý gửi OTP
  void _handleSendOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      Fluttertoast.showToast(msg: "Vui lòng nhập số điện thoại");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Lấy danh sách user
      final users = await _authService.getUsers();

      for (var user in users) {
        print(user['phone']);
      }

      print(users.first);

      // 2. Kiểm tra an toàn: Nếu danh sách rỗng
      if (users.isEmpty) {
        setState(() => _isLoading = false);
        Fluttertoast.showToast(msg: "Số điện thoại chưa được đăng ký");
        return;
      }

      // 3. Kiểm tra số điện thoại (Hỗ trợ cả phone và Phone)
      final isExist = users.any((user) {
        final userPhone = (user['phone'] ?? user['Phone'] ?? "").toString().trim();
        return userPhone == phone;
      });

      if (!isExist) {
        setState(() => _isLoading = false);
        Fluttertoast.showToast(msg: "Số điện thoại chưa được đăng ký");
        return;
      }

      // 4. Nếu tồn tại thì gửi OTP
      final success = await _authService.sendOtp(phone);

      if (success) {
        Fluttertoast.showToast(msg: "Mã OTP đã được gửi!");
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/otp',
            arguments: {
              'phone': phone,
              'fullName': '',
            },
          );
        }
      } else {
        Fluttertoast.showToast(msg: "Gửi OTP thất bại");
      }
    } catch (e) {
      print("Lỗi ForgotPassword: $e");
      Fluttertoast.showToast(msg: "Lỗi kết nối máy chủ");
    } finally {
      // Đảm bảo luôn tắt loading kể cả khi có lỗi xảy ra
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text("Quên mật khẩu"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Đặt lại mật khẩu",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2E44),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Nhập số điện thoại của bạn để nhận mã xác thực (OTP) thiết lập lại mật khẩu mới.",
              style: TextStyle(fontSize: 15, color: Color(0xFF4A6580), height: 1.5),
            ),
            const SizedBox(height: 40),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFF1A73C8)),
                hintText: "Số điện thoại của bạn",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF1A73C8), width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73C8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Gửi mã xác nhận",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}