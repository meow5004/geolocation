// To parse this JSON data, do
//
//     final RefLocationGroup = RefLocationGroupFromJson(jsonString);

import 'dart:convert';

RefLocationGroup refLocationGroupFromJson(String str) => RefLocationGroup.fromJson(json.decode(str));

String refLocationGroupToJson(RefLocationGroup data) => json.encode(data.toJson());

class RefLocationGroup {
    int id;
    String name;

    RefLocationGroup({
        this.id,
        this.name
    });

    factory RefLocationGroup.fromJson(Map<String, dynamic> json) => new RefLocationGroup(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}
