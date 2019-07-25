// To parse this JSON data, do
//
//     final checkinHistory = checkinHistoryFromJson(jsonString);

import 'dart:convert';

CheckinHistory checkinHistoryFromJson(String str) => CheckinHistory.fromJson(json.decode(str));

String checkinHistoryToJson(CheckinHistory data) => json.encode(data.toJson());

class CheckinHistory {
    int id;
    int locationId;
    String checkTime;
    String userId;

    CheckinHistory({
        this.id,
        this.locationId,
        this.checkTime,
        this.userId,
    });

    factory CheckinHistory.fromJson(Map<String, dynamic> json) => new CheckinHistory(
        id: json["id"],
        locationId: json["locationId"],
        checkTime: json["checkTime"],
        userId: json["userId"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "locationId": locationId,
        "checkTime": checkTime,
        "userId": userId,
    };
}
