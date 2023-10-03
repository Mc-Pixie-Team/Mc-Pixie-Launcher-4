import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/pages/installedModpacks.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/apis/modrinth.api.dart';
import 'package:mclauncher4/src/tasks/apis/modrinth.download.dart';
import 'package:mclauncher4/src/tasks/downloadState.dart';
import 'package:mclauncher4/src/tasks/fabric/fabric.dart';
import 'package:mclauncher4/src/tasks/forge/forge.dart';
import 'package:mclauncher4/src/tasks/isolateMessage.dart';
import 'package:mclauncher4/src/tasks/minecraft/client.dart';
import 'package:mclauncher4/src/tasks/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/modloaders.dart';
import 'package:mclauncher4/src/tasks/startMessage.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/version.dart';
import 'package:mclauncher4/src/widgets/SidePanel/SidePanel.dart';
import 'package:mclauncher4/src/widgets/SidePanel/taskwidget.dart';
import 'package:uuid/uuid.dart';

class InstallController with ChangeNotifier {
  Modloader? _modloader;
  MainState _mainState = MainState.notinstalled;
  ChangeNotifier _notifierforTask = ChangeNotifier();

  double _progress = 0.0;
  double _mainprogress = 0.0;
  final String _processId = Uuid().v1();
  var _installState;
  late SendPort sendPort;

  get installState => _installState;
  String get processId => _processId;
  double get progress => _progress;
  double get mainprogress => _mainprogress;
  MainState get mainState => _mainState;

  void setTaskWidget() {
    SidePanel().addToTaskWidget(
        AnimatedBuilder(
            animation: _notifierforTask,
            builder: (context, child) => TaskwidgetItem(
                cancel: cancel,
                 mainState: mainState,
                  installState: installState,
                  mainprogress: mainprogress,
                  progress: progress,
                )),
        processId);
  }

  void removeTaskWidget() {
    SidePanel().removeFromTaskWidget(_processId);
  }

  void _callnotifiers() {
    _notifierforTask.notifyListeners();
    notifyListeners();
  }


  void cancel() async {
    sendPort.send(IsolateBreaker());
    Modpacks.globalinstallContollers.removeLast();
    if (await Directory('${await getInstancePath()}\\$processId').exists()) {
      try {
        await Directory('${await getInstancePath()}\\$processId')
          .delete(recursive: true);
      }catch (e) {
        
      }
      
    }

    _mainState = MainState.notinstalled;
    _callnotifiers();
  }

  start(Api _handler, Map modpackVersion) async {
    String mloaderS = modpackVersion["loaders"].first;
    if (mloaderS == "forge") {
      _modloader = Forge();
    } else if (mloaderS == "fabric") {
      _modloader = Fabric();
    }
    if (_modloader == null) throw 'no modloader was found';

    Map versions =
        await _handler.getMMLVersion(modpackVersion, _processId, mloaderS);
    Version version = versions["version"];
    ModloaderVersion modloaderVersion = versions["modloader"];
    _mainState = MainState.running;
    _callnotifiers();
    _modloader!.run(_processId, version, modloaderVersion);
  }

  void install(Api _handler, Map _modpackData) async {
    setTaskWidget();
    _mainState = MainState.downloadingML;
    _callnotifiers();


        Map modpackproject = await _handler.getModpack(_modpackData["project_id"]);
    Map modpackVersion = await _handler
        .getModpackVersion((modpackproject["versions"] as List).last);

    ReceivePort receivePort = ReceivePort();
    ReceivePort exitPort = ReceivePort();

    await Isolate.spawn(
        Installer.init,
        [
          receivePort.sendPort,
          StartMessage(
              handler: _handler,
              modpackData: modpackVersion,
              processId: _processId)
        ],
        onExit: exitPort.sendPort);

    receivePort.listen((message) {
      if (message is InstallerMessage) {
        if (message.isSendPort) {
          sendPort = message.getsendPort!;
        }
        _progress = message.getprogress;
        _mainprogress = message.getmainprogress;
        _installState = message.getinstallState;
        _mainState = message.getmainState;
        _callnotifiers();
      }
    });

    exitPort.listen((message) {
      removeTaskWidget();
    });
  }
}

class Installer {
  Modloader? _modloader;
  Minecraft _minecraft = Minecraft();
  MainState _mainState = MainState.downloadingML;
  double _progress = 0.0;
  double _mainprogress = 0.0;
  var _installState;

  late SendPort sendportMain;

  void sendMessage([
    SendPort? sendportMain,
    ReceivePort? receivePort,
  ]) {
    if (sendportMain != null) {
      this.sendportMain = sendportMain;
    }
    if (receivePort != null) {
      receivePort.listen((message) {
        if (message is IsolateBreaker) {
          print('suicide Isolate: ${message.getmessage}');
          Isolate.exit();
        }
      });
    }

    this.sendportMain.send(InstallerMessage(
        mainState: _mainState,
        installState: _installState,
        progress: _progress,
        mainprogress: _mainprogress,
        sendPort: receivePort?.sendPort));
  }

  static init(List args) {
    SendPort sendportMain = args[0];
    StartMessage startMessage = args[1];
    Installer _installer = Installer();
    ReceivePort receivePort = ReceivePort();

    _installer.sendMessage(sendportMain, receivePort);

    _installer.install(startMessage.getHandler, startMessage.modpackData,
        startMessage.getProcessId);
  }

  install(Api _handler, Map modpackData, String _processId) async {


    var downloader = _handler.getDownloaderObject();
    String mloaderS = modpackData["loaders"].first;
    Version version = Version.parse(modpackData["game_versions"].first);

    if (mloaderS == "forge") {
      _modloader = Forge();
    } else if (mloaderS == "fabric") {
      _modloader = Fabric();
    }
    if (_modloader == null) throw 'no modloader was found';

    downloader.addListener(() {
      _mainState = MainState.downloadingMods;
      _mainprogress = downloader.progress;
      _progress = downloader.progress;
      sendMessage();
    });

    _minecraft.addListener(() {
      // print('${_minecraft.installstate} ${_minecraft.progress}');
      _mainState = MainState.downloadingMinecraft;
      _installState = _minecraft.installstate;
      _mainprogress = _minecraft.mainprogress;
      _progress = _minecraft.progress;
      sendMessage();
    });
    _modloader!.addListener(() {
      // print(
      //     'state: ${_modloader!.installstate}, progress: ${_modloader!.progress}');
      _mainState = MainState.downloadingML;
      _installState = _modloader!.installstate;
      _mainprogress = _modloader!.mainprogress;
      _progress = _modloader!.progress;
      sendMessage();
    });

    await downloader.downloadModpack(modpackData, _processId);
    Map versions =
        await ModrinthApi().getMMLVersion(modpackData, _processId, mloaderS);

    version = versions["version"];
    ModloaderVersion modloaderVersion = versions["modloader"];

    String mfilePath =
        '${await getworkpath()}\\versions\\$version\\$version.json';

    if (_checkForInstall(
        '${await getworkpath()}\\versions\\$version\\$version.json')) {
      print('need to install minecraft: $version');
      print(mfilePath);
      await _minecraft.install(version!);
    }

    if (_checkForInstall(
        await _modloader!.getSafeDir(version, modloaderVersion))) {
      print('need to install $mloaderS: $version-$modloaderVersion');
      await _modloader!.install(version, modloaderVersion);
    }
    _mainState = MainState.installed;
    sendMessage();
    print('installed is done');

    // _modloader!.run(modpackVersion["id"], version, modloaderVersion);
    Isolate.exit();
  }

  bool _checkForInstall(String path) {
    return (!(File(path).existsSync()));
  }
}
