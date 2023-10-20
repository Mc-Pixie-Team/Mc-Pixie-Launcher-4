// ignore_for_file: sort_child_properties_last

import 'dart:ui';

import 'package:mclauncher4/src/getApiHandler.dart';
import 'package:mclauncher4/src/pages/installedModpacks.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/installController.dart';
import 'package:mclauncher4/src/tasks/java/java.dart';
import 'package:mclauncher4/src/widgets/Buttons/circularButton.dart';
import 'package:mclauncher4/src/widgets/InstalledCard.dart';
import 'package:mclauncher4/src/widgets/JavaInstallCard.dart';
import 'package:mclauncher4/src/widgets/Providers/BrowseCard.dart';
import 'package:mclauncher4/src/widgets/components/slideInAnimation.dart';
import 'package:mclauncher4/src/widgets/Providers/dropdownmenu.dart';
import 'package:mclauncher4/src/widgets/searchbar.dart' as Searchbar;
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/widgets/divider.dart' as Divider;
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ModListPage extends StatefulWidget {
  const ModListPage({Key? key}) : super(key: key);

  @override
  _ModListPageState createState() => _ModListPageState();
}

class _ModListPageState extends State<ModListPage> {
  late ScrollController _scrollController;
  ScrollController _secondController = ScrollController();
  late Widget addButton;
  GlobalKey key = new GlobalKey();
  List installContollers = [];
  List modpacklist = [];
  Api _handler = ApiHandler().getApi("modrinth");
  Future<dynamic> get mv async {
    return await _handler.getAllMV();
  }

  Future<List> get modpacklistfuture async {
    return await _handler.getModpackList();
  }

  bool iscalled = false;
  String querytext = "";
  List filterStrings = [];
  getMoreData() async {
    if (iscalled) return;
    iscalled = true;
    print('getmore data');
    List rawModpacks = await _handler.getMoreModpacks();
    modpacklist.addAll(rawModpacks);
    installContollers.addAll(
        List.generate(rawModpacks.length, (index) => InstallController()));
    setState(() {});
    iscalled = false;
  }

