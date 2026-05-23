import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/user_service.dart';

class ChangPhoneScreen extends StatefulWidget {
  final String currentPhone;
  const ChangPhoneScreen({super.key, required this.currentPhone});

  @override
  State<ChangPhoneScreen> createState() => _ChangPhoneScreenState();
}

class _ChangPhoneScreenState extends State<ChangPhoneScreen> {

  Users? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId");
      final token = prefs.getString("token");

      print("User ID: " + userId.toString());
      print("Token: " + token!);

      if (userId == null || token == null) {
        throw Exception("Thông tin đăng nhập không hợp lệ");
      }

      final res = await http.get(
        Uri.parse('http://10.0.2.2:5257/api/User/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Bắt buộc phải có Token
        },
      );
      print("Data : \n" + res.body);


      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        final mappedUser = Users(
          UserId: data['userId'],
          Email: data['email'],
          PassWord: data['passWord'],
          Phone: data['phone'],
          Role: data['role'],
          CreatedAt: data['createdAt'] != null
              ? DateTime.parse(data['createdAt'])
              : DateTime.now(),

          UpdateAt: data['updateAt'] != null
              ? DateTime.parse(data['updateAt'])
              : DateTime.now(),
        );



        setState(() {
          // Sử dụng model Users hiện tại của bạn
          userProfile = Users.fromJson(data);
          print(userProfile?.Phone);
          print(userProfile?.Email);
          print(userProfile?.Role);
          isLoading = false;
        });
      } else {
        throw Exception('Lỗi server: ${res.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString()}")),
        );
      }
    }
  }

  final AuthService _authService = AuthService();
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Controllers
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPhoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _newPhoneController.dispose();
    _otpController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() => _currentStep++);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _verifyPassword() async {

    if (_passwordController.text.trim().isEmpty) {

      Fluttertoast.showToast(
        msg: "Vui lòng nhập mật khẩu",
      );

      return;
    }

    setState(() => _isLoading = true);

    final isCorrect = await _authService.checkPassword(
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (isCorrect) {

      _nextStep();

    } else {

      Fluttertoast.showToast(
        msg: "Mật khẩu không đúng",
      );

    }
  }

  // Step 2: Send OTP to new phone
  Future<void> _sendOtp() async {
    final newPhone = _newPhoneController.text.trim();
    if (newPhone.isEmpty) {
      Fluttertoast.showToast(msg: "Vui lòng nhập số điện thoại mới");
      return;
    }
    if (newPhone == widget.currentPhone) {
      Fluttertoast.showToast(msg: "Số điện thoại đã tồn tại!");
      return;
    }

    final users = await _authService.getUsers();

    final isExist = users.any(
          (u) => u['phone'] == newPhone,
    );

    if (isExist) {

      setState(() => _isLoading = false);

      Fluttertoast.showToast(
        msg: "Số điện thoại đã tồn tại",
      );

      return;
    }

    setState(() => _isLoading = true);
    final sent = await _authService.sendOtp(newPhone);
    setState(() => _isLoading = false);

    if (sent) {
    Fluttertoast.showToast(msg: "Đã gửi mã OTP");
    _nextStep();
    } else {
    Fluttertoast.showToast(msg: "Gửi OTP thất bại");
    }
  }

  // Step 3: Verify OTP and Finish
  Future<void> _verifyOtpAndFinish() async {

    if (_otpController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Vui lòng nhập mã OTP",
      );
      return;
    }

    setState(() => _isLoading = true);

    final verified = await _authService.verifyOtp(
      _newPhoneController.text.trim(),
      _otpController.text.trim(),
    );

    if (!verified) {

      setState(() => _isLoading = false);

      Fluttertoast.showToast(
        msg: "Mã OTP không đúng",
      );

      return;
    }

    // update số điện thoại
    final result = await _authService.changePhone(
      _passwordController.text,
      _newPhoneController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {

      Fluttertoast.showToast(
        msg: "Đổi số điện thoại thành công",
      );

      Navigator.pop(
        context,
        _newPhoneController.text.trim(),
      );

    } else {

      Fluttertoast.showToast(
        msg: result['message'],
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text("Đổi số điện thoại", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A2E44),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStepPassword(),
                _buildStepNewPhone(),
                _buildStepOtp(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      color: Colors.white,
      child: Row(
        children: [
          _stepCircle(0, "Mật khẩu"),
          _stepLine(0),
          _stepCircle(1, "SĐT mới"),
          _stepLine(1),
          _stepCircle(2, "Xác thực"),
        ],
      ),
    );
  }

  Widget _stepCircle(int step, String label) {
    bool isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1A73C8) : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: _currentStep > step
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text("${step + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? const Color(0xFF1A73C8) : Colors.grey)),
      ],
    );
  }

  Widget _stepLine(int step) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: _currentStep > step ? const Color(0xFF1A73C8) : Colors.grey[300],
      ),
    );
  }

  Widget _buildStepPassword() {
    return _buildStepLayout(
      title: "Xác thực danh tính",
      description: "Nhập mật khẩu hiện tại của bạn để đảm bảo an toàn bảo mật.",
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: "Mật khẩu",
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1A73C8)),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      onPressed: _verifyPassword,
      buttonText: "Tiếp tục",
    );
  }

  Widget _buildStepNewPhone() {
    return _buildStepLayout(
      title: "Số điện thoại mới",
      description: "Nhập số điện thoại mới mà bạn muốn thay đổi. Chúng tôi sẽ gửi mã OTP về số này.",
      child: TextField(
        controller: _newPhoneController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: "Số điện thoại mới",
          prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFF1A73C8)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      onPressed: _sendOtp,
      buttonText: "Gửi mã OTP",
    );
  }

  Widget _buildStepOtp() {
    return _buildStepLayout(
      title: "Xác thực OTP",
      description: "Nhập mã OTP 6 số đã được gửi đến số điện thoại ${_newPhoneController.text}",
      child: TextField(
        controller: _otpController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
        maxLength: 6,
        decoration: InputDecoration(
          counterText: "",
          hintText: "------",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      onPressed: _verifyOtpAndFinish,
      buttonText: "Hoàn tất",
    );
  }

  Widget _buildStepLayout({required String title, required String description, required Widget child, required VoidCallback onPressed, required String buttonText}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A2E44))),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 14, color: Color(0xFF4A6580))),
          const SizedBox(height: 32),
          child,
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73C8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(buttonText, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}