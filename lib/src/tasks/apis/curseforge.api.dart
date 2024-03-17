import 'dart:convert';

import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/installer/curseforge/curseforge_install.dart';
import 'package:mclauncher4/src/tasks/models/dumf_model.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:http/http.dart' as http;

class CurseforgeApi implements Api {


  @override
  String query = "";

  @override
  String? version = "";

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


  @override
  void addCategory(String name, String oldtext) {
    categoriesSearch.remove(oldtext);
    categoriesSearch.add(name);
  }

  @override
  UMF convertToUMF(Map modpackData) {
    List categories = List.generate(modpackData["categories"].length,
        ((index) => modpackData["categories"][index]["name"]));

    return UMF(
        original: modpackData,
        name: modpackData["name"],
        description: modpackData["summary"],
        downloads: modpackData["downloadCount"],
        likes: 1,
        icon: modpackData["logo"]["thumbnailUrl"],
        author: modpackData["authors"][0]["name"],
        categories: categories,
        MLVersion: null,
        MCVersion: modpackData["latestFiles"][0]["gameVersions"][0]);
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
        Uri.parse('$baseUrl/v1/categories?gameId=432&classId=4471'),
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

      final res2 = await http.get(
        Uri.parse('$baseUrl/v1/mods/${modpackData["id"]}/description'),
        headers: userHeader);
    final body = await jsonDecode(utf8.decode(res2.bodyBytes))["data"];

    for (var hit in hits) {
      if(hit["isServerPack"]) continue;
      versions.add(UMF(
        original: hit,
        name: hit["displayName"],
        downloads: hit["downloadCount"],
        icon: modpackData["logo"]["thumbnailUrl"],
      author: modpackData["authors"][0]["name"],
        MLVersion: null,
        MCVersion: hit["gameVersions"][0],
        ));
    }

    return DUMF(
        name: modpackData["name"],
        description: modpackData["summary"],
        downloads: modpackData["downloadCount"],
        likes: 1,
        icon: modpackData["logo"]["thumbnailUrl"],
        author: modpackData["authors"][0]["name"],
        versions: versions,
        original: modpackData,
        body: body);
  }

  @override
  getDownloaderObject() {
    //getDownloaderObject
    return CurseforgeInstaller();
  }

  @override
  getModpackList() async {
    print("get list");

    List categories = [];

    if(!categoriesSearch.isEmpty) {
      print("need to search for cate");
      List hits = await _requestCategories();

      for (String cate in categoriesSearch) {

        for (var hit in hits) {
          if(hit["name"] == cate) {
            categories.add(hit["id"]);
          }
        }
      }
    }

    String url = '$baseUrl/v1/mods/search?index=0&pageSize=50&gameId=432&sortField=1&sortOrder=desc&classId=4471&searchFilter=$query&gameVersion=${this.version}&categoryIds=$categories';
    print(
        url);
    final res = await http.get(
        Uri.parse(
            url),
        headers: userHeader);
    final hits = jsonDecode(utf8.decode(res.bodyBytes))["data"];
    return hits;
  }

  @override
  Future<List> getMoreModpacks() async{
      index += pageSize;
    
        List categories = [];

    if(categoriesSearch != []) {
      List hits = await _requestCategories();

      for (String cate in categoriesSearch) {

        for (var hit in hits) {
          if(hit["name"] == cate) {
            categories.add(hit["id"]);
          }
        }
      }
    }

    String url = '$baseUrl/v1/mods/search?index=$index&pageSize=$pageSize&gameId=432&sortField=1&sortOrder=desc&classId=4471&searchFilter=$query&gameVersion=${this.version}&categoryIds=$categoriesSearch';
    print(
        url);
    final res = await http.get(
        Uri.parse(
            url),
        headers: userHeader);
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
