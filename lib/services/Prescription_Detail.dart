import 'Medication_service.dart';

class PrescriptionDetailModel {

  final int prescriptionId;

  final String medicationId;

  final int? duration;

  final int? quantity;

  final String? note;

  final MedicationModel? medication;

  PrescriptionDetailModel({

    required this.prescriptionId,

    required this.medicationId,

    this.duration,

    this.quantity,

    this.note,

    this.medication,
  });

  factory PrescriptionDetailModel.fromJson(
      Map<String, dynamic> json) {

    return PrescriptionDetailModel(

      prescriptionId: json['prescriptionId'] ?? 0,

      medicationId: json['medicationId'] ?? '',

      duration: json['duration'],

      quantity: json['quantity'],

      note: json['note'],

      medication: json['medication'] != null
          ? MedicationModel.fromJson(json['medication'])
          : null,
    );
  }
}