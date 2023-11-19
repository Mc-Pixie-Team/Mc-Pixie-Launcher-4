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

  void start([d, b, a, c]) {}
  void cancel() {}


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
   // addtaskwidget();
    print('start download');

    print((modpackData["versions"] as List).last);


    ModrinthInstaller installer = ModrinthInstaller();

    ReceivePort receivePort = ReceivePort();

    receivePort.listen((message) {
      if(message is InstallerMessage) {
       _state = message.mainState;
       _progress = message.progress;
      // notifyListeners();
      }
    });

    await Isolate.spawn((args) => isolateInstall(args), [
      receivePort.sendPort,
      StartMessage(
          handler: handler, modpackData: modpackData, processId: _processId)
    ]);

    _progress = installer.progress;
    _state = installer.installState;
    notifyListeners();
  }

  static void isolateInstall(List args) async{
    StartMessage startMessage = (args.last as StartMessage);
    ModrinthInstaller installer = ModrinthInstaller();

    Timer timer = Timer.periodic(Duration(milliseconds: 1500), (timer) {
      (args.first as SendPort).send(InstallerMessage(
          mainState: installer.installState, progress: installer.progress));  
    });

    await installer.install(startMessage.modpackData, startMessage.processId);
    timer.cancel();
  }
}
