import 'package:flutter/material.dart';

class Api {

    
    String version = "";
    String query ="";
  String getTitlename() {
    throw "you cannot call api alone";
  }

  get getidname => throw "";




  // getModpack() {
  //   // TODO: implement getModpack
  //   throw "you cannot call api alone";
  // }

  // getModpackVersion() {
  //   // TODO: implement getModpack
  //   throw "you cannot call api alone";
  // }
 void removeCategory(String name){}
   getMMLVersion(modpackVersion, String instanceName, String modloader){}
   void addCategory(String name, String oldtext) {}
     void searchMV(String version) {

  }
  getMoreModpacks() {}
 Future<String> getModpackName(Map v) { throw "";}
Future<List<String>> getAllMV() { throw "";}
  getModpackList() {}
  getModpack(String id){}
  getModpackVersion(String version){}
  getDownloaderObject() {
    throw '';
  }
 Future<List<String>>  getCategories() {throw "";}

}
