import 'package:flutter/material.dart';

class Api {
  String version = "";
  String query = "";
  String getTitlename() {
    throw Exception(
        "Do not call the normal API class, this is just a Template function!");
  }

  get getidname => throw Exception(
      "Do not call the normal API class, this is just a Template function!");

  // getModpack() {
  //   // TODO: implement getModpack
  //   throw "you cannot call api alone";
  // }

  // getModpackVersion() {
  //   // TODO: implement getModpack
  //   throw "you cannot call api alone";
  // }
  void removeCategory(String name) {
    throw Exception(
        "Do not call the normal API class, this is just a Template function!");
  }

  getMMLVersion(modpackVersion, String instanceName, String modloader) {
    throw Exception(
        "Do not call the normal API class, this is just a Template function!");
  }

  void addCategory(String name, String oldtext) {
    throw Exception(
        "Do not call the normal API class, this is just a Template function!");
  }

  void searchMV(String version) {
    throw Exception(
        "Do not call the normal API class, this is just a Template function!");
  }

  getMoreModpacks() {}
  Future<String> getModpackName(Map v) {
    throw Exception(
        "Do not call the normal API class, this is just a Template function!");
  }

  Future<List<String>> getAllMV() {
    throw Exception(
        "Do not call the normal API class, this is just a Template function!");
  }

  getModpackList() {
    throw Exception(
        "Do not call the normal API class, this is just a Template function!");
  }

  getModpack(String id) {
    throw Exception(
        "Do not call the normal API class, this is just a Template function!");
  }

  getModpackVersion(String version) {
    throw Exception(
        "Do not call the normal API class, this is just a Template function!");
  }

  getDownloaderObject() {
    throw Exception(
        "Do not call the normal API class, this is just a Template function!");
  }

  Future<List<String>> getCategories() {
    throw Exception(
        "Do not call the normal API class, this is just a Template function!");
  }
}
