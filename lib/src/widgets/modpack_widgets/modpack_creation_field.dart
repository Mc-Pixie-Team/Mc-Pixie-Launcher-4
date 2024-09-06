import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mclauncher4/src/app.dart';
import 'package:mclauncher4/src/tasks/install_controller.dart';
import 'package:mclauncher4/src/tasks/installs/install_model.dart';
import 'package:mclauncher4/src/tasks/models/modloader_type.dart';
import 'package:mclauncher4/src/tasks/models/object_type.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:mclauncher4/src/widgets/components/customized_dropdown_menu.dart';
import 'package:mclauncher4/src/widgets/components/editable_text_field.dart';
import 'package:mclauncher4/src/widgets/divider.dart' as Divider;
import 'package:mclauncher4/src/widgets/rounded_text_button.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class ModpackCreationField extends StatefulWidget {
  const ModpackCreationField({Key? key}) : super(key: key);

  @override
  _ModpackCreationFieldState createState() => _ModpackCreationFieldState();
}

class _ModpackCreationFieldState extends State<ModpackCreationField> {
  ModloaderType mloader = ModloaderType.forge;

  String mcVersion = "";
  String mlVersion = "";
  List<String> mcVersions = [];
  List<String> mlVersions = [];

  String mpName = "";
  String iconPath = "";

  late TextEditingController _controller;
  late TextEditingController _controllerSecondary;

  bool isPicking = false;

  late Map<ModloaderType, Future<dynamic> Function(String)> modloaders;

  _createModpack() async{
    if (mcVersion.isEmpty || mcVersions.isEmpty || isPicking) return;
    isPicking = true;
    Navigator.pop(context);

    var uuid = Uuid().v1();

    try {
     await Utils.copyFile(source: File(iconPath), destination: File(p.join(getInstancePath(), uuid.toString(), "icon.png")));
    }catch (e) {
      print(e);
      return;
    }
    

    UMF modpackData = UMF(
        name: mpName.isEmpty ? "MyModpack" : mpName,
        author: "ME",
        description: "",
        processId: uuid,
        downloads: 1,
        modloader: mloader,
        MLVersion: mlVersion,
        MCVersion: mcVersion,
        type: ObjectType.modpack,
        slug: uuid,
        original: {});

      
    var installController = InstallController(
      processid: uuid,
        installState: InstallState.fetching,
        installObjectHandler: GlobalObjectHandler.handler,
        modpackData: modpackData);
    GlobalObjectHandler.handler.installControllers.add(installController);
    installController.install();
    isPicking = false;
  }

  Future _getMinecraftVersions() async {
    mcVersions.clear();
    final res = await http.get(Uri.parse(
        'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json'));
    final hits = jsonDecode(utf8.decode(res.bodyBytes))["versions"];

    for (var hit in hits) {
      if (hit["type"] == "release") {
        mcVersions.add(hit["id"]);
      }
    }
    mcVersion = mcVersions.first;
    await _changeModloader(mloader);
  }

  Future _vanilla(String a) async {
    mlVersion = "";
    mcVersion = a;
    _controller.text = "";
  }

  @override
  initState() {
    modloaders = {
      ModloaderType.forge: _getForgeVersions,
      ModloaderType.fabric: _getFabricVersions,
      ModloaderType.vanilla: _vanilla
    };

    _controller = TextEditingController();
    _controllerSecondary = TextEditingController();

    super.initState();
    _getMinecraftVersions();
  }

  Future _getForgeVersions(String version) async {
    print("getForge");

    final res = await http.get(Uri.parse(
        'https://files.minecraftforge.net/net/minecraftforge/forge/maven-metadata.json'));
    final hits = jsonDecode(utf8.decode(res.bodyBytes))[version];
    if (hits == null) throw "SELECT VALID VERSION";

    for (var hit in hits) {
      mlVersions.add((hit as String).split("-")[1]);
    }
    mlVersion = mlVersions.first;
  }

  Future _getFabricVersions(String version) async {
    print("getFabric");

    final res = await http.get(
        Uri.parse('https://meta.fabricmc.net/v2/versions/loader/$version'));
    if (res.statusCode != 200) throw "COULD NOT FIND FABRIC VERSION";

    final hits = jsonDecode(utf8.decode(res.bodyBytes));
    for (var hit in hits) {
      if (hit["intermediary"]["version"] == version) {
        mlVersions.add(hit["loader"]["version"]);
      }
    }
    mlVersion = mlVersions.first;
  }

