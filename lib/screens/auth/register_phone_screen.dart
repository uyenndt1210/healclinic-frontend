import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/auth_service.dart';

class RegisterPhoneScreen extends StatefulWidget {
  const RegisterPhoneScreen({super.key});

  @override
  State<RegisterPhoneScreen> createState() => _RegisterPhoneScreenState();
}

class _RegisterPhoneScreenState extends State<RegisterPhoneScreen> {
  final _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _agree = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng ký"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chào mừng đến với\nHEAL CLINIC",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
            ),
            const SizedBox(height: 8),
            Text(
              "Tạo tài khoản mới",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 40),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone_android, color: Color(0xFF00AEEF)),
                hintText: "Nhập số điện thoại",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Checkbox(
                  value: _agree,
                  activeColor: const Color(0xFF00AEEF),
                  onChanged: (value) => setState(() => _agree = value!),
                ),
                const Expanded(
                  child: Text(
                    "Tôi đồng ý với Điều khoản dịch vụ và Chính sách bảo mật",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading || !_agree || _phoneController.text.isEmpty
                    ? null
                    : () async {
                  setState(() => _isLoading = true);

                  try {
                    final success = await _authService.sendOtp(_phoneController.text);

                    if (success) {
                      Fluttertoast.showToast(msg: "Mã OTP đã được gửi!");
                      Navigator.pushNamed(context, '/otp', arguments: _phoneController.text);
                    } else {
                      Fluttertoast.showToast(msg: "Gửi OTP thất bại");
                    }
                  } catch (e) {
                    Fluttertoast.showToast(msg: "Lỗi: $e");
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AEEF),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Tiếp tục", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text("Đã có tài khoản? Đăng nhập", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}