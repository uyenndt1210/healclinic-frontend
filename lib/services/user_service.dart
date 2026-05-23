import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Users {
  int UserId;
  String Email;
  String PassWord;
  String Phone;
  String Role;
  DateTime CreatedAt;
  DateTime UpdateAt;

  Users({ required this.UserId,
          required this.Email,
          required this.PassWord,
          required this.Phone,
          required this.Role,
          required this.CreatedAt,
          required this.UpdateAt});

  factory Users.fromJson(Map<String, dynamic> json){
    return Users(
      UserId: json['userId'],
      Email: json['email'],
      PassWord: json['passWord'],
      Phone: json['phone'], // FIX
      Role: json['role'],
      CreatedAt: DateTime.parse(json['createdAt']),
      UpdateAt: DateTime.parse(json['updateAt']),
    );
  }
}