  _changeModloader(ModloaderType value) async {
    if (mcVersion.isEmpty) return;

    setState(() {
      mlVersions.clear();
    });
    try {
      await modloaders[value]!.call(mcVersion);
      mloader = value;
    } catch (e) {
      for (var key in modloaders.keys) {
        try {
          await modloaders[key]!.call(mcVersion);
          mloader = key;
          break;
        } catch (e) {
          continue;
        }
      }
    }

    setState(() {});
  }

  _onImagePick() async{
    isPicking = true;
FilePickerResult? result = await FilePicker.platform.pickFiles(
  allowMultiple: false,
  type: FileType.image,
  lockParentWindow: true,
  dialogTitle: "Pick your Modpack Image."
  );

if(result == null) {
  isPicking = false;
  return;
} 
iconPath = result.paths.first!;
isPicking = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      width: 430,
      height: 660,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
          border:
              Border.all(width: 1.0, color: Color.fromARGB(255, 56, 56, 56))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create your modpack.",
            style: Theme.of(context).typography.black.headlineSmall,
          ),
          SizedBox(
            height: 10,
          ),
          Divider.CustomDivider(
            size: 0,
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(onTap: () => _onImagePick(), child: MouseRegion(cursor: SystemMouseCursors.click, child: Container(
                height: 130,
                width: 130,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(18)),
              ))),
              SizedBox(
                width: 20,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Modpack Name:",
                      style: Theme.of(context).typography.black.labelLarge),
                  SizedBox(
                    height: 6,
                  ),
                  Material(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                      child: TextField(
                        onChanged: (value) => mpName = value,
                        autocorrect: false,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(18),
                        ],
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context)
                                .typography
                                .black
                                .labelMedium!
                                .color!
                                .withOpacity(0.86)),
                        autofocus: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(8.0),
                          hintStyle:
                              Theme.of(context).typography.black.bodyMedium,
                          border: InputBorder.none,
                          hintText: 'Ex: MyModpack',
                        ),
                      )),
                ],
              ))
            ],
          ),
          SizedBox(
            height: 35,
          ),
          Text("Minecraft Version:",
              style: Theme.of(context).typography.black.labelLarge),
          SizedBox(
            height: 6,
          ),
          CustomizedDropdownMenu(
              controller: _controllerSecondary,
              onSelected: (p0) {
                if (p0 == null) {
                  _controllerSecondary.text = mcVersion;
                  return;
                }
                ;
                mcVersion = p0;
                _changeModloader(mloader);
              },
              initialSelection: mcVersion,
              enabled: mcVersions.isNotEmpty,
              items: mcVersions),
          SizedBox(
            height: 25,
          ),
          Text("Modloader type:",
              style: Theme.of(context).typography.black.labelLarge),
          SizedBox(
            height: 6,
          ),
          Material(
              type: MaterialType.transparency,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                    modloaders.keys.length,
                    (index) => Row(children: [
                          SizedBox(
                            width: 3,
                          ),
                          Radio(
                              value: modloaders.keys.toList()[index],
                              groupValue: mloader,
                              onChanged: (value) => _changeModloader(
                                  modloaders.keys.toList()[index])),
                          Text(
                              ModloaderTypeTools.toName(
                                  modloaders.keys.toList()[index]),
                              style: Theme.of(context)
                                  .typography
                                  .black
                                  .labelMedium),
                        ])),
              )),
          SizedBox(
            height: 25,
          ),
          ...(mloader == ModloaderType.vanilla
              ? [SizedBox.shrink()]
              : [
                  Text("Modloader Version:",
                      style: Theme.of(context).typography.black.labelLarge),
                  SizedBox(
                    height: 6,
                  ),
                  CustomizedDropdownMenu(
                      onSelected: (p0) {
                        if (p0 == null) {
                          _controller.text = mlVersion;
                          return;
                        }
                        ;
                        mlVersion = p0;
                      },
                      initialSelection: mlVersion,
                      controller: _controller,
                      enabled: mlVersions.isNotEmpty,
                      items: mlVersions),
                ]),
          Expanded(child: SizedBox.expand()),
          Divider.CustomDivider(
            size: 0,
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                  onTapUp: (details) => Navigator.of(context).pop(),
                  child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: SizedBox(
                          height: 50,
                          width: 140,
                          child: Center(
                              child: Text(
                            "Cancle",
                            style:
                                Theme.of(context).typography.black.titleMedium,
                          ))))),
              RoundedTextButton(
                overlayColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                color: Theme.of(context).colorScheme.primary,
                height: 50,
                width: 140,
                text: "Create",
                onTap: () {
                  _createModpack();
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
