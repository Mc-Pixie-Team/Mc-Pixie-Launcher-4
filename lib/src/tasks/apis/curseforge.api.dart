import 'dart:convert';

import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/models/object_type.dart';
import 'package:mclauncher4/src/tasks/provider_installs/curseforge/curseforge_install.dart';
import 'package:mclauncher4/src/tasks/provider_installs/provider_installer.dart';
import 'package:mclauncher4/src/tasks/models/dumf_model.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:http/http.dart' as http;


class CurseforgeApi implements Api {
  @override
  String query = "";

  @override
  String? version = "";

  @override
  ObjectType type = ObjectType.modpack;

  Map<String, String> userHeader = {
    "Content-type": "application/json",
    "Accept": "application/json",
    "x-api-key":
        "\$2a\$10\$zApu4/n/e1nylJMTZMv5deblPpAWUHXc226sEIP1vxCjlYQoQG3QW",
  };

  final baseUrl = "https://api.curseforge.com";

  int index = 0;
  int pageSize = 50;
  List categoriesSearch = [];
  
  String getClassid() {
        var classid;
    switch(this.type) {
      case ObjectType.mod:
        classid = 6;
      case ObjectType.shader:
        classid =  6552;
      case ObjectType.resource:
        classid = 12;
      case ObjectType.world:
        classid = 17;
      default:
        classid = 4471;
    }
    return classid.toString();
  } 

  


  @override
  void setObjectType(ObjectType type) {
    this.type = type;
  }

  @override
  void addCategory(String name) {
    categoriesSearch.add(name);
  }

  @override
  UMF convertToLiteUMF(Map modpackData) {
    List categories = List.generate(modpackData["categories"].length,
        ((index) => modpackData["categories"][index]["name"]));

    return UMF(
        original: modpackData,
        name: modpackData["name"],
        slug: modpackData["slug"],
        description: modpackData["summary"],
        downloads: modpackData["downloadCount"],
        icon: modpackData["logo"]["thumbnailUrl"],
        author: modpackData["authors"][0]["name"],
        categories: categories,
        MCVersion: modpackData["latestFiles"][0]["gameVersions"][0],
        providerId: getidname,
        type: this.type);
  }

  @override
  Future<List<String>> getAllMV() async {
    final res = await http.get(Uri.parse('$baseUrl/v1/minecraft/version'),
        headers: userHeader);
    final hits = jsonDecode(utf8.decode(res.bodyBytes))["data"];

    List<String> versions =
        List.generate(hits.length, (index) => hits[index]["versionString"]);

    return versions;
  }

  Future<List> _requestCategories() async {

    final res = await http.get(
        Uri.parse('$baseUrl/v1/categories?gameId=432&classId=${getClassid()}'),
        headers: userHeader);
    final hits = await jsonDecode(utf8.decode(res.bodyBytes))["data"];
    return hits;
  }

  @override
  Future<List<String>> getCategories() async {
    final hits = await _requestCategories();

    List<String> categories = [];
    for (var version in hits) {
      categories.add(version["name"]);
    }

    return categories;
  }

  @override
  Future<DUMF> getDUMF(Map modpackData) async {
    List<UMF> versions = [];

    final res = await http.get(
        Uri.parse('$baseUrl/v1/mods/${modpackData["id"]}/files'),
        headers: userHeader);
    final hits = await jsonDecode(utf8.decode(res.bodyBytes))["data"] as List;
    print(modpackData["id"]);
    final res2 = await http.get(
        Uri.parse('$baseUrl/v1/mods/${modpackData["id"]}/description'),
        headers: userHeader);
    final body = await jsonDecode(utf8.decode(res2.bodyBytes))["data"];
    print(hits[1]);
    for (var hit in hits) {
      if (hit["isServerPack"]) continue;

      String mcVersion =
          hit["sortableGameVersions"][0]["gameVersionPadded"] == "0"
              ? hit["sortableGameVersions"][1]["gameVersionName"]
              : hit["sortableGameVersions"][0]["gameVersionName"];

      versions.add(UMF(
        providerId: getidname,
        original: hit,
        name: modpackData["name"],
        slug: modpackData["slug"],
        versionName: hit["displayName"],
        downloads: hit["downloadCount"],
        icon: modpackData["logo"]["thumbnailUrl"],
        author: modpackData["authors"][0]["name"],
        MCVersion: mcVersion,
        type: this.type
      ));
    }

    return DUMF(
        name: modpackData["name"],
        description: modpackData["summary"],
        downloads: modpackData["downloadCount"],
        icon: modpackData["logo"]["thumbnailUrl"],
        author: modpackData["authors"][0]["name"],
        versions: versions,
        original: modpackData,
        body: body);
  }

  @override
  Future<UMF> getLatestModpackVersionFromLiteUMF(UMF umf) async {
    if (umf.original["modId"] != null)
      return umf; //if there are dependencies its not the lite version from the start anymore
    Map? modpackVersion =
        (umf.original["latestFiles"] as List).firstWhere((element) {
      print(element["releaseType"]);
      return element["releaseType"] == 1;
    }, orElse: () => null); // gets the newest version of the modpack

    if (modpackVersion == null) {
      modpackVersion = umf.original["latestFiles"][0];
    }

    final res2 = await http.get(
        Uri.parse('$baseUrl/v1/mods/${modpackVersion!["modId"]}/description'),
        headers: userHeader);
    final body = await jsonDecode(utf8.decode(res2.bodyBytes))["data"];

    String mcVersion =
        modpackVersion!["sortableGameVersions"][0]["gameVersionPadded"] == "0"
            ? modpackVersion["sortableGameVersions"][1]["gameVersionName"]
            : modpackVersion["sortableGameVersions"][0]["gameVersionName"];

    return UMF(
        providerId: getidname,
        original: modpackVersion,
        categories: umf.categories,
        description: umf.description,
        name: umf.original["name"],
        slug: umf.slug,
        versionName: modpackVersion["displayName"],
        downloads: modpackVersion["downloadCount"],
        icon: umf.original["logo"]["thumbnailUrl"],
        author: umf.original["authors"][0]["name"],
        body: body,
        MCVersion: mcVersion,
        type: this.type
      );
  }

  @override
  ProviderInstaller getDownloaderObject() {
    //getDownloaderObject
    return CurseforgeInstaller();
  }

  @override
  getModpackList() async {
    print("get list");
    
    List categories = [];

    if (!categoriesSearch.isEmpty) {
      print("need to search for cate");
      List hits = await _requestCategories();

      for (String cate in categoriesSearch) {
        for (var hit in hits) {
          if (hit["name"] == cate) {
            categories.add(hit["id"]);
          }
        }
      }
    }

    
     print(index);
    String url =
        '$baseUrl/v1/mods/search?index=$index&pageSize=$pageSize&gameId=432&sortField=1&sortOrder=desc&classId=${getClassid()}&searchFilter=$query&gameVersion=${this.version}&categoryIds=$categories';
    print(url);
    final res = await http.get(Uri.parse(url), headers: userHeader);
     index += pageSize;
    print(res.statusCode);
    final hits = jsonDecode(utf8.decode(res.bodyBytes))["data"];
   

    return hits;
  }


  @override
  String getTitlename() {
    return "Curseforge";
  }

  @override
  get getidname => "curseforge";

  @override
  void removeCategory(String name) {
    categoriesSearch.remove(name);
  }

  @override
  void searchMV(String version) async {
    this.version = version;
  }
}