  bool checkForJava() {
    if (Java.isJavaInstalled) {
      return true;
    } else {
      showGeneralDialog(
        barrierLabel: 'Java not installed',
        barrierColor: Colors.black38,
        transitionDuration: Duration(milliseconds: 200),
        pageBuilder: (ctx, anim1, anim2) => Center(
          child: JavaInstallCard()
        ),
        transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: 4, sigmaY: 4 ),
          child: FadeTransition(
            child: child,
            opacity: anim1,
          ),
        ),
        context: context,
      );
      return false;
    }
  }

  void removeAtIndex(int index) {
    setState(() {
      filters.removeAt(
        index,
      );
      filters.insert(index, SizedBox());
    });
  }

  @override
  void initState() {
    addButton = CircularButton(
      child: Icon(
        Icons.add,
        color: Colors.grey,
      ),
      height: 40,
      width: 40,
      onClick: () {
        int index = filters.length - 1;

        setState(() {
          filters.insert(
            index,
            Padding(
                padding: EdgeInsets.only(left: 5, right: 10),
                child: Dropdownmenu(
                  isRemovalIcon: true,
                  child: SvgPicture.asset(
                    'assets\\svg\\cancel-icon.svg',
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                  onremove: (text) {
                    key = new GlobalKey();
                    modpacklist = [];
                    _handler.removeCategory(text);
                    removeAtIndex(index);
                  },
                  useOverlay: false,
                  registry: filterStrings,
                  onchange: (text, oldtext) {
                    key = new GlobalKey();

                    _handler.addCategory(text, oldtext);
                    setState(() {
                      modpacklist = [];
                    });
                  },
                )),
          );
        });
      },
    );

    filters.insert(0, addButton);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _scrollController.addListener(() async {
        if (_scrollController.position.pixels >=
            (_scrollController.position.maxScrollExtent - 400)) {
          await getMoreData();
        }
      });
    });

    super.initState();
  }

  List<Widget> filters = [];

  @override
  Widget build(BuildContext context) {
    return Container(
        clipBehavior: Clip.antiAlias,
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(18)),
        child: Stack(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 70, left: 30, bottom: 9),
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
                  _handler.getTitlename(),
                  style: Theme.of(context).typography.black.displaySmall,
                )),
              ),
              Divider.Divider(
                size: 14,
              ),
              SizedBox(
                height: 8,
              ),
              Expanded(
                  child: DynMouseScroll(
                animationCurve: Curves.easeOutQuart,
                scrollSpeed: 1.2,
                durationMS: 650,
                builder: (context, controller, physics) {
                  _scrollController = controller;
                  return FutureBuilder(
                      key: key,
                      future: modpacklistfuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: SizedBox(
                              height: 50,
                              width: 50,
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 30),
                            ),
                          );
                        }

                        if (snapshot.hasData) {
                          print('rebuld in ModList');
                          if (modpacklist.length < 1) {
                            modpacklist = snapshot.data ?? [];
                            installContollers = List.generate(
                                modpacklist.length,
                                (index) => InstallController());
                          }

                          return SlideInAnimation(
                              curve: Curves.easeInOutQuart,
                              duration: Duration(milliseconds: 750),
                              child: ShaderMask(
                                  shaderCallback: (Rect rect) {
                                    return LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color.fromARGB(255, 177, 70, 21),
                                        Colors.transparent,
                                        Colors.transparent,
                                        const Color.fromARGB(0, 155, 39, 176)
                                      ],
                                      stops: [
                                        0.0,
                                        0.1,
                                        0.9,
                                        1.0
                                      ], // 10% purple, 80% transparent, 10% purple
                                    ).createShader(rect);
                                  },
                                  blendMode: BlendMode.dstOut,
                                  child: ListView.builder(
                                      physics: physics,
                                      controller: controller,
                                      itemCount: modpacklist.length,
                                      itemBuilder: ((context, index) {
                                        InstallController installcontroller =
                                            installContollers[index];

                                        return AnimatedBuilder(
                                            key: Key(
                                                installcontroller.processId),
                                            animation: installcontroller,
                                            builder: (context, child) =>
                                                BrowseCard(
                                                  processId: installcontroller
                                                      .processId,
                                                  mainprogress:
                                                      installcontroller
                                                          .mainprogress,
                                                  modpacklist:
                                                      modpacklist[index],
                                                  mainState: installcontroller
                                                      .mainState,
                                                  installState:
                                                      installcontroller
                                                          .installState,
                                                  progress: installcontroller
                                                      .progress,
                                                  onCancel: () {
                                                    installcontroller.cancel();
                                                  },
                                                  onDownload: () async {
                                                    if (checkForJava() == false)
                                                      return;
                                                    Map modpackData =
                                                        modpacklist[index];

                                                    Modpacks
                                                        .globalinstallContollers
                                                        .add(AnimatedBuilder(
                                                      key: Key(installcontroller
                                                          .processId),
                                                      animation:
                                                          installcontroller,
                                                      builder:
                                                          (context, child) =>
                                                              InstalledCard(
                                                        processId:
                                                            installcontroller
                                                                .processId,
                                                        modpackData: modpackData[
                                                            "title"],
                                                        mainState:
                                                            installcontroller
                                                                .mainState,
                                                        mainprogress:
                                                            installcontroller
                                                                .mainprogress,
                                                        onCancel:
                                                            installcontroller
                                                                .cancel,
                                                        onOpen: () async {
                                                          if (checkForJava() ==
                                                              false) return;
                                                          Map modpackproject =
                                                              await _handler.getModpack(
                                                                  modpacklist[
                                                                          index]
                                                                      [
                                                                      "project_id"]);
                                                          Map modpackversion = await _handler
                                                              .getModpackVersion(
                                                                  (modpackproject[
                                                                              "versions"]
                                                                          as List)
                                                                      .last);
                                                          installcontroller.start(
                                                              _handler,
                                                              modpackversion);
                                                        },
                                                      ),
                                                    ));

                                                    installcontroller.install(
                                                        _handler, modpackData);
                                                  },
                                                  onOpen: () async {
                                                    Map modpackproject =
                                                        await _handler.getModpack(
                                                            modpacklist[index]
                                                                ["project_id"]);
                                                    Map modpackversion =
                                                        await _handler
                                                            .getModpackVersion(
                                                                (modpackproject[
                                                                            "versions"]
                                                                        as List)
                                                                    .last);
                                                    installcontroller.start(
                                                        _handler,
                                                        modpackversion);
                                                  },
                                                ));
                                      }))));
                        }
                        return Container();
                      });
                },
              ))
            ],
          ),
          Positioned.fill(
              top: 12,
              right: 12,
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: Align(
                            alignment: Alignment.topRight,
                            child: FutureBuilder(
                                future: _handler.getCategories(),
                                builder: ((context, snapshot) {
                                  if (snapshot.hasData) {
                                    filterStrings = snapshot.data!;
                                    return SingleChildScrollView(
                                        controller: _secondController,
                                        reverse: true,
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: filters,
                                        ));
                                  } else {
                                    return Container(
                                      width: double.infinity,
                                    );
                                  }
                                })))),
                    SizedBox(
                      width: 10,
                    ),
                    FutureBuilder(
                        future: mv,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return SizedBox(
                                width: 235,
                                child: Dropdownmenu(
                                  useOverlay: false,
                                  registry: snapshot.data,
                                  onchange: (text, oldtext) {
                                    key = new GlobalKey();

                                    _handler.searchMV(text);
                                    setState(() {
                                      modpacklist = [];
                                    });
                                  },
                                ));
                          }
                          return SizedBox(
                            width: 235,
                          );
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    Searchbar.Searchbar(
                      onchange: (text) {
                        querytext = text;
                      },
                      onsubmit: () {
                        key = new GlobalKey();
                        print('querytext: $querytext');
                        setState(() {
                          _handler.query = querytext;
                          modpacklist = [];
                        });
                      },
                    ),
                  ],
                ),
              )),
        ]));
  }
}
