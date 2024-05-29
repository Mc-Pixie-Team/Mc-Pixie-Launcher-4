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
import 'package:mclauncher4/src/tasks/models/value_notifier_list.dart';
import 'package:mclauncher4/src/tasks/models/download_states.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/widgets/cards/installed_card.dart';
import 'package:mclauncher4/src/widgets/side_panel/side_panel.dart';
import 'package:mclauncher4/src/widgets/side_panel/taskwidget.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
class InstallController with ChangeNotifier {
  Api handler;
  UMF modpackData;
  String? processid;
  MainState mainstate;
  BuildContext? context;
  ValueNotifierList _stdout = ValueNotifierList([]);
  InstallController(
      {required this.handler,
      required this.modpackData,
      this.processid,
      this.mainstate = MainState.notinstalled,
      this.replace = true}) {
       
   
   

    processid = processid ?? const Uuid().v1();
  }

  bool replace;
  double _progress = 0.0;

  MainState get state => mainstate;
  double get progress => _progress;
  String get processId => processid!;
  ValueNotifierList get stdout => _stdout;
  Isolate? _isolate;
  Process? _result;

  static int instances = 0;

  onHandleStdout(Iterable<int> out) {
     
      _stdout.add(String.fromCharCodes(out));
  }
 
  void start() async {

    print('start');

    mainstate = MainState.fetching;
    _progress = 100.0;
    notifyListeners();
    setUIChanges();

    _result = await handler.getDownloaderObject().start(processId);

    await Future.delayed(Duration(milliseconds: 300));
    mainstate = MainState.running;
    notifyListeners();

    _result!.stdout.listen(onHandleStdout);
    _result!.stderr.listen(onHandleStdout);

    _result!.exitCode.then((value) {
      mainstate = MainState.installed;
      notifyListeners();

      removeUIChanges();
    });
  }

  void cancel() {

    print("killing isolate");
    if (_result != null) {
     _result!.kill();
      mainstate = MainState.installed;
      notifyListeners();
      return;
    }

    if (_isolate == null) {
      print("cant kill Isolate");
      return;
    }

    _isolate!.kill(priority: Isolate.immediate);
    _progress = 0.0;

    //Exception: called from here
    delete();
  }

  void delete() async {
    File manifestfile = File( path.join(getInstancePath(), "manifest.json"));
    List manifest = jsonDecode(await manifestfile.readAsString());
    final dir = Directory(path.join(getInstancePath(), processid));

    manifest.removeWhere((element) {
      print(element["processId"]);
      return element["processId"] == processId;
    });
    await manifestfile.writeAsString(jsonEncode(manifest));
  
    if (dir.existsSync()) dir.delete(recursive: true);

   removeFromInstallList();
     print('deleted');
    mainstate = MainState.notinstalled;
    notifyListeners();
  }

  void install({String? version}) async {
    print("Installing with:" + handler.getTitlename());
    print('start download');
    mainstate = MainState.fetching;
    notifyListeners();
    setUIChanges();

    print(modpackData.icon);
  
  ///To show the fetching animation
   // await Future.delayed(Duration(milliseconds: 300));

    print(InstallController.instances);
    await waitWhile(() => InstallController.instances > 1);
    InstallController.instances++;

    ReceivePort receivePort = ReceivePort();
    ReceivePort exitPort = ReceivePort();

    receivePort.listen((message) {
      if (message is InstallerMessage) {
        mainstate = message.mainState;
        _progress = message.progress;
        notifyListeners();
      }
    });
    exitPort.listen((message) {
      print(message);
      removeUIChanges();
      InstallController.instances--;
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
        errorsAreFatal: true,);
  }

  static void isolateEntry(List args) async {
    StartMessage startMessage = (args.last as StartMessage);

    var installer = startMessage.getHandler.getDownloaderObject();

    BackgroundIsolateBinaryMessenger.ensureInitialized(startMessage.getToken);


    //init for all pathes
    await Path.init();

    Timer timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      (args.first as SendPort).send(InstallerMessage(
        mainState: installer.installState,
        progress: installer.progress,
      ));
    });

    //Call the main installer
    await installer.install(
        modpackData: startMessage.modpackData.original,
        instanceName: startMessage.processId,
        localversion: startMessage.version);

    timer.cancel();
     List manifest = [];
    try {
      manifest = jsonDecode(
        File( path.join(getInstancePath(), "manifest.json")).readAsStringSync());
    } catch (e){
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
      print(' ab lengt ' + InstalledModpacksUIHandler.installCardChildren.value.length.toString());
    if (InstalledModpacksUIHandler.installCardChildren.value
        .where((Widget element) => element.key == Key(processId))
        .isEmpty) {
          print("add to");
          
      InstalledModpacksUIHandler.installCardChildren.addAll( [AnimatedBuilder(
        key: Key(processId),
        animation: this,
        builder: (context, child) => InstalledCard(
          stdout: stdout,
          processId: processId,
          modpackData: modpackData,
          state: state,
          progress: progress,
          onCancel: cancel,
          onOpen: start,
          onDelete: delete,
        ),
      )]);
    }
    print('lengt ' + InstalledModpacksUIHandler.installCardChildren.value.length.toString());

    // Calls SidePanel instance
   StaticSidePanelController.controller.addToTaskWidget(
        AnimatedBuilder(
            animation: this,
            builder: (context, child) => TaskwidgetItem(
                  name: state == MainState.downloadingMinecraft
                      ? "Minecraft"
                      : modpackData.name!,
                  cancel: cancel,
                  state: state,
                  progress: progress,
                )),
        processId);
  }
  removeFromInstallList() {
    InstalledModpacksUIHandler.installCardChildren.removeKeyFromAnimatedBuilder(processId);
  }



  removeUIChanges() {
   StaticSidePanelController.controller.removeFromTaskWidget(processId);
  }

  setErrorDialog(BuildContext context, String errorDialog) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Oh no an Error occured!"), 
            content:  SelectableText(errorDialog),
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
