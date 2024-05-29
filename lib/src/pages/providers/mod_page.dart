// ignore_for_file: prefer_interpolation_to_compose_strings, unnecessary_cast

import 'dart:io';
import 'dart:isolate';

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

//    Future c = compute(ModrinthApi().getDUMF, widget.modpackData.original);
//     print("init");
// c.then((value) {
//   if(isdisposed) return;
//       setState(() {
//            details = value;
//       });

//     });

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
    String modloaderstring = "";
    for (String modl in widget.modpackData.modloader) {
      modloaderstring += "$modl ";
    }

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
              Row(children: [
                Padding(
                  padding: EdgeInsets.only(left: 40),
                  child: ModPicture(
                    width: 140,
                    url: widget.modpackData.icon!,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                SlideInAnimation(
                    curve: Curves.easeOutQuad,
                    duration: const Duration(milliseconds: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Modpack",
                          style: Theme.of(context)
                              .typography
                              .black
                              .labelLarge!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                        Text(
                          widget.modpackData.name!,
                          style:
                              Theme.of(context).typography.black.displaySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            StackedItem(
                              type1: "Downloads",
                              type2: widget.modpackData.downloads! > 999
                                  ? (((widget.modpackData.downloads! / 1000)
                                                  as double)
                                              .round())
                                          .toString() +
                                      'k'
                                  : widget.modpackData.downloads!.toString(),
                            ),
                            StackedItem(
                                type1: modloaderstring,
                                type2: widget.modpackData.MLVersion ?? "N/A"),
                            StackedItem(
                                type1: "Minecraft",
                                type2: widget.modpackData.MCVersion ?? "N/A")
                          ],
                        )
                      ],
                    ))
              ]),
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
                            child: Center(child: AnimatedContainer(
                              margin: EdgeInsets.only(top: 5),
                              duration: Duration(milliseconds: 300),
                              height: 2,
                              curve: Curves.easeInOutCubic,
                              width: isVersions ? 0 : 80,
                              color:  Theme.of(context).colorScheme.primary,
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
                            child: Center(child: AnimatedContainer(
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
                            ? Text(
                                "no body found! or details could not be loaded")
                            : WebviewWidget(
                    cachHTMLFile: File(
                      path.join( getHTMLcachePath(), "index.html")),
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
