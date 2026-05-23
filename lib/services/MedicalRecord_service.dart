import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Precription_service.dart';
import 'appointment_service.dart';



class MedicalRecordModel {

  final int recordId;

  final int appointmentId;

  final String diagnosis;

  final String symptoms;

  final String treatment;

  final bool isCover;

  final int percentCover;

  final DateTime createdAt;

  final Appointment? appointment;

  final List<PrescriptionModel> prescriptions;

  MedicalRecordModel({
    required this.recordId,
    required this.appointmentId,
    required this.diagnosis,
    required this.symptoms,
    required this.treatment,
    required this.isCover,
    required this.percentCover,
    required this.createdAt,
    this.appointment,
    required this.prescriptions,
  });

  factory MedicalRecordModel.fromJson(
      Map<String, dynamic> json) {

    var presList =
        json['prescriptions'] as List? ?? [];

    return MedicalRecordModel(

      recordId:
      json['recordId'] ?? 0,

      appointmentId:
      json['appointmentId'] ?? 0,

      diagnosis:
      json['diagnosis'] ?? '',

      symptoms:
      json['symptoms'] ?? '',

      treatment:
      json['treatment'] ?? '',

      isCover:
      json['isCover'] ?? false,

      percentCover:
      json['percentCover'] ?? 0,

      createdAt:
      json['createdAt'] != null
          ? DateTime.parse(
          json['createdAt'])
          : DateTime.now(),

      appointment:
      json['appointment'] != null
          ? Appointment.fromJson(
          json['appointment'])
          : null,

      prescriptions:
      presList
          .map((p) =>
          PrescriptionModel.fromJson(p))
          .toList(),
    );
  }
}

class MedicalRecordService {
  static const String baseUrl = 'http://10.0.2.2:5257/api/MedicalRecord';

  Future<List<MedicalRecordModel>> getAllMedicalRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MedicalRecordModel.fromJson(json)).toList();
      } else {
        print("Lỗi lấy danh sách hồ sơ: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ LỖI KẾT NỐI MedicalRecordService: $e");
      return [];
    }
  }
}