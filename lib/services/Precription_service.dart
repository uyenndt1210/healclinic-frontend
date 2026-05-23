import 'Prescription_Detail.dart';

class PrescriptionModel {

  final int prescriptionId;

  final int recordId;

  final String? note;

  final DateTime? createdAt;

  final List<PrescriptionDetailModel> details;

  PrescriptionModel({
    required this.prescriptionId,
    required this.recordId,
    this.note,
    this.createdAt,
    required this.details,
  });

  factory PrescriptionModel.fromJson(
      Map<String, dynamic> json) {

    var detailsList =
        json['prescriptiondetails']
        as List? ?? [];

    return PrescriptionModel(

      prescriptionId:
      json['prescriptionId'] ?? 0,

      recordId:
      json['recordId'] ?? 0,

      note:
      json['note'],

      createdAt:
      json['createdAt'] != null
          ? DateTime.parse(
          json['createdAt'])
          : null,

      details:
      detailsList
          .map((d) =>
          PrescriptionDetailModel.fromJson(d))
          .toList(),
    );
  }
}

