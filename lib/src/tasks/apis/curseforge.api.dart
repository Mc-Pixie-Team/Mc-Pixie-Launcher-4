import 'dart:convert';

import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/models/dumf_model.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:http/http.dart' as http;

class CurseforgeApi implements Api {
  @override
  String query = "";

  @override
  String? version;


  Map userHeader = {"Content-type": "application/json", "Accept": "application/json"};

  @override
  void addCategory(String name, String oldtext) {
    // TODO: implement addCategory
  }

  @override
  UMF convertToUMF(Map modpackData) {
    // TODO: implement convertToUMF
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getAllMV() {
    // TODO: implement getAllMV
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getCategories() {
    // TODO: implement getCategories
    throw UnimplementedError();
  }

  @override
  Future<DUMF> getDUMF(Map modpackData) {
    // TODO: implement getDUMF
    throw UnimplementedError();
  }

  @override
  getDownloaderObject() {
    // TODO: implement getDownloaderObject
    throw UnimplementedError();
  }

  @override
  Future<Map> getMMLVersion(String instanceName) {
    // TODO: implement getMMLVersion
    throw UnimplementedError();
  }

  @override
  getModpack(String id) {
    // TODO: implement getModpack
    throw UnimplementedError();
  }

  @override
  getModpackList() async {
     final res = await http.get(Uri.parse(
        'https://api.curseforge.com/v1/mods/search?index=0&pageSize=50&gameId=432&sortField=6&sortOrder=desc&classId=4471'));
    final hits = jsonDecode(utf8.decode(res.bodyBytes))["data"];
    
  }


  @override
  Future<List> getMoreModpacks() {
    // TODO: implement getMoreModpacks
    throw UnimplementedError();
  }

  @override
  String getTitlename() {
    
    return "Curseforge";
  }

  @override
  // TODO: implement getidname
  get getidname => throw UnimplementedError();

  @override
  void removeCategory(String name) {
    // TODO: implement removeCategory
  }

  @override
  void searchMV(String version) {
    // TODO: implement searchMV
  }

  
}