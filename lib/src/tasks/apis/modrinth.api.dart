import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/installer/modrinth/modrinth_install.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';


class ModrinthApi implements Api {
  int limit = 50;
  int offset = 50;
  List _facet = [];

  ModrinthApi() {
    _facet = jsonDecode('[["project_type:modpack"], ["categories:forge", "categories:fabric"]]');
  }

  @override
  String query = "";
  @override
  String version = "";

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
    var res = await http.get(Uri.parse(
        'https://api.modrinth.com/v2/search?query=$query&facets=${jsonEncode(_facet)}&index=relevance&limit=$limit'));

    return jsonDecode(utf8.decode(res.bodyBytes))["hits"];
  }

  @override
  getDownloaderObject() {
    return ModrinthInstaller();
  }

  @override
  getMoreModpacks() async {
    String ver = '["versions:$version"]';
    var res = await http.get(Uri.parse(
        'https://api.modrinth.com/v2/search?query=$query&offset=$offset&facets=[["project_type:modpack"], ["categories:forge", "categories:fabric"]]&index=relevance&limit=$limit'));
    offset += limit;
    return jsonDecode(utf8.decode(res.bodyBytes))["hits"];
  }

  @override
  getModpack(String id) async {
    var res = await http.get(Uri.parse('https://api.modrinth.com/v2/project/$id'));
    return jsonDecode(utf8.decode(res.bodyBytes));
  }


  @override
  Future<String> getModpackName(Map modpackData) async {
    if (modpackData["title"] != null) {
      return modpackData["title"];
    } else {
      Map project = await getModpack(modpackData["project_id"]);

      return project["title"];
    }
  }

  @override
  Future<List<String>> getCategories() async {
    var res = await http.get(Uri.parse('https://api.modrinth.com/v2/tag/category'));

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
    var res = await http.get(Uri.parse('https://api.modrinth.com/v2/tag/game_version'));

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
  UMF convertToUMF(Map modpackData) {
    modpackData["name"] = modpackData["name"] ?? modpackData["title"];
    print(modpackData);

    return UMF(
        name: modpackData["title"].toString(),
        author: modpackData["author"].toString(),
        description: modpackData["description"].toString(),
        downloads: modpackData["downloads"],
        likes: modpackData["follows"],
        categories: modpackData["categories"],
        icon: modpackData["icon_url"],
        modloader: "",
        MLVersion: "",
        MCVersion: modpackData["latest_version"],
        original: modpackData);
  }



  @override
  getTitlename() {
    return "Modrinth";
  }
}
