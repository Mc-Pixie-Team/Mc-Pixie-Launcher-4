class UMF {
  UMF({
    this.name,
    this.author,
    this.description,
    this.downloads,
    this.likes,
    this.categories,
    this.icon,
    this.body,
    this.modloader = const [],
    this.MLVersion,
    this.MCVersion,
    required this.original,
  });

  String? name;
  String? author;
  String? description;
  int? downloads;
  int? likes;
  List<dynamic>? categories;
  String? icon;
  String? body;
  List<String> modloader;
  String? MLVersion;
  String? MCVersion;
  Map original;

  static toJson(UMF umf) {
    return {
      "name": umf.name,
      "author": umf.author,
      "description": umf.description,
      "downloads": umf.downloads,
      "likes": umf.likes,
      "categories": umf.categories,
      "icon": umf.icon,
      "modloader": umf.modloader,
      "MLVersion": umf.MLVersion,
      "MCVersion": umf.MCVersion,
      "body": umf.body,
      "original": umf.original
    };
  }

  static parse(Map json) {

    List<String> modloaderlist = List.generate((json["modloader"] as List).length, (index) => (json["modloader"] as List)[index].toString());

    return UMF(
      
    name: json["name"],
    author: json["author"],
    description:  json["description"],
    downloads: json["downloads"],
    likes: json["likes"],
    categories: json["categories"],
    icon: json["icon"],
    body: json["body"],
   modloader: modloaderlist,
    MLVersion: json["MLVersion"],
    MCVersion: json["MCVersion"],
   original: json["original"]
  
    );
  }
}
