import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/auth/microsoft.dart';
import 'package:mclauncher4/src/tasks/storrage/secureStorrage.dart';

class MinecraftAccount {
  String name;
  String refreshToken;
  String username;
  String uuid;
  MinecraftAccount({required this.name, required this.refreshToken, required this.username, required this.uuid});
  Map toMap() {
    return {"name": name, "refreshToken": refreshToken, "username": username, "uuid": uuid};
  }

  static parse(Map map) {
    return MinecraftAccount(name: map["name"], refreshToken: map["refreshToken"], username: map["username"], uuid: map["uuid"]);
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
    SecureStorage().writeSecureData("accounts", jsonEncode(saveData));
  }

  Future<List<MinecraftAccount>> getAccounts() async {
    String unparsedData = await SecureStorage().readSecureData("accounts");
    List listData = jsonDecode(unparsedData);
    List<MinecraftAccount> data = [];

    for (var element in listData) {
      data.add(MinecraftAccount.parse(element));
    }
    return data;
  }

  Future<void> addAccount(MinecraftAccount account) async {
    List<MinecraftAccount> accList = await MinecraftAccountUtils().getAccounts();
    bool newAcc = true;
    for (var element in accList) {
      if (element.uuid == account.uuid) {
        newAcc = false;
        break;
      }
    }
    if (newAcc) {
      accList.add(account);
      MinecraftAccountUtils().setStandard(account);
      MinecraftAccountUtils().saveAccounts(accList);
    } else {
      
      print("account already exists! Doing nothing.");
    }
  }

  Future<void> deleteAccount(MinecraftAccount account) async {
    String uuid = account.uuid;
    List<MinecraftAccount> accList = await MinecraftAccountUtils().getAccounts();
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
    try {
      Map loginData = await Microsoft().reAuthenticate(account);
      return {"authToken": loginData["authToken"], "account": account};
    } catch (e) {
      print(e);
      print("user not longer authenticated!!!");
    }
    return {"authToken": null, "account": account};
  }

  Future<void> setStandard(MinecraftAccount account) async {
    await SecureStorage().writeSecureData("standardAccount", account.uuid);
  }

  Future<MinecraftAccount?> getAccountByUUID(String uuid) async {
    List<MinecraftAccount> accounts = await MinecraftAccountUtils().getAccounts();

    MinecraftAccount? account;
    for (var element in accounts) {
      if (element.uuid == uuid) {
        account = element;
      }
    }
    return account;
  }

  Future<MinecraftAccount?> getStandard() async {
    String standardAccUUID = await SecureStorage().readSecureData("standardAccount");
    MinecraftAccount? account = await MinecraftAccountUtils().getAccountByUUID(standardAccUUID);
    return account;
  }

  Future<void> initOnFirstStart() async {
    try {
      SecureStorage().readSecureData("standardAccount");
    } catch (e) {
      await MinecraftAccountUtils().saveAccounts([]);
    }
  }
}

class MinecraftHead extends StatelessWidget {
  const MinecraftHead({
    super.key,
    required this.user,
  });

  final MinecraftAccount user;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
      child: Image.network(
        "https://mc-heads.net/avatar/" + user.uuid,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.cancel_presentation_outlined);
        },
      ),
    );
  }
}
