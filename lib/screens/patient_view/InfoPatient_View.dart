import 'dart:convert';
import 'package:benhvien/services/patient_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_service.dart';
import 'ChangeInfoPatient.dart';

class AppColors {
  static const primary = Color(0xFF1A73C8);
  static const background = Color(0xFFF5F9FF);
  static const textDark = Color(0xFF1A2E44);
  static const textMedium = Color(0xFF4A6580);
  static const white = Color(0xFFFFFFFF);
  static const gradientStart = Color(0xFF1A73C8);
  static const gradientEnd = Color(0xFF00B4D8);
}


class InforPatient extends StatefulWidget {
  const InforPatient({super.key});

  @override
  State<InforPatient> createState() => _InforPatientState();
}

class _InforPatientState extends State<InforPatient> {
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

          if (data['patients'] != null && (data['patients'] as List).isNotEmpty) {
            // Lấy dữ liệu bệnh nhân (giả sử backend trả về camelCase trong list)
            final pData = data['patients'][0];
            fullName = pData['fullName'];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text("Thông tin cá nhân", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1A2E44),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 24),
              _buildSectionTitle("Thông tin tài khoản"),
              _buildUserSection(),
              const SizedBox(height: 20),
              _buildSectionTitle("Thông tin y tế"),
              _buildPatientSection(),
              const SizedBox(height: 30),
              _buildEditButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
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
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            fullName ?? "Unknow",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            userProfile?.Email ?? "Chưa cập nhật Email",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSection() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _infoTile(Icons.phone_iphone_rounded, "Số điện thoại", userProfile?.Phone ?? "N/A"),
          _divider(),
          _infoTile(Icons.email_outlined, "Email", userProfile?.Email ?? "N/A"),
          _divider(),
          _infoTile(Icons.wc_rounded, "Giới tính", patient?.Gender ?? "N/A"),
          _divider(),
          _infoTile(Icons.date_range_rounded, "Ngày sinh", patient?.DateOfBirth ?? "N/A"),
          _divider(),
          _infoTile(Icons.location_on_outlined, "Địa chỉ", patient?.Address ?? "Chưa cập nhật"),
        ],
      ),
    );
  }

  Widget _buildPatientSection() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _infoTile(Icons.bloodtype_outlined, "Nhóm máu", patient?.BloodType ?? "N/A"),
          _divider(),
          Row(
            children: [
              Expanded(child: _infoTile(Icons.monitor_weight_outlined, "Cân nặng", "${patient?.Weight ?? 0} kg")),
              Container(width: 1, height: 40, color: Colors.grey[100]),
              Expanded(child: _infoTile(Icons.height_rounded, "Chiều cao", "${patient?.Height ?? 0} cm")),
            ],
          ),
          _divider(),
          _infoTile(Icons.warning_amber_rounded, "Dị ứng",
              (patient?.Allergies == null || patient!.Allergies.isEmpty) ? "Không có" : patient!.Allergies),
          _divider(),
          _infoTile(Icons.medical_services_outlined, "Bệnh mãn tính",
              (patient?.ChronicDiseases == null || patient!.ChronicDiseases.isEmpty) ? "Không có" : patient!.ChronicDiseases),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textMedium, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          )
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
    );
  }

  Widget _divider() => Divider(height: 1, indent: 70, color: Colors.grey[100]);

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          if (userProfile == null || patient == null) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeInfoPatient(
                user: userProfile!,
                patientId: patient!.PatientId,
                currentFullName: fullName ?? "",
                address: patient!.Address,
                dateOfBirth: DateTime.parse(patient!.DateOfBirth),
                gender: patient!.Gender,
                weight: double.tryParse(patient!.Weight),
                height: double.tryParse(patient!.Height),
                allergies: patient!.Allergies,
                chronicDiseases: patient!.ChronicDiseases,
                bloodType: patient!.BloodType,
              ),
            ),
          ).then((value) {
            if (value == true) fetchProfile();
          });
        },
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text("Chỉnh sửa thông tin", style: TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          side: BorderSide(color: AppColors.primary.withOpacity(0.4), width: 2),
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }
}