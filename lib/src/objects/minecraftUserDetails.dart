// To parse this JSON data, do
//
//     final minecraftUserDetails = minecraftUserDetailsFromJson(jsonString);

import 'package:hive/hive.dart';
import 'dart:convert';



MinecraftUserDetails minecraftUserDetailsFromJson(String str) => MinecraftUserDetails.fromJson(json.decode(str));

String minecraftUserDetailsToJson(MinecraftUserDetails data) => json.encode(data.toJson());

@HiveType(typeId: 1)
class MinecraftUserDetails {
    @HiveField(1)
    List<Cape> capes;
    @HiveField(2)
    String id;
    @HiveField(3)
    String name;
    @HiveField(4)
    List<Skin> skins;

    MinecraftUserDetails({
        required this.capes,
        required this.id,
        required this.name,
        required this.skins,
    });

    factory MinecraftUserDetails.fromJson(Map<String, dynamic> json) => MinecraftUserDetails(
        capes: List<Cape>.from(json["capes"].map((x) => Cape.fromJson(x))),
        id: json["id"],
        name: json["name"],
        skins: List<Skin>.from(json["skins"].map((x) => Skin.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "capes": List<dynamic>.from(capes.map((x) => x.toJson())),
        "id": id,
        "name": name,
        "skins": List<dynamic>.from(skins.map((x) => x.toJson())),
    };
}

@HiveType(typeId: 2)
class Cape {
    @HiveField(1)
    String alias;
    @HiveField(2)
    String id;
    @HiveField(3)
    String state;
    @HiveField(4)
    String url;

    Cape({
        required this.alias,
        required this.id,
        required this.state,
        required this.url,
    });

    factory Cape.fromJson(Map<String, dynamic> json) => Cape(
        alias: json["alias"],
        id: json["id"],
        state: json["state"],
        url: json["url"],
    );

    Map<String, dynamic> toJson() => {
        "alias": alias,
        "id": id,
        "state": state,
        "url": url,
    };
}

@HiveType(typeId: 3)
class Skin {
    @HiveField(1)
    String id;
    @HiveField(2)
    String state;
    @HiveField(3)
    String textureKey;
    @HiveField(4)
    String url;
    @HiveField(5)
    String variant;

    Skin({
        required this.id,
        required this.state,
        required this.textureKey,
        required this.url,
        required this.variant,
    });

    factory Skin.fromJson(Map<String, dynamic> json) => Skin(
        id: json["id"],
        state: json["state"],
        textureKey: json["textureKey"],
        url: json["url"],
        variant: json["variant"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "state": state,
        "textureKey": textureKey,
        "url": url,
        "variant": variant,
    };
}
