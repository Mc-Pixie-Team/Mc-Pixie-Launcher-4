import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/pages/installed_objects_handlers.dart';

import 'package:mclauncher4/src/tasks/auth/microsoft.dart';
import 'package:mclauncher4/src/tasks/install_object_handler.dart';
import 'package:mclauncher4/src/widgets/buttons/svg_button.dart';
import 'package:mclauncher4/src/widgets/cards/add_card.dart';
import 'package:mclauncher4/src/widgets/cards/installed_card.dart';
import 'package:mclauncher4/src/widgets/carousel/carousel.dart';

import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:mclauncher4/src/widgets/divider.dart' as divider;
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  List<Map> publicModpackList;
  InstallObjectHandler installObjectHandler;
  HomePage(
      {required this.installObjectHandler,
      required this.publicModpackList,
      Key? key})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget modpackList(BuildContext context) => DynMouseScroll(
      animationCurve: Curves.easeOutExpo,
      scrollSpeed: 1.0,
      durationMS: 650,
      builder: (context, _scrollController, physics) => SingleChildScrollView(
            physics: physics,
            controller: _scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 60,
                ),
                Padding(
                    padding: EdgeInsets.only(left: 45, right: 45),
                    child: Carousel(items: widget.publicModpackList)),
                SizedBox(
                  height: 30,
                ),
                ValueListenableBuilder(
                    valueListenable:
                        widget.installObjectHandler.installControllers,
                    builder: (context, value, child) {
                      List<Widget> innergrid = List.generate(
                          widget.installObjectHandler.installControllers.value
                              .length,
                          (index) => InstalledCard(
                              controllerInstance: widget.installObjectHandler
                                  .installControllers.value[index]));

                      innergrid.add(AddCard());
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 55, top: 5),
                              child: Text(
                                "Installed" + ":",
                                style: Theme.of(context)
                                    .typography
                                    .black
                                    .headlineSmall,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            divider.CustomDivider(
                              size: 50,
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 50, top: 50),
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Wrap(
                                        alignment: WrapAlignment.start,
                                        spacing:
                                            40.0, // gap between adjacent chips
                                        runSpacing: 60.0,
                                        children: innergrid)))
                          ]);
                    })
              ],
            ),
          ));

  @override
  Widget build(BuildContext context) {
    return Container(
        clipBehavior: Clip.antiAlias,
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(alignment: Alignment.center, children: [
          Positioned.fill(
            child: modpackList(context),
          ),
          Positioned.fill(
            child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 15,
                      ),
                      Transform.rotate(
                          angle: 1.6,
                          child: SvgButton.asset(
                            'assets/svg/dropdown-icon.svg',
                            onpressed: () {},
                            color: Theme.of(context).colorScheme.secondary,
                          )),
                      Padding(
                          padding: EdgeInsets.only(left: 14, bottom: 3),
                          child: Text("Homepage",
                              style: Theme.of(context)
                                  .typography
                                  .black
                                  .titleMedium)),
                      Expanded(child: Container()),
                      SizedBox(
                        width: 15,
                      )
                    ],
                  ),
                )),
          )
        ]));
  }
}
