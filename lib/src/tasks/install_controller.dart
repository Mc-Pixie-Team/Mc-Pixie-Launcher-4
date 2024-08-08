import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/app.dart';
import 'package:mclauncher4/src/pages/installed_objects_handlers.dart';
import 'package:mclauncher4/src/tasks/Models/isolate_message.dart';
import 'package:mclauncher4/src/tasks/Models/start_message.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/models/navigator_key.dart';
import 'package:mclauncher4/src/tasks/models/object_type.dart';
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
  String? rootProcessId;
  late InstallModel installModel;
  BuildContext? context;
  InstallState? installState;
  bool isVersion;
  List<VoidCallback> _beforedeletelisteners = [];
  InstallController({
    required this.handler,
    required this.modpackData,
    this.processid,
    this.rootProcessId,
    this.isVersion = true,
    this.installState,
  }) {
    installModel = InstallModel();
    processid = processid ?? const Uuid().v1();
    if (installState != null) {
      installModel.setInstallState(installState!);
    }
  }

  String get processId => processid!;
  String get rootprocessId => rootProcessId!;
  //ValueNotifierList get stdout => _stdout;
  Isolate? _isolate;
  Process? _result;

  static int instances = 0;

  onHandleStdout(Iterable<int> out) {
    //  _stdout.add(String.fromCharCodes(out));
  }


  void changeModpackData(UMF umf) {
    this.modpackData = umf;
    installModel.triggerAll();
  }

  void addBeforeDeleteListener(VoidCallback callback) {
    _beforedeletelisteners.add(callback);
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
    for (var callback in _beforedeletelisteners) {
      callback.call();
    }
    File manifestfile = rootProcessId == null ? File(path.join(getInstancePath(), "manifest.json")) : File(path.join(getInstancePath(), rootProcessId ,"manifest.json"));
    List manifest = jsonDecode(await manifestfile.readAsString());
    final dir = Directory(path.join(getInstancePath(), rootProcessId ?? processid));

    manifest.removeWhere((element) {
      print(element["processId"]);
      return element["processId"] == processId;
    });
    await manifestfile.writeAsString(jsonEncode(manifest));

    removeFromInstallList();
    installModel.setInstallState(InstallState.notInstalled);

    if (dir.existsSync()) {
      try {
        dir.delete(recursive: true);
      } catch (e) {
        setErrorDialog(context, e.toString());
      }
    }
    print('deleted');
  }

  void install({String? version}) async {
    print("Installing with:" + handler.getTitlename());
    print("Starting ProcessID: $processid, with root $rootProcessId ");
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
        installModel.setAll(
            message.getInstallerState, message.getState, message.getprogress);

        if (message.isUMF) {
          modpackData = message.umfData!;
        }
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
            processId: rootProcessId ?? processId,
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
    if(startMessage.getModpackData.type == ObjectType.modpack) {
        await installer.install(
          umfData: startMessage.modpackData,
          instanceName: startMessage.processId,
          installModel: installModel);
    }else {
        await installer.installFile(
          umfData: startMessage.modpackData,
          instanceName: startMessage.processId,
          installModel: installModel);

    }

   
      var manifestPath =  path.join( path.join(getInstancePath(), startMessage.getModpackData.type == ObjectType.modpack ? null : startMessage.getProcessId), "manifest.json"); 
      List manifest = [];
       try {
        manifest = jsonDecode(File(manifestPath)
           .readAsStringSync());
      } catch (e) {
        throw "couldnt accses manifest: $manifestPath";
     }

      manifest.add({
       "processId": startMessage.processId,
       "provider": startMessage.handler.getidname,
       ...UMF.toJson(startMessage.modpackData)
      });
  
      await File(manifestPath)
          .writeAsString(jsonEncode(manifest));
    


    //Prining finish
    (args.first as SendPort).send(InstallerMessage(
      progress: 100,
      state: "Done",
      umfData: startMessage.modpackData,
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
if(modpackData.type == ObjectType.modpack) {
    if (InstalledModpacksHandler.globalInstallControllers.value
        .where((element) => element.processId ==  this.processId)
        .isEmpty) {
      print("add to");

      InstalledModpacksHandler.globalInstallControllers.add(this);
    }
}



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
        rootProcessId ?? processId);
  }

  removeFromInstallList() {
    InstalledModpacksHandler.globalInstallControllers
        .removeProcessIdFormList(processId);
  }

  removeUIChanges() {
    StaticSidePanelController.controller.removeFromTaskWidget(rootProcessId ?? processId);
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
