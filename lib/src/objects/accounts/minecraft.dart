import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/objects/minecraftUserDetails.dart';
import 'package:mclauncher4/src/tasks/auth/microsoft.dart';
import 'package:mclauncher4/src/tasks/storage/secure_storage.dart';
import 'package:mclauncher4/src/widgets/internet_connection_checker.dart';
import "package:hive/hive.dart" as Hive;

class MinecraftAccount {
  String name;
  String refreshToken;
  String username;
  String uuid;
  MinecraftUserDetails userDetails;
  MinecraftAccount({required this.name, required this.refreshToken, required this.username, required this.uuid, required this.userDetails});
  Map toMap() {
    return {"name": name, "refreshToken": refreshToken, "username": username, "uuid": uuid, "userDetails": userDetails};
  }

  static parse(Map map) {
    return MinecraftAccount(
        name: map["name"],
        refreshToken: map["refreshToken"],
        username: map["username"],
        uuid: map["uuid"],
        userDetails: MinecraftUserDetails.fromJson(map["userDetails"]));
  }
}

class MinecraftAccountUtils {
  Future<String> getUUID(playername) async {
    String uuid = "";
    var client = HttpClient();
    try {
      HttpClientRequest request = await client.get('https://api.mojang.com/users/profiles/minecraft/', 443, playername);
      // Optionally set up headers...
      // Optionally write to the request object...
      HttpClientResponse response = await request.close();
      // Process the response
      final stringData = await response.transform(utf8.decoder).join();
      // if username not found return empty string
      if (response.statusCode == 200) {
        Map data = jsonDecode(stringData);
        uuid = data["id"];
      }
    } finally {
      client.close();
    }
    return uuid;
  }

  Future<void> saveAccounts(List<MinecraftAccount> accounts) async {
    List saveData = [];
    for (var element in accounts) {
      Map elemNew = element.toMap();
      saveData.add(elemNew);
    }
    await SecureStorage.writeSecureData("account", jsonEncode(saveData));
  }

  Future<List<MinecraftAccount>> getAccounts() async {
    String unparsedData = await SecureStorage.readSecureData("account");
    List listData = jsonDecode(unparsedData);
    List<MinecraftAccount> data = [];

    for (var element in listData) {
      data.add(MinecraftAccount.parse(element));
    }
    return data;
  }

  Future<void> addAccount(MinecraftAccount account) async {
    List<MinecraftAccount> accList = await getAccounts();
    bool newAcc = true;
    for (var element in accList) {
      if (element.uuid == account.uuid) {
        newAcc = false;
        break;
      }
    }
    if (newAcc) {
      accList.add(account);
      await saveAccounts(accList);
      await setStandard(account);
    } else {
      print("account already exists! Doing nothing.");
    }
  }

  Future<void> updateAccount(MinecraftAccount account) async {
    List<MinecraftAccount> accList = await getAccounts();
    List<MinecraftAccount> newAccList = [];
    bool updatedAcc = false;
    for (var element in accList) {
      if (element.uuid == account.uuid) {
        updatedAcc = true;
        newAccList.add(account);
        print("Account Updated!");
      } else {
        newAccList.add(element);
      }
    }
    if (updatedAcc) {
      await saveAccounts(newAccList);
    } else {
      print("Account not found. Nothing Updated!");
    }
  }

  Future<void> deleteAccount(MinecraftAccount account) async {
    String uuid = account.uuid;
    List<MinecraftAccount> accList = await getAccounts();
    bool deletedAcc = false;
    List<MinecraftAccount> newAccList = [];

    for (var element in accList) {
      if (element.uuid != uuid) {
        newAccList.add(element);
      } else {
        deletedAcc = true;
      }
    }

    if (deletedAcc) {
      MinecraftAccountUtils().saveAccounts(newAccList);
    } else {
      print("No Account deleted!");
    }
  }

  Future<Map> reAuthenticateAndUpdateAccount(MinecraftAccount account) async {
    if (InternetConnectionCheckerHelper().hasConnection == false) {
      print("starting Minecraft in OFFLINE mode (NO AUTH-TOKEN)");
      return {"authToken": null, "account": account};
    }
    try {
      Map loginData = await Microsoft().reAuthenticate(account);
      account.userDetails = loginData["userDetails"];
      this.updateAccount(account);
      return {"authToken": loginData["authToken"], "account": account};
    } catch (e) {
      print(e);
      print("user not longer authenticated!!!");
    }
    return {"authToken": null, "account": account};
  }

