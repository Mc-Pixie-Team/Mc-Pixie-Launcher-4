import 'package:fl_chart/fl_chart.dart';
import 'package:mclauncher4/src/tasks/models/object_type.dart';

class UMF {
  UMF({
    this.name,
    this.versionName,
    this.author,
    this.description,
    this.downloads,
    this.likes,
    this.categories,
    this.icon,
    this.body,
    this.modloader,
    this.MLVersion,
    this.MCVersion,
    required this.type,
    required this.slug,
    required this.providerId,
    required this.original,
  });

  String? name;
  String? versionName;
  String? author;
  String? description;
  int? downloads;
  int? likes;
  List<dynamic>? categories;
  String? icon;
  String? body;
  String? modloader;
  String? MLVersion;
  String? MCVersion;
  ObjectType type;
  String slug;
  String providerId;
  Map original;

  static toJson(UMF umf) {
    return {
      "name": umf.name,
      "slug": umf.slug,
      "versionName": umf.versionName,
      "author": umf.author,
      "description": umf.description,
      "downloads": umf.downloads,
      "likes": umf.likes,
      "categories": umf.categories,
      "icon": umf.icon,
      "modloader": umf.modloader,
      "MLVersion": umf.MLVersion,
      "MCVersion": umf.MCVersion,
      "type": umf.type.toString(),
      "body": umf.body,
      "providerId": umf.providerId,
      "original": umf.original
    };
  }

  static UMF parse(Map json) {
    return UMF(
        name: json["name"],
        versionName: json["versionName"],
        author: json["author"],
        description: json["description"],
        downloads: json["downloads"],
        likes: json["likes"],
        categories: json["categories"],
        icon: json["icon"],
        body: json["body"],
        modloader: json["modloader"],
        MLVersion: json["MLVersion"],
        MCVersion: json["MCVersion"],
        type: _parsetype(json["type"]),
        slug: json["slug"],
        providerId: json["providerId"],
        original: json["original"]);
  }

  static ObjectType _parsetype(String type) {


    switch (type) {
      case "ObjectType.mod":
        return ObjectType.mod;
      case "ObjectType.resource":
        return ObjectType.resource;
      case "ObjectType.shader":
        return ObjectType.shader;
      case "ObjectType.world":
        return ObjectType.world;
      default:
        return ObjectType.modpack;
    }
  }

  UMF copyWith({
    String? name,
    String? versionName,
    String? author,
    String? description,
    int? downloads,
    int? likes,
    List<dynamic>? categories,
    String? icon,
    String? body,
    String? modloader,
    String? MLVersion,
    String? MCVersion,
    ObjectType? type,
    String? slug,
    String? providerId,
    Map? original,
  }) {
    return UMF(
        name: name ?? this.name,
        versionName: versionName ?? this.versionName,
        author: author ?? this.author,
        description: description ?? this.description,
        downloads: downloads ?? this.downloads,
        likes: likes ?? this.likes,
        categories: categories ?? this.categories,
        icon: icon ?? this.icon,
        body: body ?? this.body,
        modloader: modloader ?? this.modloader,
        MLVersion: MLVersion ?? this.MLVersion,
        MCVersion: MCVersion ?? this.MCVersion,
        type: type ?? this.type,
        slug: slug ?? this.slug,
        providerId: providerId ?? this.providerId,
        original: original ?? this.original);
  }
}
