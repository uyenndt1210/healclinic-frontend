import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_service.dart';
import 'package:intl/intl.dart';

class AppColors {
  static const primary = Color(0xFF1A73C8);
  static const background = Color(0xFFF5F9FF);
  static const textDark = Color(0xFF1A2E44);
  static const textMedium = Color(0xFF4A6580);
  static const white = Color(0xFFFFFFFF);
  static const gradientStart = Color(0xFF1A73C8);
  static const gradientEnd = Color(0xFF00B4D8);
}

class ChangeInfoPatient extends StatefulWidget {
  final Users user;
  final int patientId;
  final String currentFullName;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? weight;
  final double? height;
  final String? allergies;
  final String? chronicDiseases;
  final String? bloodType;

  const ChangeInfoPatient({
    super.key,
    required this.user,
    required this.currentFullName,
    required this.patientId,
    required this.address,
    required this.dateOfBirth,
    required this.gender,
    required this.weight,
    required this.height,
    required this.allergies,
    required this.chronicDiseases,
    required this.bloodType,
  });

  @override
  State<ChangeInfoPatient> createState() => _ChangeInfoPatientState();
}

class _ChangeInfoPatientState extends State<ChangeInfoPatient> {
  final List<String> _genderOptions = ["Nam", "Nữ"];

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _allergiesController;
  late TextEditingController _diseasesController;
  late TextEditingController _bloodTypeController;
  late TextEditingController _addressController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _genderController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentFullName);
    _emailController = TextEditingController(text: widget.user.Email);
    _phoneController = TextEditingController(text: widget.user.Phone);
    _weightController = TextEditingController(text: widget.weight?.toString() ?? "");
    _heightController = TextEditingController(text: widget.height?.toString() ?? "");
    _allergiesController = TextEditingController(text: widget.allergies ?? "");
    _diseasesController = TextEditingController(text: widget.chronicDiseases ?? "");
    _bloodTypeController = TextEditingController(text: widget.bloodType ?? "");
    _addressController = TextEditingController(text: widget.address ?? "");
    _dateOfBirthController = TextEditingController(
      text: widget.dateOfBirth != null
          ? DateFormat('dd/MM/yyyy').format(widget.dateOfBirth!)
          : "",
    );
    _genderController = TextEditingController(text: widget.gender ?? "Nam");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _allergiesController.dispose();
    _diseasesController.dispose();
    _bloodTypeController.dispose();
    _addressController.dispose();
    _dateOfBirthController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ Họ tên và Số điện thoại")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final responseUser = await http.put(
        Uri.parse('http://10.0.2.2:5257/api/User/${widget.user.UserId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'UserId': widget.user.UserId,
          'Email': _emailController.text.trim(),
          'PassWord': widget.user.PassWord,
          'Phone': widget.user.Phone,
          'Role': widget.user.Role,
        }),
      );
      print("UpdateUser Status: ${responseUser.statusCode}");
      print("UpdateUser Body: ${responseUser.body}");
      if (responseUser.statusCode == 200) {

        String? isoDob;
        try {
          if (_dateOfBirthController.text.isNotEmpty) {
            isoDob = DateFormat('yyyy-MM-dd').format(
              DateFormat('dd/MM/yyyy')
                  .parse(_dateOfBirthController.text),
            );
          }
        } catch (e) {
          isoDob = widget.dateOfBirth != null
              ? DateFormat('yyyy-MM-dd')
              .format(widget.dateOfBirth!)
              : null;
        }

        final responsePatient = await http.put(
          Uri.parse('http://10.0.2.2:5257/api/Patient/${widget.patientId}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'PatientId': widget.patientId,
            'FullName': _nameController.text.trim(),
            'Address': _addressController.text.trim(),
            'DateOfBirth': isoDob,
            'Gender': _genderController.text.trim(),
            'Weight': double.tryParse(_weightController.text.trim()),
            'Height': double.tryParse(_heightController.text.trim()),
            'Allergies': _allergiesController.text.trim(),
            'ChronicDiseases': _diseasesController.text.trim(),
            'BloodType': _bloodTypeController.text.trim(),
            'UserId': widget.user.UserId,
          }),
        );

        print("UpdatePatient Status: ${responsePatient.statusCode}");
        print("UpdatePatient Body: ${responsePatient.body}");

        if (responsePatient.statusCode == 200) {
          await prefs.setString('fullName', _nameController.text.trim());
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cập nhật thông tin thành công!")),
            );
            Navigator.pop(context, true);
          }
        } else {
          throw Exception("Lỗi cập nhật thông tin bệnh nhân");
        }
      } else {
        throw Exception("Lỗi cập nhật tài khoản");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString()}")),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text("Chỉnh sửa hồ sơ", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A2E44),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSectionTitle("Thông tin cá nhân"),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  _buildTextField(Icons.person_outline, "Họ và tên", _nameController),
                  const Divider(height: 32),
                  _buildTextField(Icons.email_outlined, "Email", _emailController),
                  const Divider(height: 32),
                  _buildGenderDropdown(),
                  const Divider(height: 32),
                  _buildTextField(Icons.calendar_today_outlined, "Ngày sinh (dd/MM/yyyy)", _dateOfBirthController),
                  const Divider(height: 32),
                  _buildTextField(Icons.phone_android_outlined, "Số điện thoại (Chỉ xem)", _phoneController, enabled: false),
                  const Divider(height: 32),
                  _buildTextField(Icons.location_on_outlined, "Địa chỉ", _addressController),
                  const Divider(height: 32),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle("Thông tin y tế"),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildTextField(Icons.monitor_weight_outlined, "Cân nặng (kg)", _weightController)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(Icons.height, "Chiều cao (cm)", _heightController)),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildTextField(Icons.bloodtype_outlined, "Nhóm máu", _bloodTypeController),
                  const Divider(height: 32),
                  _buildTextField(Icons.warning_amber_rounded, "Dị ứng", _allergiesController),
                  const Divider(height: 32),
                  _buildTextField(Icons.medical_services_outlined, "Bệnh mãn tính", _diseasesController),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMedium)),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String label, TextEditingController controller, { bool enabled = true,}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4A6580),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),

        TextField(
          controller: controller,
          enabled: enabled,

          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF1A73C8),
              size: 20,
            ),

            border: InputBorder.none,

            contentPadding:
            const EdgeInsets.symmetric(vertical: 12),
          ),

          style: const TextStyle(
            color: Color(0xFF1A2E44),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Giới tính",
          style: TextStyle(
            color: Color(0xFF4A6580),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        DropdownButtonFormField<String>(
          // Nếu giá trị hiện tại không nằm trong danh sách thì mặc định chọn cái đầu tiên
          value: _genderOptions.contains(_genderController.text)
              ? _genderController.text
              : _genderOptions[0],
          items: _genderOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _genderController.text = newValue!;
            });
          },
          decoration: const InputDecoration(
            prefixIcon: Icon(
              Icons.wc_outlined,
              color: Color(0xFF1A73C8),
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
          style: const TextStyle(
            color: Color(0xFF1A2E44),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1A73C8)),
          isExpanded: true,
          dropdownColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A73C8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Lưu thay đổi", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}