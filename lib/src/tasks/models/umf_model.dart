class UMF {
  UMF({
    this.name,
    this.author,
    this.description,
    this.downloads,
    this.likes,
    this.categories,
    this.icon,
    this.modloader,
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
  String? modloader;
  String? MLVersion;
  String? MCVersion;
  Map original;
}
