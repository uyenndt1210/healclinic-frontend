import 'dart:convert';

import 'package:benhvien/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:emailjs/emailjs.dart' as emailjs;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/patient_service.dart';

class AppColors {
  static const primary = Color(0xFF1A73C8);
  static const background = Color(0xFFF5F9FF);
  static const textDark = Color(0xFF1A2E44);
  static const textMedium = Color(0xFF4A6580);
  static const white = Color(0xFFFFFFFF);
  static const gradientStart = Color(0xFF1A73C8);
  static const gradientEnd = Color(0xFF00B4D8);
}


class ContactPage extends StatefulWidget {
  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();
  bool _isSending = false;

  Users? userProfile;
  Patients? patient;
  String? fullName;
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
      final name = prefs.getString("fullName");

      print("Name: " + name!);
      print("User ID: " + userId.toString());
      print("Token: " + token!);

      if (userId == null || token == null) {
        throw Exception("Thông tin đăng nhập không hợp lệ");
      }

      final res = await http.get(
        Uri.parse('http://10.0.2.2:5257/api/User/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
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
          userProfile = Users.fromJson(data);
          emailController.text = userProfile?.Email ?? "";

          if (data['patients'] != null && (data['patients'] as List).isNotEmpty) {
            // Lấy dữ liệu bệnh nhân (giả sử backend trả về camelCase trong list)
            final pData = data['patients'][0];
            fullName = pData['fullName'];
            nameController.text = fullName ?? "";

            // Map thủ công để đảm bảo an toàn nếu Model Patients dùng PascalCase
            patient = Patients(
              PatientId: pData['patientId'] ?? 0,
              FullName: pData['fullName'] ?? '',
              Gender: pData['gender'] ?? '',
              DateOfBirth: pData['dateOfBirth'] ?? '',
              Address: pData['address'] ?? '',
              Phone: pData['phone'] ?? '',
              BloodType: pData['bloodType'] ?? '',
              Height: pData['height']?.toString() ?? '0',
              Weight: pData['weight']?.toString() ?? '0',
              Allergies: pData['allergies'] ?? '',
              ChronicDiseases: pData['chronicDiseases'] ?? '',
              CreatedAt: pData['createdAt'] != null ? DateTime.parse(pData['createdAt']) : DateTime.now(),
              UpdateAt: pData['updateAt'] != null ? DateTime.parse(pData['updateAt']) : DateTime.now(),
              UserId: userId,
            );
          }
          //fullName = name;
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



  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> sendEmail() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty || messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    setState(() => _isSending = true);

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id': 'service_d7kt02y',
          'template_id': 'template_k03npug',
          'user_id': 'VCZ2gjfktXWD2c9D6',
          'template_params': {
            'name': nameController.text,
            'email': emailController.text,
            'message': messageController.text,
            'title': 'Phản hồi từ ứng dụng',
            'time': "${DateTime.now().hour.toString().padLeft(2, '0')}:"
                "${DateTime.now().minute.toString().padLeft(2, '0')} - ${DateTime.now().day.toString().padLeft(2, '0')}/"
                "${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}",
          }
        }),
      );
      if (response.statusCode == 200) {
        _showSnackBar('Gửi phản hồi thành công!', Colors.green);
        _formKey.currentState?.reset();
        nameController.clear();
        emailController.clear();
        messageController.clear();
      } else {
        _showSnackBar('Lỗi hệ thống: ${response.body}', Colors.red);
      }
    }
      catch (e) {
        print("Lỗi EmailJS:");
        print(e.toString());
        print(e.runtimeType);
        _showSnackBar('Không thể kết nối Internet. Vui lòng thử lại!', Colors.red);
      } finally {
        setState(() {
          _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Liên hệ & Phản hồi", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Gửi tin nhắn cho chúng tôi",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: nameController,
                      label: "Họ và tên",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: emailController,
                      label: "Email liên hệ",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: messageController,
                      label: "Nội dung phản hồi",
                      icon: Icons.chat_bubble_outline,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 30),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.gradientEnd,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            children: [
              Icon(Icons.headset_mic_rounded, color: Colors.white, size: 50),
              SizedBox(height: 12),
              Text(
                "Chúng tôi luôn lắng nghe bạn",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "Mọi ý kiến đóng góp giúp Heal Clinic \n hoàn thiện hơn",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
        filled: true,
        fillColor: Colors.grey[50],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textMedium, fontSize: 14),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isSending ? null : sendEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        child: _isSending
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : const Text(
          "Gửi phản hồi ngay",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}