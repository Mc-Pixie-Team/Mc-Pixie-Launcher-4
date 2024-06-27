// ignore_for_file: prefer_interpolation_to_compose_strings, unnecessary_cast

import 'dart:io';
import 'dart:isolate';

import 'package:mclauncher4/src/widgets/modpack_widgets/modpack_title_icon_widget.dart';
import 'package:path/path.dart' as path;
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/get_api_handler.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/models/dumf_model.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/widgets/buttons/svg_button.dart';
import 'package:mclauncher4/src/widgets/components/slide_in_animation.dart';
import 'package:mclauncher4/src/widgets/file_table/file_table.dart';
import 'package:mclauncher4/src/widgets/mod_picture.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_windows/webview_windows.dart';

class ModPage extends StatefulWidget {
  UMF modpackData;
  String handlerString;
  ModPage({Key? key, required this.modpackData, required this.handlerString})
      : super(key: key);

  @override
  _ModPageState createState() => _ModPageState();
}

class _ModPageState extends State<ModPage> {
  DUMF? details;
  bool isdisposed = false;
  Isolate? isolate;
  bool isVersions = true;

  static inIsolate(List args) async {
    Api handler = ApiHandler().getApi(args[2]);
    DUMF dumf = await handler.getDUMF(args[0]);
    Isolate.exit(args[1], dumf);
  }

  createIsolate() async {
    final resultPort = ReceivePort();

    isolate = await Isolate.spawn(inIsolate, [
      widget.modpackData.original,
      resultPort.sendPort,
      widget.handlerString
    ]);

    resultPort.listen((message) {
      setState(() {
        details = message;
      });
    });
  }

  @override
  void initState() {
    createIsolate();

    super.initState();
  }

  @override
  void dispose() {
    isdisposed = true;
    if (isolate != null) {
      isolate!.kill();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18)),
      child: Stack(
        children: [
          Positioned(
              top: 35,
              left: 20,
              child: SvgButton.asset(
                "assets/svg/dropdown-icon.svg",
                onpressed: () => Navigator.of(context).pop(),
                color: Theme.of(context).colorScheme.secondary,
                text: Text(
                  "Modpacks",
                  style: Theme.of(context).typography.black.labelLarge,
                ),
              )),
          Positioned.fill(
            top: 50,
            child: Column(children: [
              ModpackTitleIconWidget(
                  modloader: widget.modpackData.modloader,
                  name: widget.modpackData.name,
                  downloads: widget.modpackData.downloads,
                  iconUrl: widget.modpackData.icon,
                  mcVersion: widget.modpackData.MCVersion,
                  mlVersion: widget.modpackData.MLVersion),
              const SizedBox(
                height: 40,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 50,
                  ),
                  GestureDetector(
                      onTap: () => setState(() {
                            isVersions = false;
                          }),
                      child: Column(children: [
                        Text(
                          "Home",
                          style:
                              Theme.of(context).typography.black.headlineSmall,
                        ),
                        SizedBox(
                            width: 80,
                            child: Center(
                                child: AnimatedContainer(
                              margin: EdgeInsets.only(top: 5),
                              duration: Duration(milliseconds: 300),
                              height: 2,
                              curve: Curves.easeInOutCubic,
                              width: isVersions ? 0 : 80,
                              color: Theme.of(context).colorScheme.primary,
                            )))
                      ])),
                  const SizedBox(
                    width: 30,
                  ),
                  GestureDetector(
                      onTap: () => setState(() {
                            isVersions = true;
                          }),
                      child: Column(children: [
                        Text("Versions",
                            style: Theme.of(context)
                                .typography
                                .black
                                .headlineSmall),
                        SizedBox(
                            width: 100,
                            child: Center(
                                child: AnimatedContainer(
                              margin: EdgeInsets.only(top: 5),
                              duration: Duration(milliseconds: 300),
                              height: 2,
                              curve: Curves.easeInOutCubic,
                              width: isVersions ? 100 : 0,
                              color: Theme.of(context).colorScheme.primary,
                            )))
                      ]))
                ],
              ),
              Expanded(
                  child: PageTransitionSwitcher(
                reverse: !isVersions,
                duration: const Duration(milliseconds: 400),
                child: isVersions
                    ? FileTable(
                        providerString: widget.handlerString,
                        details: details,
                      )
                    : details?.body == null
                        ? Text("no body found! or details could not be loaded")
                        : WebviewWidget(
                            cachHTMLFile: File(
                                path.join(getHTMLcachePath(), "index.html")),
                            body: details!.body!,
                          ),
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
            ]),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class StackedItem extends StatelessWidget {
  String type1;
  String type2;

  StackedItem({required this.type1, required this.type2});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(right: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type1,
              style: Theme.of(context).typography.black.bodyMedium,
            ),
            SizedBox(
              height: 3,
            ),
            Text(
              type2,
              style: Theme.of(context).typography.black.labelLarge,
            )
          ],
        ));
  }
}