  Future<void> setStandard(MinecraftAccount account) async {
    await SecureStorage.writeSecureData("standardAccount", account.uuid);
  }

  Future<MinecraftAccount?> getAccountByUUID(String uuid) async {
    List<MinecraftAccount> accounts = await getAccounts();

    MinecraftAccount? account;
    for (var element in accounts) {
      if (element.uuid == uuid) {
        account = element;
      }
    }
    return account;
  }

  Future<MinecraftAccount?> getStandard() async {
    String standardAccUUID = await SecureStorage.readSecureData("standardAccount");
    MinecraftAccount? account = await getAccountByUUID(standardAccUUID);
    return account;
  }

  Future<void> initOnFirstStart() async {
    if (!(await SecureStorage.isKeyRegistered("account"))) {
      await MinecraftAccountUtils().saveAccounts([]);
    }
  }
}

class MinecraftHead extends StatefulWidget {
  const MinecraftHead({
    super.key,
    required this.user,
    this.widht = 100,
    this.height = 100,
    this.onlyFirstLayer = false,
    this.debugDisable = false,
  });
  final double height;
  final double widht;
  final MinecraftAccount user;
  final bool onlyFirstLayer;
  final bool debugDisable;

  @override
  _MinecraftHeadState createState() => _MinecraftHeadState();
}

class _MinecraftHeadState extends State<MinecraftHead> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Skin activeSkin = widget.user.userDetails.skins.where((element) => element.state == "ACTIVE").toList()[0];
    return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
        child: FutureBuilder(
          future: getPlayerHead(activeSkin.url, activeSkin.textureKey, debugDisable: widget.debugDisable, onlyFirstLayer: widget.onlyFirstLayer),
          builder: (context, snapshot) {
            if (snapshot.hasData == true) {
              var data = snapshot.data!;
              return Container(
                  height: widget.height,
                  width: widget.widht,
                  child: Image.memory(
                    data,
                    width: widget.widht,
                    height: widget.height,
                    scale: 8 / widget.height,
                    filterQuality: FilterQuality.none,
                  ));
            }
            return Container(
              height: widget.height,
              width: widget.widht,
              child: Icon(
                Icons.person_rounded,
              ),
            );
          },
        ));
  }
}

Future<Uint8List?> getPlayerHead(String url, String textureKey, {bool debugDisable = false, bool onlyFirstLayer = false}) async {
  Uint8List dataAsUint8List = new Uint8List(0);

  if (debugDisable == true) {
    print("get player head is Disabled");
    return null;
  }

  Hive.Box box = Hive.Hive.box("MinecraftPlayerHeads");
  if (box.containsKey(textureKey) == false) {
    if (InternetConnectionCheckerHelper().hasConnection == false) {
      return null;
    }
    print("loading Skin Texture with textureKey: ${textureKey}");
    var client = HttpClient();

    try {
      HttpClientRequest request = await client.getUrl(Uri.parse(url));

      // Optionally set up headers...
      // Optionally write to the request object...
      HttpClientResponse responseFuture = await request.close();

      // Process the response
      final response = await responseFuture;
      // if username not found return empty string
      var responseData = (await response.toSet());
      List<int> responseDataConc = [];

      for (var element in responseData) {
        responseDataConc.addAll(element);
      }
      dataAsUint8List = Uint8List.fromList(responseDataConc);

/*     List pngSignature = [137, 80, 78, 71, 13, 10, 26, 10];
    bool isPng = false;
    for (var i = 0; i < pngSignature.length; i++) {
      if (pngSignature[i] == responseDataConc[i]) {
        isPng = true;
      } else {
        isPng = false;
      }
    }
    print("contains png: ${isPng}"); */
      img.Image skinImage = img.decodePng(dataAsUint8List)!;
      img.Image layer1Face = img.copyCrop(skinImage, x: 8, y: 8, width: 8, height: 8);
      if (onlyFirstLayer == true) {
        box.put(textureKey, img.encodePng(layer1Face).toList());
        return img.encodePng(layer1Face);
      } else {
        img.Image layer2Face = img.copyCrop(skinImage, x: 40, y: 8, width: 8, height: 8);
        img.Image combinedFace = img.compositeImage(layer1Face, layer2Face);
        box.put(textureKey, img.encodePng(combinedFace).toList());
        return img.encodePng(combinedFace);
      }
    } catch (error) {
      print(error);
      return null;
    } finally {
      client.close();
    }
  } else if (box.containsKey(textureKey) == true) {
    List<int> dataFromBox = box.get(textureKey);
    dataAsUint8List = Uint8List.fromList(dataFromBox);

    return dataAsUint8List;
  } else {
    throw "unknown exception";
  }
}

