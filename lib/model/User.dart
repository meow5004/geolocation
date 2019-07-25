// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  int id;
  String imei;
  String userId;

  User({this.id, this.imei, this.userId});

  factory User.fromJson(Map<String, dynamic> json) => new User(
        id: json["id"],
        imei: json["imei"],
        userId: json["userId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "imei": imei,
        "userId": userId,
      };
}
