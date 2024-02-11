import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/fabric/fabric.dart';
import 'package:mclauncher4/src/tasks/forge/forge.dart';
import 'package:mclauncher4/src/tasks/installer/modrinth/modrinth_install.dart';
import 'package:mclauncher4/src/tasks/models/dumf_model.dart';
import 'package:mclauncher4/src/tasks/models/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:mclauncher4/src/tasks/modloaders.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:path/path.dart' as path;

class ModrinthApi implements Api {
  int limit = 50;
  int offset = 50;
  List _facet = [];

  ModrinthApi() {
    _facet = jsonDecode(
        '[["project_type:modpack"], ["categories:forge", "categories:fabric"]]');
  }

  @override
  String query = "";
  @override
  String? version;

  @override
  get getidname => "modrinth";

  @override
  void addCategory(String name, String oldname) {
    removeCategory(oldname);
    _facet.add(["categories:$name"]);
  }

  @override
  void searchMV(String version) {
    if ((_facet.first.last).startsWith("versions:")) {
      _facet.removeAt(0);
    }

    this.version = version;

    if (version != "") {
      _facet.insert(0, ["versions:$version"]);
    }
  }

  @override
  void removeCategory(String name) {
    List facetmirror = [];

    facetmirror.addAll(_facet);
    for (List types in facetmirror) {
      List typesmirror = [];
      typesmirror.addAll(types);
      for (String stringType in typesmirror) {
        if (types.length == 0) {
          _facet.remove(types);
        }
        if (stringType == "categories:$name") {
          types.remove(stringType);
          if (types.length == 0) {
            _facet.remove(types);
          }
          return;
        }
      }
    }
  }


  @override
  getModpackList() async {
    // print(
    //     'https://api.modrinth.com/v2/search?query=$query&facets=${jsonEncode(_facet)}&index=relevance&limit=$limit');
    List<Map> modpacksproc = [];
    final res = await http.get(Uri.parse(
        'https://api.modrinth.com/v2/search?query=$query&facets=${jsonEncode(_facet)}&index=relevance&limit=$limit'));
    final hits = jsonDecode(utf8.decode(res.bodyBytes))["hits"];

 
    return hits;
  }

  @override
  getDownloaderObject() {
    return ModrinthInstaller();
  }

  @override
  getMoreModpacks() async {
    var res = await http.get(Uri.parse(
        'https://api.modrinth.com/v2/search?query=$query&offset=$offset&facets=[["project_type:modpack"], ["categories:forge", "categories:fabric"]]&index=relevance&limit=$limit'));
    offset += limit;
    return jsonDecode(utf8.decode(res.bodyBytes))["hits"];
  }

  @override
  getModpack(String id) async {
    var res =
        await http.get(Uri.parse('https://api.modrinth.com/v2/project/$id'));
    return jsonDecode(utf8.decode(res.bodyBytes));
  }


  @override
  Future<List<String>> getCategories() async {
    var res =
        await http.get(Uri.parse('https://api.modrinth.com/v2/tag/category'));

    List allMCcatergories = jsonDecode(utf8.decode(res.bodyBytes));
    List<String> return_value = [];

    for (Map i in allMCcatergories) {
      if (i["project_type"] == "modpack" && i["header"] == "categories") {
        return_value.add(i["name"]);
      }
    }

    return return_value;
  }

  @override
  Future<List<String>> getAllMV() async {
    var res = await http
        .get(Uri.parse('https://api.modrinth.com/v2/tag/game_version'));

    List allMCversions = jsonDecode(utf8.decode(res.bodyBytes));
    List<String> return_value = [];

    for (var i in allMCversions) {
      if (i["major"]) {
        return_value.add(i["version"]);
      }
      continue;
    }

    return return_value;
  }

  @override
  Future<Map> getMMLVersion(
    String instanceName,
  ) async {
    late ModloaderVersion modloaderVersion;
    late Modloader modloader;
    String destination =
        path.join(getInstancePath(), instanceName, "modrinth.index.json");
    Map depend =
        (jsonDecode(await File(destination).readAsString()))["dependencies"];

    if (depend["fabric-loader"] != null) {
      modloader = Fabric();
      modloaderVersion = ModloaderVersion.parse(depend["fabric-loader"]);
    } else if (depend["forge"] != null) {
      modloader = Forge();
      modloaderVersion = ModloaderVersion.parse(depend["forge"]);
    }

    return {"modloader": modloader, "modloaderVersion": modloaderVersion};
  }

  @override
  UMF convertToUMF(Map modpackData) {
    modpackData["name"] = modpackData["name"] ?? modpackData["title"];

    return UMF(
        name: modpackData["title"].toString(),
        author: modpackData["author"].toString(),
        description: modpackData["description"].toString(),
        downloads: modpackData["downloads"],
        likes: modpackData["follows"],
        categories: modpackData["categories"],
        icon: modpackData["icon_url"],
        modloader: ["Fabric"],
        MLVersion: null,
        MCVersion: modpackData["latest_version"],
        original: modpackData);
  }

  Future<List> _getMultipleVersion(List<dynamic> verisons) async {
    var res = await http
        .get(Uri.parse('https://api.modrinth.com/v2/versions?ids=${jsonEncode(verisons)}'));
    // TODO: implement getModpack
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

      Future<Map<String, dynamic>> _getModpack(String id) async {
    var res = await http.get(Uri.parse('https://api.modrinth.com/v2/project/$id'));
    return jsonDecode(utf8.decode(res.bodyBytes));
  }



  @override
  Future<DUMF> getDUMF(Map modpackData) async {
    List<UMF> versions = [];

    modpackData =await _getModpack(modpackData["project_id"]);
    List rawVersion = await _getMultipleVersion(modpackData["versions"]);

    for (Map version in rawVersion){
  versions.add(UMF(
          icon: modpackData["icon_url"],
          MCVersion: version["game_versions"].last,
          modloader: Utils.listTOListString(version["loaders"]),
          name: version["name"].toString(),
          description: modpackData["description"].toString(),
          downloads: version["downloads"],
          original: version));
    }
   versions.sort((a, b) {
    if(Version.parse(a.MCVersion!) > Version.parse(b.MCVersion!) ) return -1;
    if(Version.parse(a.MCVersion!) < Version.parse(b.MCVersion!) ) return 1;
    if(Version.parse(a.MCVersion!) == Version.parse(b.MCVersion!) ) return 0;
    throw "cannot parse Version";
   },);
  
    return DUMF(
      name: modpackData["title"].toString(),
      author: modpackData["author"].toString(),
      description: modpackData["description"].toString(),
      downloads: modpackData["downloads"],
      likes: modpackData["follows"],
      categories: modpackData["categories"],
      icon: modpackData["icon_url"],
      versions: versions,
      original: modpackData,
    );
  }

  @override
  getTitlename() {
    return "Modrinth";
  }
}
