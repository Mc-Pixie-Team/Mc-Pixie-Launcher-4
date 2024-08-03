
import 'package:mclauncher4/src/tasks/provider_installs/provider_installer.dart';
import 'package:mclauncher4/src/tasks/models/dumf_model.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';


abstract class Api {
  /// pls pay attention to the functionality and inheritance of the ModListPage and the InstallController
  /// (debug mode is highly recommended)

  /// for any further investigation, you can look in the already existing implementations of some providers

  String? version = "";
  String query = "";

  //Is the title name of the Provider (ex: Modrinth, Curseforge)
  String getTitlename();

  //gets the id of the provider (ex: modrinth)
  //This ID must be able to be found by the apihandler
  get getidname;

  //This method should change the API query to remove
  // a specific tag or category (ex: technology, magic) from it
  void removeCategory(String name);

  //This method should add a category to the Search query of the provider
  void addCategory(String name, String oldtext);

  //This method should change the API query to search for a specific minecraft version.
  void searchMV(String version);

  //The method is called, when the ModList reached its limits, it should
  //return List of a specific amount of modpacks, based on the limit and offset
  //the user set
  Future<List> getMoreModpacks();

  //The method should return all minecraft version, that the provider has to offer
  Future<List<String>> getAllMV();

  //its called in the init, it should return a List of a specific amount of modpacks,
  //based on the limit the user set
  getModpackList();

  //This methode should return a sperate download object you created to download modpacks, if
  //thats not the case just return your custom api class
  ProviderInstaller getDownloaderObject();

  Future<List<String>> getCategories();

  UMF convertToLiteUMF(Map modpackData);

  Future<DUMF> getDUMF(Map modpackData);

  Future<UMF> getLatestModpackVersionFromLiteUMF(UMF dum);
}
