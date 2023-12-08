import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/pages/installed_modpacks_handler.dart';
import 'package:mclauncher4/src/tasks/Models/isolate_message.dart';
import 'package:mclauncher4/src/tasks/Models/start_message.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/forge/forge.dart';
import 'package:mclauncher4/src/tasks/installer/modrinth/modrinth_install.dart';
import 'package:mclauncher4/src/tasks/models/download_states.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:mclauncher4/src/widgets/cards/installed_card.dart';
import 'package:mclauncher4/src/widgets/side_panel/side_panel.dart';
import 'package:mclauncher4/src/widgets/side_panel/taskwidget.dart';
import 'package:uuid/uuid.dart';

class InstallController with ChangeNotifier {
  Api handler;
  UMF modpackData;
  String? processid;
  InstallController({required this.handler, required this.modpackData, this.processid}) {
    processid = processid ?? const Uuid().v1();
  }

  MainState _state = MainState.notinstalled;
  double _progress = 0.0;

  MainState get state => _state;
  double get progress => _progress;
  String get processId => processid!;

  Isolate? _isolate;

  static int instances = 0;

  void start() async{
    print('start');
   Process result = await  ModrinthInstaller().start(processId);



  }


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

  void install() async {
    print('start download');
    _state = MainState.fetching;
    notifyListeners();
    setUIChanges();

    //To show the fetching animation
    await Future.delayed(Duration(milliseconds: 300));

    print(InstallController.instances);
    await waitWhile(() => InstallController.instances > 1);
    InstallController.instances++;

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
      removeUIChanges();
      InstallController.instances--;
    });

    _isolate = await Isolate.spawn((args) => isolateInstall(args),
        [receivePort.sendPort, StartMessage(handler: handler, modpackData: modpackData, processId: processId)],
        onExit: exitPort.sendPort, debugName: "Install of $processId");
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
    await installer.install(startMessage.modpackData.original, startMessage.processId);

    timer.cancel();
    //Send complete message
    (args.first as SendPort).send(InstallerMessage(
      mainState: MainState.installed,
      progress: 100,
    ));
    Isolate.exit();
  }

  ///  <-------Utils------->

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
    Modpacks.globalinstallContollers.add(AnimatedBuilder(
      key: Key(this.processId),
      animation: this,
      builder: (context, child) => InstalledCard(
        processId: this.processId,
        modpackData: modpackData,
        state: this.state,
        progress: this.progress,
        onCancel: cancel,
        onOpen: () async {},
      ),
    ));


    //Calls SidePanel instance
    SidePanel().addToTaskWidget(
        AnimatedBuilder(
            animation: this,
            builder: (context, child) => TaskwidgetItem(
                  name:  state == MainState.downloadingMinecraft ? "Minecraft" : modpackData.name!,
                  cancel: cancel,
                  mainState: state,
                  mainprogress: progress,
                  progress: progress,
                )),
        processId);
  }

  removeUIChanges() {
    SidePanel().removeFromTaskWidget(processId);
    Modpacks.globalinstallContollers.removeKeyFromAnimatedBuilder(processId);
  }
  
}
