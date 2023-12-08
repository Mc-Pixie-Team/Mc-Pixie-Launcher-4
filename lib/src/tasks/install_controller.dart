import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/Models/isolate_message.dart';
import 'package:mclauncher4/src/tasks/Models/start_message.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/installer/modrinth/modrinth_install.dart';
import 'package:mclauncher4/src/tasks/models/download_states.dart';
import 'package:mclauncher4/src/widgets/SidePanel/SidePanel.dart';
import 'package:mclauncher4/src/widgets/SidePanel/taskwidget.dart';
import 'package:uuid/uuid.dart';

class InstallController with ChangeNotifier {
  InstallController([d]);

  MainState _state = MainState.notinstalled;
  double _progress = 0.0;
  String _processId = Uuid().v1();

  MainState get state => _state;
  double get progress => _progress;
  String get processId => _processId;

  Isolate? _isolate;

  static int instances = 0;

  void start([d, b, a, c]) {}
  void cancel() {
    if (_isolate == null) {
      print("cant kill Isolate");
      return;
    }

    _isolate!.kill(priority: -1);
    _progress = 0;
    _state = MainState.notinstalled;
    notifyListeners();
  }

  Future waitWhile(bool test(), [Duration pollInterval = Duration.zero]) {
  var completer = new Completer();
  check() {
    if (!test()) {
      completer.complete();
    } else {
      new Timer(pollInterval, check);
    }
  }
  check();
  return completer.future;
}

  // addtaskwidget() {
  //     SidePanel().addToTaskWidget(
  //     AnimatedBuilder(
  //         animation: this,
  //         builder: (context, child) => TaskwidgetItem(
  //               name: "test",
  //               cancel: cancel,
  //               mainState: state,

  //               mainprogress: progress,
  //               progress: progress,
  //             )),
  //     processId);
  // }

  void install(Api handler, Map modpackData) async {
    print('start download');
    _state = MainState.fetching;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 300));

    print(InstallController.instances);
   await waitWhile(() => InstallController.instances > 1);
    InstallController.instances++;

    // addtaskwidget();

    ReceivePort receivePort = ReceivePort();
    ReceivePort exitPort = ReceivePort();

    receivePort.listen((message) {
      if (message is InstallerMessage) {
        _state = message.mainState;
        _progress = message.progress;
        notifyListeners();
      }
    });
    exitPort.listen((message) {
      print(message);
      InstallController.instances--;
    });

    _isolate = await Isolate.spawn(
        (args) => isolateInstall(args),
        [
          receivePort.sendPort,
          StartMessage(
              handler: handler, modpackData: modpackData, processId: _processId)
        ],
        onExit: exitPort.sendPort,
        debugName: "Install of $processId");
  }

  static void isolateInstall(List args) async {
    StartMessage startMessage = (args.last as StartMessage);
    ModrinthInstaller installer = ModrinthInstaller();

    Timer timer = Timer.periodic(Duration(milliseconds: 1500), (timer) {
      (args.first as SendPort).send(InstallerMessage(
        mainState: installer.installState,
        progress: installer.progress,
      ));
    });

    //Call the main installer
    await installer.install(startMessage.modpackData, startMessage.processId);

    timer.cancel();
    //Send complete message
    (args.first as SendPort).send(InstallerMessage(
      mainState: MainState.installed,
      progress: 100,
    ));

    Isolate.exit();
  }
}
