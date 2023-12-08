import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/get_api_handler.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/install_controller.dart';
import 'package:mclauncher4/src/tasks/models/download_states.dart';
import 'package:mclauncher4/src/widgets/cards/installed_card.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';

class Modpacks {
  static generateManifest() async {
    File manifest = File("${await getInstancePath()}\\manifest.json");
    if (manifest.existsSync()) return;
    manifest.createSync(recursive: true);
    manifest.writeAsStringSync("[]");
  }

  static ValueNotifierList<Widget> globalinstallContollers = ValueNotifierList([]);
  static Future<List<Widget>> getPacksformManifest() async {
    List manifest = jsonDecode(await File('${await getInstancePath()}/manifest.json').readAsString());

    List<Widget> cards = List.generate(manifest.length, (index) {
      Map modpackversion = manifest[index]["providerArgs"];
      Api _handler = ApiHandler().getApi(manifest[index]["provider"]);

      InstallController installcontroller = InstallController(
          processid: manifest[index]["processId"],
          handler: _handler,
          modpackData: _handler.convertToUMF(modpackversion)); // MainState.installed

      return AnimatedBuilder(
        animation: installcontroller,
        key: Key(manifest[index]["processId"]),
        builder: (context, child) => InstalledCard(
          processId: manifest[index]["processId"],
          modpackData: manifest[index],
          state: installcontroller.state,
          progress: installcontroller.progress,
          onCancel: installcontroller.cancel,
          onOpen: () async {
            installcontroller.start();
          },
        ),
      );
    });

    return cards;
  }
}

class ValueNotifierList<Widget> extends ValueNotifier<List<Widget>> {
  ValueNotifierList(List<Widget> value) : super(value);

  void add(Widget valueToAdd) {
    value = [...value, valueToAdd];
    notifyListeners();
  }

  void addAll(List<Widget> valuetoAddall) {
    value.addAll(valuetoAddall);
  }

  void removeLast() {
    value.removeLast();
    notifyListeners();
  }

  void remove(Widget valueToRemove) {
    value = value.where((value) => value != valueToRemove).toList();
    notifyListeners();
  }

  void removeKeyFromAnimatedBuilder(String key) {
    value = value.where((value) {
      if (value is AnimatedBuilder) {
        AnimatedBuilder builder = value as AnimatedBuilder;

        return builder.key != Key(key);
      }
      return false;
    }).toList();
    notifyListeners();
  }
}
