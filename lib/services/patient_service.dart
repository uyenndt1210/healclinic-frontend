class Patients{

  int PatientId;
  String FullName;
  String Gender;
  String DateOfBirth;
  String Address;
  String Phone;
  String BloodType;
  String Height;
  String Weight;
  String Allergies;
  String ChronicDiseases;
  DateTime CreatedAt;
  DateTime UpdateAt;
  int UserId;

  Patients({
    required this.PatientId,
    required this.FullName,
    required this.Gender,
    required this.DateOfBirth,
    required this.Address,
    required this.Phone,
    required this.BloodType,
    required this.Height,
    required this.Weight,
    required this.Allergies,
    required this.ChronicDiseases,
    required this.CreatedAt,
    required this.UpdateAt,
    required this.UserId,
  });

  factory Patients.fromJson(Map<String, dynamic> json){
    return Patients(
        PatientId: json["patientId"],
        FullName: json["fullName"],
        Gender: json["gender"],
        DateOfBirth: json["dateOfBirth"],
        Address: json["address"],
        Phone: json["phone"],
        BloodType: json["bloodType"],
        Height: json["height"],
        Weight: json["weight"],
        Allergies: json["allergies"],
        ChronicDiseases: json["chronicDiseases"],
        CreatedAt: json["createdAt"],
        UpdateAt: json["updateAt"],
        UserId: json["userId"]);
  }

}