import 'dart:async';
import 'package:animations/animations.dart';
import 'package:mclauncher4/src/pages/installed_mod/installed_home_page.dart';
import 'package:mclauncher4/src/pages/installed_mod/installed_mods_page.dart';
import 'package:mclauncher4/src/tasks/apis/files/files_handler.dart';
import 'package:mclauncher4/src/tasks/installs/install_model.dart';
import 'package:mclauncher4/src/tasks/models/object_type.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/install_controller.dart';

import 'package:mclauncher4/src/tasks/models/value_notifier_list.dart';
import 'package:mclauncher4/src/tasks/utils/file_explorer.dart';
import 'package:mclauncher4/src/widgets/explorer/explorer.dart';
import 'package:mclauncher4/src/widgets/modpack_widgets/modpack_actions_menu.dart';
import 'package:mclauncher4/src/widgets/modpack_widgets/modpack_title_icon_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InstalledModPage extends StatefulWidget {
  InstallController controllerInstance;
  InstalledModPage({
    Key? key,
    required this.controllerInstance,
  }) : super(key: key);

  @override
  _InstalledModPageState createState() => _InstalledModPageState();
}

class _InstalledModPageState extends State<InstalledModPage> {
  List<String> commandline = [];

  ScrollController scrollController = ScrollController();

  late Map<String, Widget> _pages;

  late String _pageKey;

  late FilesHandler _handler;

  @override
  void dispose() {
    if(!_handler.isdisposed) {
       _handler.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    widget.controllerInstance.installModel.addListener(() {
      setState(() {
        
      });
    });

    List<ObjectType> types = [
      ObjectType.mod,
      ObjectType.resource,
      ObjectType.shader,
    ];

    _handler = FilesHandler(
      directoryPath: path.join(getInstancePath(), widget.controllerInstance.processId), types: types, processId: widget.controllerInstance.processId);

    _handler.initialize();

    widget.controllerInstance.addBeforeDeleteListener(() { 
      if(!_handler.isdisposed) {
       _handler.dispose();
     }
    });

    Map pagesTypes =  Map.fromIterable(types, key: (type) => ObjectTypeTools.toName(type), value: (type) => AnimatedBuilder(key: Key(type.toString()),animation: _handler, builder: (context, child) {

       return ModsPage(files: _handler.files.toList(), type: type, instanceName: widget.controllerInstance.processId);}), );

    _pages = {
    "Home": InstalledHomePage(processId: widget.controllerInstance.processId,),
    "Console": Container(),
    ...pagesTypes
  };

    _pageKey = _pages.keys.toList()[3];
    // widget.controllerInstance.stdout.addListener(() {
    //   if (scrollController.hasClients) {
    //     scrollController.animateTo(scrollController.position.maxScrollExtent,
    //         duration: Duration(milliseconds: 200), curve: Curves.easeOut);
    //   }
    // });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });

    
  }

  onOpenFolder() {
    FileExplorer.openFileExplorer(
        path.join(getInstancePath(), widget.controllerInstance.processId));
  }

  onDelete(BuildContext _context) {
    Navigator.pop(_context);
    widget.controllerInstance.delete();
  }

  onPlay() {
    switch (widget.controllerInstance.installModel.installState) {
      case InstallState.installed:
        widget.controllerInstance.start();
      case InstallState.running:
        widget.controllerInstance.cancel();
      default:
        return;
    }
  }

  double TextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.size.width + 6;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox.expand(
            child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ModpackTitleIconWidget(
                    modloader:
                        widget.controllerInstance.modpackData.modloader ?? "",
                    downloads: widget.controllerInstance.modpackData.downloads,
                    iconUrl: widget.controllerInstance.modpackData.icon,
                    mcVersion: widget.controllerInstance.modpackData.MCVersion,
                    mlVersion:
                        widget.controllerInstance.modpackData.MLVersion ?? "fd",
                    name: widget.controllerInstance.modpackData.name,
                  ),
                  Expanded(
                      child: SizedBox(
                    height: 0,
                    width: double.infinity,
                  )),
                  AnimatedBuilder(
                      animation: widget.controllerInstance.installModel,
                      builder: (BuildContext context, Widget? child) =>
                          ModpackActionsMenu(
                              onDelete: () => onDelete(context),
                              onPlay: onPlay,
                              onSecondMenuItem: onOpenFolder,
                              state: widget
                                  .controllerInstance.installModel.installState,
                              progress: widget
                                  .controllerInstance.installModel.progress))
                ],
              ),
              const SizedBox(
                height: 55,
              ),
              Row(
                children: List.generate(_pages.keys.length, (index) {
                  var key = _pages.keys.toList()[index];
                  return Padding(
                    padding: EdgeInsets.only(left: 40),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _pageKey = key;
                      }),
                      child: IntrinsicWidth(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              key,
                              style: _pageKey == key
                                  ? Theme.of(context)
                                      .typography
                                      .black
                                      .bodyLarge!
                                      .copyWith(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255))
                                  : Theme.of(context)
                                      .typography
                                      .black
                                      .bodyLarge,
                            ),
                            SizedBox(
                              width: TextWidth(
                                  key,
                                  Theme.of(context)
                                      .typography
                                      .black
                                      .headlineSmall!),
                              child: Center(
                                child: AnimatedContainer(
                                  margin: EdgeInsets.only(top: 5),
                                  duration: Duration(milliseconds: 200),
                                  height: 2,
                                  curve: Curves.easeInOutCubic,
                                  width: _pageKey == key
                                      ? TextWidth(
                                          key,
                                          Theme.of(context)
                                              .typography
                                              .black
                                              .headlineSmall!)
                                      : 0,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                  child: PageTransitionSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _pages[_pageKey],
                transitionBuilder:
                    (child, primaryAnimation, secondaryAnimation) =>
                        SharedAxisTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  fillColor: Colors.transparent,
                  child: child,
                ),
              ))
            ],
          ),
        )));
  }
}
