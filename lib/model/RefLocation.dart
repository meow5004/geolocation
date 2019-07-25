// To parse this JSON data, do
//
//     final refLocation = refLocationFromJson(jsonString);

import 'dart:convert';

RefLocation refLocationFromJson(String str) => RefLocation.fromJson(json.decode(str));

String refLocationToJson(RefLocation data) => json.encode(data.toJson());

class RefLocation {
    int id;
    String name;
    double lat;
    double long;
    int groupId;

    RefLocation({
        this.id,
        this.name,
        this.lat,
        this.long,
        this.groupId
    });

    factory RefLocation.fromJson(Map<String, dynamic> json) => new RefLocation(
        id: json["id"],
        name: json["name"],
        lat: json["lat"],
        long: json["long"],
        groupId: json["groupId"]
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "lat": lat,
        "long": long,
        "groupId":groupId
    };
}
