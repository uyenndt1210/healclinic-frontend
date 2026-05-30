import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Appointment {
  final int appointmentId;
  final String doctorName;
  final String appointmentDate;
  final String status;
  final double price;
  final String? timeExpected;
  final String? specialtyName;

  Appointment({
    required this.appointmentId,
    required this.doctorName,
    required this.appointmentDate,
    required this.status,
    required this.price,
    this.timeExpected,
    this.specialtyName,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointmentId'] ?? json['AppointmentId'] ?? 0,
      doctorName: json['doctorName'] ?? json['doctor']?['fullName'] ?? json['DoctorName'] ?? 'Không rõ',
      appointmentDate: json['appointmentDate'] ?? json['AppointmentDate'] ?? '',
      status: json['status'] ?? json['Status'] ?? 'N/A',
      price: (json['price'] ?? json['Price'] ?? 0).toDouble(),
      timeExpected: json['timeExpected'] ?? json['TimeExpected'],
      specialtyName: json['specialty']?['specialtyName'] ?? json['specialtyId'],
    );
  }
}

class AppointmentDetail {
  final int appointmentId;
  final String patientName;
  final String doctorName;
  final String specialtyId;
  final String appointmentDate;
  final String timeExpected;
  final int queueNumber;
  final String status;
  final String note;

  AppointmentDetail({
    required this.appointmentId,
    required this.patientName,
    required this.doctorName,
    required this.specialtyId,
    required this.appointmentDate,
    required this.timeExpected,
    required this.queueNumber,
    required this.status,
    required this.note,
  });

  factory AppointmentDetail.fromJson(Map<String, dynamic> json) {
    return AppointmentDetail(
      appointmentId: json['appointmentId'] ?? 0,
      patientName: json['patient']?['fullName'] ?? 'Không rõ',
      doctorName: json['doctor']?['fullName'] ?? 'Không rõ',
      specialtyId: json['specialty']?['specialtyName'] ?? json['specialtyId'] ?? '',
      appointmentDate: json['appointmentDate'] ?? '',
      timeExpected: json['timeExpected'] ?? 'Chưa xác định',
      queueNumber: json['queueNumber'] ?? 0,
      status: json['status'] ?? 'N/A',
      note: json['note'] ?? '',
    );
  }
}

class AppointmentService {
  final String baseUrl = "http://10.0.2.2:5257/api";

  // Lấy patientId từ userId qua API User
  Future<int?> _getPatientId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId");
    final token = prefs.getString("token");

    if (userId == null) {
      debugPrint("Lỗi: userId không tồn tại");
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/User/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final patients = data['patients'] as List?;
      if (patients != null && patients.isNotEmpty) {
        final patientId = patients[0]['patientId'];
        debugPrint("patientId lấy được: $patientId");
        return patientId;
      }
    }

    debugPrint("Không lấy được patientId, status: ${response.statusCode}");
    return null;
  }

  // Lấy danh sách lịch hẹn
  Future<List<Appointment>> getAppointments({String? status}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final patientId = await _getPatientId();
      if (patientId == null) return [];

      final url = '$baseUrl/Appointment/patient/$patientId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("Appointment status code: ${response.statusCode}");
      debugPrint("Appointment body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Appointment> appointments =
        data.map((item) => Appointment.fromJson(item)).toList();

        if (status != null) {
          appointments =
              appointments.where((a) => a.status == status).toList();
        }

        return appointments;
      }

      debugPrint("Lỗi API Appointment: ${response.statusCode}");
      return [];
    } catch (e) {
      debugPrint("Lỗi lấy lịch hẹn: $e");
      return [];
    }
  }

  // Lấy chi tiết 1 lịch hẹn theo id
  Future<AppointmentDetail?> getAppointmentById(int appointmentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse('$baseUrl/Appointment/$appointmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("Detail status code: ${response.statusCode}");
      debugPrint("Detail body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AppointmentDetail.fromJson(data);
      }

      return null;
    } catch (e) {
      debugPrint("Lỗi lấy chi tiết lịch hẹn: $e");
      return null;
    }
  }
}
