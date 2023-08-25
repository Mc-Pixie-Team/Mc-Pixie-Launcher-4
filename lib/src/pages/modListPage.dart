// ignore_for_file: sort_child_properties_last

import 'package:flutter/cupertino.dart' as apple;
import 'package:mclauncher4/src/widgets/SvgButton.dart';
import 'package:mclauncher4/src/widgets/components/slideInAnimation.dart';
import '../widgets/searchbar.dart' as Searchbar;
import 'package:flutter/material.dart';
import '../widgets/divider.dart' as Divider;
import '../theme/scrollphysics.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ModListPage extends StatefulWidget {
  const ModListPage({Key? key}) : super(key: key);

  @override
  _ModListPageState createState() => _ModListPageState();
}

class _ModListPageState extends State<ModListPage> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(() {
      print('ahh');
    });

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _scrollController.addListener(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(18)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              heightFactor: 1.4,
              widthFactor: double.infinity,
              alignment: Alignment(0.98, 1),
              child: Searchbar.Searchbar(),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, left: 30, bottom: 9),
              child: SlideInAnimation(
                  duration: Duration(milliseconds: 1000),
                  child: Text(
                    'Modpacks provided:',
                    style: Theme.of(context).typography.black.bodySmall,
                  )),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30, bottom: 28),
              child: SlideInAnimation(
                  child: Text(
                'Modrinth',
                style: Theme.of(context).typography.black.displaySmall,
              )),
            ),
            Divider.Divider(
              size: 14,
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
                child: DynMouseScroll(
                    animationCurve: Curves.easeOutExpo,
                    scrollSpeed: 1.0,
                    durationMS: 650,
                    builder: (context, controller, physics) => ListView.builder(
                        physics: physics,
                        controller: controller,
                        itemCount: 10,
                        itemBuilder: ((context, index) {
                          _scrollController = controller;
                          return Padding(
                              padding: EdgeInsets.only(
                                top: 30,
                                left: 32,
                                right: 32,
                              ),
                              child: Container(
                                  clipBehavior: Clip.antiAlias,
                                  height: 160,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        child: Container(
                                          width: 127,
                                          height: 127,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceVariant),
                                        ),
                                        padding: EdgeInsets.all(17),
                                      ),
                                      Expanded(
                                          child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 33,
                                          ),
                                          Text(
                                            "PixieCraft$index",
                                            style: Theme.of(context)
                                                .typography
                                                .black
                                                .headlineSmall,
                                          ),
                                          Text(
                                            "The ultimate skyblock modpack! Watch development at: darkosto.tv/SkyFactoryLive",
                                            style: Theme.of(context)
                                                .typography
                                                .black
                                                .bodyMedium,
                                          ),
                                        ],
                                      )),
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Container(
                                              height: 45,
                                              width: 95,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceVariant,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SvgButton(
                                                    svg: SvgPicture.asset(
                                                        'assets\\svg\\download-icon.svg'),
                                                    onpressed: () {},
                                                  ),
                                                  SvgPicture.asset(
                                                      'assets\\svg\\network-icon.svg'),
                                                ],
                                              )),
                                        ),
                                      )
                                    ],
                                  )));
                        }))))
          ],
        ));
  }
}
