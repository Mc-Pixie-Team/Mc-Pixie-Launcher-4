import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/app.dart';
import 'package:mclauncher4/src/pages/installed_modpacks_handler.dart';
import 'package:mclauncher4/src/tasks/Models/isolate_message.dart';
import 'package:mclauncher4/src/tasks/Models/start_message.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/models/navigator_key.dart';
import 'package:mclauncher4/src/tasks/models/value_notifier_list.dart';

import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:mclauncher4/src/tasks/installs/install_model.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/widgets/cards/installed_card.dart';
import 'package:mclauncher4/src/widgets/side_panel/side_panel.dart';
import 'package:mclauncher4/src/widgets/side_panel/taskwidget.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class InstallController {
  Api handler;
  UMF modpackData;
  String? processid;
  late InstallModel installModel;
  BuildContext? context;
  InstallState? installState;
  bool isVersion;
  ValueNotifierList _stdout = ValueNotifierList([]);
  InstallController(
      {required this.handler,
      required this.modpackData,
      this.processid,
      this.isVersion = true,
      this.installState,
      this.replace = true}) {
    installModel = InstallModel();
    processid = processid ?? const Uuid().v1();
    if (installState != null) {
      installModel.setInstallState(installState!);
    }
  }

  bool replace;
  String get processId => processid!;
  ValueNotifierList get stdout => _stdout;
  Isolate? _isolate;
  Process? _result;

  static int instances = 0;

  onHandleStdout(Iterable<int> out) {
    _stdout.add(String.fromCharCodes(out));
  }

  void start() async {
    installModel.setInstallState(InstallState.fetching);
    installModel.setState("launching Minecraft");
    setUIChanges();

    _result =
        await handler.getDownloaderObject().start(processId, installModel);

    await Future.delayed(Duration(milliseconds: 300));

    _result!.stdout.listen(onHandleStdout);
    _result!.stderr.listen(onHandleStdout);

    _result!.exitCode.then((value) {
      installModel.setInstallState(InstallState.installed);

      removeUIChanges();
    });
  }

  void cancel() {
    print("killing isolate");
    if (_result != null) {
      _result!.kill();
      installModel.setInstallState(InstallState.installed);
      return;
    }

    if (_isolate == null) {
      print("cant kill Isolate");
      return;
    }

    _isolate!.kill(priority: Isolate.immediate);

    //Exception: called from here
    delete();
  }

  void delete() async {
    File manifestfile = File(path.join(getInstancePath(), "manifest.json"));
    List manifest = jsonDecode(await manifestfile.readAsString());
    final dir = Directory(path.join(getInstancePath(), processid));

    manifest.removeWhere((element) {
      print(element["processId"]);
      return element["processId"] == processId;
    });
    await manifestfile.writeAsString(jsonEncode(manifest));

    if (dir.existsSync()) {
      try {
        dir.delete(recursive: true);
      } catch (e) {
        setErrorDialog(context, e.toString());
      }
    }

    removeFromInstallList();
    print('deleted');
    installModel.setInstallState(InstallState.notInstalled);
  }

  void install({String? version}) async {
    print("Installing with:" + handler.getTitlename());
    print('start download');
    installModel.setInstallState(InstallState.fetching);
    installModel.setState("Installing Project");



    if (!isVersion) {
      print("getting newest version from Modpack");
      modpackData =
          (await handler.getLatestModpackVersionFromLiteUMF(modpackData));
    }
    setUIChanges();
    print("NAME OF MODPACK:" + modpackData.name!);
    print("NAME OF THE VERSION OF THE MODPACK:" + modpackData.versionName!);
    print(modpackData.icon);

    ///To show the fetching animation
    // await Future.delayed(Duration(milliseconds: 300));

    print(InstallController.instances);
    await waitWhile(() => InstallController.instances > 1);
    InstallController.instances++;

    ReceivePort receivePort = ReceivePort();
    ReceivePort exitPort = ReceivePort();
    ReceivePort errorPort = ReceivePort();
    receivePort.listen((message) {
      if (message is InstallerMessage) {
        installModel.setAll(message.getInstallerState, message.getState, message.getprogress);
      }
    });
    exitPort.listen((message) {
      print(message);
      removeUIChanges();

      InstallController.instances--;

    });
    errorPort.listen((message) {
      installModel.setInstallState(InstallState.notInstalled);

      print("from massenger: " + message.toString());
      setErrorDialog(context, message.toString());
    });

    //compute Isolate
    var rootToken = RootIsolateToken.instance!;

    _isolate = await Isolate.spawn(
      (args) => isolateEntry(args),
      [
        receivePort.sendPort,
        StartMessage(
            token: rootToken,
            handler: handler,
            modpackData: modpackData,
            processId: processId,
            version: version == null ? null : Version.parse(version))
      ],
      onExit: exitPort.sendPort,
      debugName: "Install of $processId",
      onError: errorPort.sendPort,
    );
  }

  static void isolateEntry(List args) async {
    StartMessage startMessage = (args.last as StartMessage);

    BackgroundIsolateBinaryMessenger.ensureInitialized(startMessage.getToken);

    //init for all pathes
    await Path.init();

    var installModel = InstallModel();
    installModel.addListener(() {
      (args.first as SendPort).send(InstallerMessage(
        progress: installModel.progress,
        state: installModel.state,
        installState: installModel.installState,
      ));
    });

    var installer = startMessage.getHandler.getDownloaderObject();
    //Call the main installer
    await installer.install(
        modpackData: startMessage.modpackData.original,
        instanceName: startMessage.processId,
        installModel: installModel);

    List manifest = [];
    try {
      manifest = jsonDecode(File(path.join(getInstancePath(), "manifest.json"))
          .readAsStringSync());
    } catch (e) {
      print("couldnt accses manifest");
    }

    Map manifestaddon = {
      "processId": startMessage.processId,
      "provider": startMessage.handler.getidname
    };
    manifestaddon.addAll(UMF.toJson(startMessage.modpackData));

    manifest.add(manifestaddon);
  
    await File(path.join(getInstancePath(), "manifest.json"))
        .writeAsString(jsonEncode(manifest));

    //Prining finish
      (args.first as SendPort).send(InstallerMessage(
        progress: 100,
        state: "Done",
        installState: InstallState.installed,
      ));

    Isolate.exit();
  }

  ///MARK:  <-------Utils------->

  // Waits until value changes
  Future waitWhile(bool test(), [Duration pollInterval = Duration.zero]) {
    var completer = Completer();
    check() {
      if (!test()) {
        completer.complete();
      } else {
        Timer(pollInterval, check);
      }
    }

    check();
    return completer.future;
  }

  setUIChanges() {
    print(' ab lengt ' +
        InstalledModpacksUIHandler.installCardChildren.value.length.toString());
    if (InstalledModpacksUIHandler.installCardChildren.value
        .where((Widget element) => element.key == Key(processId))
        .isEmpty) {
      print("add to");

      InstalledModpacksUIHandler.installCardChildren.addAll([
        InstalledCard(
          key: Key(processId),
          controllerInstance: this,
        ),
      ]);
    }
    print('lengt ' +
        InstalledModpacksUIHandler.installCardChildren.value.length.toString());

    // Calls SidePanel instance
    StaticSidePanelController.controller.addToTaskWidget(
        AnimatedBuilder(
            animation: installModel,
            builder: (context, child) => TaskwidgetItem(
                  name: modpackData.name!,
                  cancel: cancel,
                  installState: installModel.installState,
                  state: installModel.state,
                  progress: installModel.progress,
                )),
        processId);
  }

  removeFromInstallList() {
    InstalledModpacksUIHandler.installCardChildren
        .removeKeyFromAnimatedBuilder(processId);
  }

  removeUIChanges() {
    StaticSidePanelController.controller.removeFromTaskWidget(processId);
  }

  setErrorDialog(BuildContext? context, String errorDialog) {
    print("printing error");
    showDialog(
        context: context ?? navigatorKey.currentContext!,
        builder: (context) {
          return AlertDialog(
            title: Text("Oh no an Error occured!"),
            content: SelectableText(errorDialog),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close"))
            ],
          );
        });
  }
}
