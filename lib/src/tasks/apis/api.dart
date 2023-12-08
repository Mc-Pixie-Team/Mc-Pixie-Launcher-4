import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';

abstract class Api {
  /// if you want to change anything here, that's allowed, (MIT)
  /// you just have to make sure that it works with all existing API's.
  /// To do this, you also have to pay attention
  /// to the functionality and inheritance of the ModListPage and the InstallController
  /// (debug mode is highly recommended )

  /// for any further investigation, you can look in the already existing implementations of the providers

  String version = "";
  String query = "";

  //Is the title name of the Provider (ex: Modrinth, Curseforge)

  String getTitlename() {
    throw Exception("Do not call the normal API class, this is just a Template function!");
  }
  //gets the id of the provider (ex: modrinth)
  //This ID must be able to be found by the apihandler

  get getidname => throw Exception("Do not call the normal API class, this is just a Template function!");

  //This method should change the API query to remove
  // a specific tag or category (ex: technology, magic) from it

  void removeCategory(String name) {
    throw Exception("Do not call the normal API class, this is just a Template function!");
  }
  //This method must return the minecraft and modloader version in this format
  // ex: {"version": _version, "modloader": modloaderVersion}. Minecraft version should
  // be in the format "Version" and the modpack version in the format "ModloaderVersion"



  void addCategory(String name, String oldtext) {
    throw Exception("Do not call the normal API class, this is just a Template function!");
  }

  //This method should change the API query to search for a specific minecraft version.

  void searchMV(String version) {
    throw Exception("Do not call the normal API class, this is just a Template function!");
  }

  //The method is called, when the ModList reached its limits, it should
  //return List of a specific amount of modpacks, based on the limit and offset
  //the player set

  Future<List> getMoreModpacks() {
    throw Exception("Do not call the normal API class, this is just a Template function!");
  }

  //based on your format, it will provide a Map, the methode should return the name of a specific modpack
  Future<String> getModpackName(Map v) {
    throw Exception("Do not call the normal API class, this is just a Template function!");
  }

  //The method should return all minecraft version, that the provider has to offer
  Future<List<String>> getAllMV() {
    throw Exception("Do not call the normal API class, this is just a Template function!");
  }

  //its called in the init, it should return a List of a specific amount of modpacks,
  //based on the limit the player set
  getModpackList() {
    throw Exception("Do not call the normal API class, this is just a Template function!");
  }

  //Many modpack providers use a id to identify thier modpacks, you methode should return
  // a modpack based on the id that is provided
  getModpack(String id) {
    throw Exception("Do not call the normal API class, this is just a Template function!");
  }

  //Many modpacks providers divide thier modpacks into versions of it self, this methode


  //This methode should return a sperate download object you created to download modpacks, if
  //thats not the case just return your custom api class
  getDownloaderObject() {
    throw Exception("Do not call the normal API class, this is just a Template function!");
  }

  Future<List<String>> getCategories() {
    throw Exception("Do not call the normal API class, this is just a Template function!");
  }


  UMF convertToUMF(Map modpackData) {
    throw Exception("Do not call the normal API class, this is just a Template function!");
  }

}
