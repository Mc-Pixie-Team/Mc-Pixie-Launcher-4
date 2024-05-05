import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
<<<<<<< Updated upstream:lib/src/pages/home_page.dart
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mclauncher4/src/pages/installed_modpacks_handler.dart';
=======

import 'package:mclauncher4/src/pages/installed_modpacks_ui_handler.dart';
>>>>>>> Stashed changes:lib/src/pages/home_page/home_page.dart
import 'package:mclauncher4/src/tasks/auth/microsoft.dart';
import 'package:mclauncher4/src/widgets/buttons/svg_button.dart';
import 'package:mclauncher4/src/widgets/carousel/carousel.dart';

import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:mclauncher4/src/widgets/divider.dart' as divider;
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map> items = [
    {'name': 'Fabulously Optimized', 'description': 'Improve your workflow', 'pictureId': "https://unsplash.com/photos/d2w-_1LJioQ/download?ixid=M3wxMjA3fDB8MXxzZWFyY2h8Nnx8bWluZWNyYWZ0fGRlfDB8fHx8MTcxMzYxOTQwN3ww&force=true&w=1920"},
    {'name': 'Cobllemon', 'description': 'fast for more', 'pictureId': "https://unsplash.com/photos/EgL0EtzL0Wc/download?ixid=M3wxMjA3fDB8MXxzZWFyY2h8M3x8bWluZWNyYWZ0fGRlfDB8fHx8MTcxMzYxOTQwN3ww&force=true&w=1920"},
    {'name': 'The Revenge', 'description': 'the big new recomming of something bad', 'pictureId': "https://unsplash.com/photos/PzKMcReo2Q4/download?ixid=M3wxMjA3fDB8MXxzZWFyY2h8N3x8bWluZWNyYWZ0fGRlfDB8fHx8MTcxMzYxOTQwN3ww&force=true&w=1920"},
    {'name': 'The Earea ATM', 'description': 'something bad is about to happen', 'pictureId': "https://unsplash.com/photos/xkFhOdId7mA/download?ixid=M3wxMjA3fDB8MXxzZWFyY2h8MTl8fG1pbmVjcmFmdHxkZXwwfHx8fDE3MTM2MTk0MDd8MA&force=true&w=1920"},
  ];

<<<<<<< Updated upstream:lib/src/pages/home_page.dart
  bool get isEmpty => Modpacks.globalinstallContollers.value.length < 1;
=======

>>>>>>> Stashed changes:lib/src/pages/home_page/home_page.dart


  Widget  modpackList(BuildContext context) => DynMouseScroll(
                        animationCurve: Curves.easeOutExpo,
                        scrollSpeed: 1.0,
                        durationMS: 650,
                        builder: (context, _scrollController, physics) => SingleChildScrollView(
                            physics: physics,
                            controller: _scrollController,
                            child: SizedBox(
                              width: 800,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height:  61,
                                  ),
                                  Carousel(items: items),
                                  ValueListenableBuilder(
<<<<<<< Updated upstream:lib/src/pages/home_page.dart
                                      valueListenable: Modpacks.globalinstallContollers,
                                      builder: (context, value, child) =>
                                           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
=======
                                      valueListenable: InstalledModpacksUIHandler.installCardChildren,
                                      builder: (context, value, child) {
                                        print("inner list lengt " + InstalledModpacksUIHandler.installCardChildren.value.length.toString());
                                          bool isEmpty = InstalledModpacksUIHandler.installCardChildren.value.length == 0;
                                         return  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
>>>>>>> Stashed changes:lib/src/pages/home_page/home_page.dart
                                              Padding(
                                                padding: EdgeInsets.only(left: 75, top: 5),
                                                child: Text(
                                                  'Installed:',
                                                  style: Theme.of(context).typography.black.headlineSmall,
                                                ),
                                              ),
                                               SizedBox(
                                                height: 10,
                                              ),
                                              divider.CustomDivider(size: 70, ),
                                             isEmpty
                                          ? Padding(
                                              padding: EdgeInsets.only(top: 150),
                                              child: Center(
                                                  child: Text(
                                                'Nothing found :(',
                                                style: Theme.of(context).typography.black.bodyLarge,
                                              )),
                                            ) :
                                              Padding(
                                                  padding: EdgeInsets.only(left: 80, top: 50),
                                                  child: Align(
                                                      alignment: Alignment.topLeft,
                                                      child: Wrap(
                                                          alignment: WrapAlignment.start,
                                                          spacing: 40.0, // gap between adjacent chips
                                                          runSpacing: 60.0,
                                                          children: value)))
                                            ]); })
                                ],
                              ),
                            )));

  @override
  Widget build(BuildContext context) {
     print("build inner list lengt " + InstalledModpacksUIHandler.installCardChildren.value.length.toString());
    return Container(
        clipBehavior: Clip.antiAlias,
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(alignment: Alignment.center, children: [
          Positioned.fill(
            child:   modpackList(context),
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
                                  child: Text(
                                    'HomePage',
                                     style: Theme.of(context).typography.black.titleMedium
                                  )),
                              Expanded(child: Container()),
                              Container(
                                  clipBehavior: Clip.antiAlias,
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle, color: Theme.of(context).colorScheme.surface),
                                  child: GestureDetector(
                                    onTap: () => Microsoft().authenticate(),
                                    child: FadeInImage.memoryNetwork(
                                        placeholder: kTransparentImage,
                                        image:
                                            'https://lh3.googleusercontent.com/a/ACg8ocLlOn3NroVB-AMQehydBqWLd8IaWRozFcPEm2_lcw3fkw=s288-c-no'),
                                  )),
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
