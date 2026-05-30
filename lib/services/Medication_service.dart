class MedicationModel {

  final String medicationId;

  final String medicineName;

  final double? dosage;

  final int? frequency;

  final DateTime? startDate;

  final DateTime? endDate;

  final int? quantity;

  final String? unit;

  final String? country;

  final String? manufacturer;

  final double? price;

  final bool isCover;

  final String? note;

  MedicationModel({
    required this.medicationId,
    required this.medicineName,
    this.dosage,
    this.frequency,
    this.startDate,
    this.endDate,
    this.quantity,
    this.unit,
    this.country,
    this.manufacturer,
    this.price,
    required this.isCover,
    this.note,
  });

  factory MedicationModel.fromJson(
      Map<String, dynamic> json) {

    return MedicationModel(

      medicationId:
      json['medicationId'] ?? '',

      medicineName:
      json['medicineName'] ?? '',

      dosage:
      (json['dosage'] as num?)
          ?.toDouble(),

      frequency:
      json['frequency'],

      startDate:
      json['startDate'] != null
          ? DateTime.parse(
          json['startDate'])
          : null,

      endDate:
      json['endDate'] != null
          ? DateTime.parse(
          json['endDate'])
          : null,

      quantity:
      json['quantity'],

      unit:
      json['unit'],

      country:
      json['country'],

      manufacturer:
      json['manufacturer'],

      price:
      (json['price'] as num?)
          ?.toDouble(),

      isCover:
      json['isCover'] ?? false,

      note:
      json['note'],
    );
  }
}