import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/MedicalRecord_service.dart';
import '../../services/Prescription_Detail.dart';
import '../../services/patient_service.dart';
import '../../services/user_service.dart';

class AppColors {
  static const primary = Color(0xFF1A73C8);
  static const background = Color(0xFFF5F9FF);
  static const textDark = Color(0xFF1A2E44);
  static const textMedium = Color(0xFF4A6580);
  static const white = Color(0xFFFFFFFF);
  static const gradientStart = Color(0xFF1A73C8);
  static const gradientEnd = Color(0xFF00B4D8);
}

class HealthRecordPage extends StatefulWidget {
  const HealthRecordPage({super.key});

  @override
  State<HealthRecordPage> createState() => _HealthRecordPageState();
}

class _HealthRecordPageState extends State<HealthRecordPage> {
  Users? userProfile;
  Patients? patient;
  String? fullName;
  List<MedicalRecordModel> medicalRecords = [];
  bool isLoading = true;
  final MedicalRecordService _medicalRecordService = MedicalRecordService();

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

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        userProfile = Users.fromJson(data);

        if (data['patients'] != null && (data['patients'] as List).isNotEmpty) {
          final pData = data['patients'][0];
          fullName = pData['fullName'];
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

        final records = await _medicalRecordService.getAllMedicalRecords();
        records.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));

        setState(() {
          medicalRecords = records;
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

  String _calculateBMI() {
    if (patient == null) return "N/A";
    double weight = double.tryParse(patient!.Weight) ?? 0;
    double height = (double.tryParse(patient!.Height) ?? 0) / 100;
    if (height == 0) return "N/A";
    double bmi = weight / (height * height);
    return bmi.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Hồ sơ sức khỏe", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBMICard(),
              const SizedBox(height: 20),
              _buildVitalStats(),
              const SizedBox(height: 20),
              _buildMedicalHistory(),
              const SizedBox(height: 24),
              const Text(
                "Lịch sử khám bệnh",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 12),
              _buildMedicalRecordsList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS GIỮ NGUYÊN PHẦN TRÊN ---
  Widget _buildBMICard() {
    String bmi = _calculateBMI();
    String resultBmi = "-----";
    if (bmi != "N/A") {
      double val = double.parse(bmi);
      if (val < 18.5) resultBmi = "Thiếu cân";
      else if (val < 24.9) resultBmi = "Bình thường";
      else if (val < 29.9) resultBmi = "Thừa cân";
      else resultBmi = "Béo phì";
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.gradientEnd,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Chỉ số BMI của bạn", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              Text(bmi, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(resultBmi, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          const Icon(Icons.monitor_heart_rounded, color: Colors.white24, size: 80),
        ],
      ),
    );
  }

  Widget _buildVitalStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _statItem(Icons.height, "Chiều cao", "${patient?.Height ?? 0} cm", Colors.blue),
        _statItem(Icons.monitor_weight, "Cân nặng", "${patient?.Weight ?? 0} kg", Colors.orange),
        _statItem(Icons.bloodtype, "Nhóm máu", patient?.BloodType ?? "N/A", Colors.red),
        _statItem(Icons.calendar_month, "Cập nhật", "Hôm nay", Colors.green),
      ],
    );
  }

  Widget _statItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildMedicalHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tiền sử & Dị ứng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 30),
          _historyRow("Dị ứng", patient?.Allergies, Icons.warning_amber_rounded, Colors.red),
          const SizedBox(height: 20),
          _historyRow("Bệnh mãn tính", patient?.ChronicDiseases, Icons.medical_services_outlined, Colors.purple),
        ],
      ),
    );
  }

  Widget _historyRow(String title, String? value, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Text(value == null || value.isEmpty ? "Không có" : value,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }

  // --- PHẦN LỊCH SỬ KHÁM BỆNH VỚI ĐƠN THUỐC ---

  Widget _buildMedicalRecordsList() {
    if (medicalRecords.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Column(
          children: [
            Icon(Icons.assignment_late_outlined, color: Colors.grey, size: 40),
            SizedBox(height: 12),
            Text("Chưa có lịch sử khám bệnh", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: medicalRecords.length,
      itemBuilder: (context, index) {
        return _buildMedicalRecordCard(medicalRecords[index]);
      },
    );
  }

  Widget _buildMedicalRecordCard(MedicalRecordModel record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.event_note, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      record.createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(record.createdAt!) : "Không rõ ngày",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (record.isCover)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text("BHYT ${record.percentCover}%",
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  )
              ],
            ),
          ),

          // Chi tiết khám bệnh
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildRecordRow(Icons.sick_outlined, "Triệu chứng", record.symptoms, Colors.orange),
                const Divider(height: 24),
                _buildRecordRow(Icons.biotech_outlined, "Chẩn đoán", record.diagnosis, Colors.red),
                const Divider(height: 24),
                _buildRecordRow(Icons.medication_liquid_outlined, "Điều trị", record.treatment, Colors.green),
              ],
            ),
          ),

          // Phần Đơn thuốc xổ xuống
          if (record.prescriptions.isNotEmpty)
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: const Text(
                  "Xem đơn thuốc",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                leading: const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: Column(
                      children: record.prescriptions.expand((p) => p.details).map((detail) {
                        return _buildPrescriptionDetailItem(detail);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionDetailItem(PrescriptionDetailModel detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.medication, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.medication?.medicineName ?? "Tên thuốc",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Số lượng: ${detail.quantity} ${detail.medication?.unit ?? ''}", style: const TextStyle(fontSize: 12)),
                    Text("Dùng trong: ${detail.duration} ngày", style: const TextStyle(fontSize: 12)),
                  ],
                ),
                if (detail.note != null && detail.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "HDSD: ${detail.note}",
                      style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordRow(IconData icon, String title, String? value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(value == null || value.isEmpty ? "Chưa có dữ liệu" : value,
                  style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
