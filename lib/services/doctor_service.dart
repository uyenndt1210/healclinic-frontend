class Doctors{

  int DoctorId;
  String FullName;
  String SpecialtyId;
  int ExperienceYears;
  String Bio;
  String AvatarUrl;
  String WorkStartTime;
  String WorkEndTime;
  DateTime CreatedAt;
  DateTime UpdateAt;
  int UserId;

  Doctors({
      required this.DoctorId,
      required this.FullName,
      required this.SpecialtyId,
      required this.ExperienceYears,
      required this.Bio,
      required this.AvatarUrl,
      required this.WorkStartTime,
      required this.WorkEndTime,
      required this.CreatedAt,
      required this.UpdateAt,
      required this.UserId,
  });

  factory Doctors.fromJson(Map<String, dynamic> json){
    return Doctors(
        DoctorId: json["doctorId"],
        FullName: json["fullName"],
        SpecialtyId: json["specialtyId"],
        ExperienceYears: json["experienceYears"],
        Bio: json["bio"],
        AvatarUrl: json["avatarUrl"],
        WorkStartTime: json["workStartTime"],
        WorkEndTime: json["workEndTime"],
        CreatedAt: json["createdAt"],
        UpdateAt: json["updateAt"],
        UserId: json["userId"]);
  }

}