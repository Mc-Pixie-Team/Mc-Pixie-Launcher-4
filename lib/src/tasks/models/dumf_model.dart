import 'package:mclauncher4/src/tasks/models/umf_model.dart';

class DUMF {
  DUMF({
    this.name,
    this.author,
    this.description,
    this.downloads,
    this.likes,
    this.categories,
    this.icon,
    this.body,
    required this.versions,
    required this.original,
  });

  String? name;
  String? author;
  String? description;
  String? body;
  int? downloads;
  int? likes;
  List<dynamic>? categories;
  String? icon;
  List<UMF> versions;
  Map original;

  static toJson(DUMF umf) {
    return {
      "name": umf.name,
      "author": umf.author,
      "description": umf.description,
      "downloads": umf.downloads,
      "likes": umf.likes,
      "categories": umf.categories,
      "icon": umf.icon,
      "versions": umf.versions,
      "original": umf.original,
      "body": umf.body
    };
  }

  static parse(Map json) {

    List<String> modloaderlist = List.generate((json["modloader"] as List).length, (index) => (json["modloader"] as List)[index].toString());

    return DUMF(
      
    name: json["name"],
    author: json["author"],
    description:  json["description"],
    downloads: json["downloads"],
    likes: json["likes"],
    categories: json["categories"],
    icon: json["icon"],
   original: json["original"],
   versions: json["verions"],
   body: json["body"]
  
    );
  }
}
