import 'dart:async';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/install_controller.dart';

import 'package:mclauncher4/src/tasks/models/value_notifier_list.dart';
import 'package:mclauncher4/src/tasks/utils/file_explorer.dart';
import 'package:mclauncher4/src/widgets/explorer/explorer.dart';
import 'package:mclauncher4/src/widgets/modpack_widgets/modpack_actions_menu.dart';
import 'package:mclauncher4/src/widgets/modpack_widgets/modpack_title_icon_widget.dart';

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

  @override
  void initState() {
    widget.controllerInstance.stdout.addListener(() {
      if (scrollController.hasClients) {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });

    super.initState();
  }

  onOpenFolder() {
    FileExplorer.openFileExplorer(
        path.join(getInstancePath(), widget.controllerInstance.processId));
  }

  onDelete(BuildContext _context) {
    Navigator.pop(_context);
    widget.controllerInstance.delete();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
        child: Container(
      padding: EdgeInsets.only(right: 40),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          SizedBox(
            height: 40,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ModpackTitleIconWidget(
                modloader: ["Fabric"],
                downloads: 12033,
                iconUrl:
                    "https://unsplash.com/photos/cZveUvrezvY/download?ixid=M3wxMjA3fDB8MXxzZWFyY2h8Mnx8cGl4ZWwlMjBhcnR8ZW58MHx8fHwxNzE3MDY5MzA2fDA&force=true&w=640",
                mcVersion: "1.20.6",
                mlVersion: "1-34.32",
                name: "Pixiemon",
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
                          onPlay: widget.controllerInstance.start,
                          onSecondMenuItem: onOpenFolder,
                          state: widget.controllerInstance.installModel.installState,
                          progress: widget.controllerInstance.installModel.progress))
            ],
          )
        ],
      ),
    ));
  }
}