class MinecraftCape extends StatefulWidget {
  const MinecraftCape({
    super.key,
    required this.user,
    this.widht = 100,
    this.height = 100,
    this.debugDisable = false,
  });
  final double height;
  final double widht;
  final MinecraftAccount user;

  final bool debugDisable;
  @override
  _MinecraftCapeState createState() => _MinecraftCapeState();
}

class _MinecraftCapeState extends State<MinecraftCape> {
  @override
  Widget build(BuildContext context) {
    Cape? cape = null;
    var selCapeList = widget.user.userDetails.capes.where((element) => element.state == "ACTIVE").toList();
    if (selCapeList.length > 0) {
      cape = widget.user.userDetails.capes.where((element) => element.state == "ACTIVE").toList()[0];
    }
    return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
        child: (cape != null)? FutureBuilder(
          future: getPlayerCape(
            cape.url,
            cape.id,
            debugDisable: widget.debugDisable,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData == true) {
              var data = snapshot.data!;
              return Container(
                  height: widget.height,
                  width: widget.widht,
                  child: Image.memory(
                    data,
                    width: widget.widht,
                    height: widget.height,
                    scale: 8 / widget.height,
                    filterQuality: FilterQuality.none,
                  ));
            }
            return Container(
              height: widget.height,
              width: widget.widht,
              child: Icon(
                Icons.person_rounded,
              ),
            );
          },
        ): SizedBox(width: widget.widht,child: Center(child:Text("no cape", style: TextStyle(fontWeight: FontWeight.w500,fontSize: widget.height/9 ),)),));
  }
}

Future<Uint8List?> getPlayerCape(String url, String id, {bool debugDisable = false, bool onlyFirstLayer = false}) async {
  Uint8List dataAsUint8List = new Uint8List(0);

  if (debugDisable == true) {
    print("get player head is Disabled");
    return null;
  }

  Hive.Box box = Hive.Hive.box("MinecraftPlayerCapes");
  print(box.get(id));
  if (box.containsKey(id) == false) {
    if (InternetConnectionCheckerHelper().hasConnection == false) {
      return null;
    }
    print("loading Cape Texture with textureKey: ${id}");
    var client = HttpClient();

    try {
      HttpClientRequest request = await client.getUrl(Uri.parse(url));

      // Optionally set up headers...
      // Optionally write to the request object...
      HttpClientResponse responseFuture = await request.close();

      // Process the response
      final response = await responseFuture;
      // if username not found return empty string
      var responseData = (await response.toSet());
      List<int> responseDataConc = [];

      for (var element in responseData) {
        responseDataConc.addAll(element);
      }
      dataAsUint8List = Uint8List.fromList(responseDataConc);

/*     List pngSignature = [137, 80, 78, 71, 13, 10, 26, 10];
    bool isPng = false;
    for (var i = 0; i < pngSignature.length; i++) {
      if (pngSignature[i] == responseDataConc[i]) {
        isPng = true;
      } else {
        isPng = false;
      }
    }
    print("contains png: ${isPng}"); */
      img.Image capeImage = img.decodePng(dataAsUint8List)!;
      img.Image layer1Cape = img.copyCrop(capeImage, x: 1, y: 1, width: 10, height: 15);

      img.Image layer2Cape = img.copyCrop(capeImage, x: 11, y: 1, width: 10, height: 15);
      img.Image combinedCape = img.compositeImage(layer2Cape, layer1Cape);
      box.put(id, img.encodePng(combinedCape).toList());
      return img.encodePng(combinedCape);
    } catch (error) {
      print(error);
      return null;
    } finally {
      client.close();
    }
  } else if (box.containsKey(id) == true) {
    List<int> dataFromBox = box.get(id);
    print("data from box");

    dataAsUint8List = Uint8List.fromList(dataFromBox);

    return dataAsUint8List;
  } else {
    throw "unknown exception";
  }
}
