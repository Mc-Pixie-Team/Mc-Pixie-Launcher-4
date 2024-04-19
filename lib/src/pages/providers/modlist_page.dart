// ignore_for_file: sort_child_properties_last

import 'dart:io';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:mclauncher4/src/get_api_handler.dart';
import 'package:mclauncher4/src/pages/installed_modpacks_Ui_handler.dart';
import 'package:mclauncher4/src/pages/providers/mod_page.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/install_controller.dart';
import 'package:mclauncher4/src/tasks/java/java.dart';
import 'package:mclauncher4/src/tasks/modloaders.dart';
import 'package:mclauncher4/src/widgets/buttons/circular_button.dart';
import 'package:mclauncher4/src/widgets/cards/java_install_card.dart';
import 'package:mclauncher4/src/widgets/providers_widget/browse_card.dart';
import 'package:mclauncher4/src/widgets/components/slide_in_animation.dart';
import 'package:mclauncher4/src/widgets/providers_widget/dropdown_menu.dart';
import 'package:mclauncher4/src/widgets/searchbar.dart' as Searchbar;
import 'package:flutter/material.dart';
import 'package:smooth_list_view/smooth_list_view.dart';
import 'package:mclauncher4/src/widgets/divider.dart' as Divider;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class ModListPage extends StatefulWidget {
  String providerString;
  ModListPage({Key? key, required this.providerString}) : super(key: key);

  @override
  _ModListPageState createState() => _ModListPageState();
}

class _ModListPageState extends State<ModListPage> {
  ScrollController _scrollController = ScrollController();
  ScrollController _secondController = ScrollController();
  late Widget addButton;
  GlobalKey key = new GlobalKey();
  List installContollers = [];
  List modpacklist = [];
  late Api _handler;

  

  
  Future<dynamic> get mv async {
    
    return await _handler.getAllMV();
    
  }

  Future<List>  modpacklistfuture(BuildContext context) async {
    print("get modrinth future");
    var returntype = await _handler.getModpackList();
    Future.delayed(Duration(milliseconds: 200)).then((value) {
      _scrollController.addListener(() async {
        if (_scrollController.position.pixels ==
            (_scrollController.position.maxScrollExtent )) {
          print('new');
          await getMoreData(context);
        }
      });
    });
    return returntype;
  }

  bool iscalled = false;
  String querytext = "";
  List filterStrings = [];
  getMoreData(BuildContext context) async {
    if (iscalled) return;
    iscalled = true;
    print('getmore data');
    List rawModpacks = await _handler.getMoreModpacks();
    modpacklist.addAll(rawModpacks);
    installContollers.addAll(List.generate(
        rawModpacks.length,
        (index) => InstallController(
          context: context,
                              handler: _handler,
                              modpackData:
                                  _handler.convertToUMF(rawModpacks[index]))));
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
        pageBuilder: (ctx, anim1, anim2) => Center(child: JavaInstallCard()),
        transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
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
   _handler = ApiHandler().getApi(widget.providerString);
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
                    'assets/svg/cancel-icon.svg',
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
          borderRadius: BorderRadius.circular(18),
            color: Theme.of(context).colorScheme.surfaceVariant,
        ),
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
              Divider.CustomDivider(
                size: 14,
              ),
              SizedBox(
                height: 8,
              ),
              Expanded(
                  child: FutureBuilder(
                key: key,
                future: modpacklistfuture(context),
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
                    print(_handler.getTitlename());
                    print('rebuld in ModList');
                    if (modpacklist.length < 1) {
                      modpacklist = snapshot.data ?? [];
                      installContollers = List.generate(
                          modpacklist.length,
                          (index) => InstallController(
                            context: context,
                              handler: _handler,
                              modpackData:
                                  _handler.convertToUMF(modpacklist[index])));
                    }
                    return ShaderMask(
                        shaderCallback: (Rect rect) {
                          return const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.fromARGB(255, 177, 70, 21),
                              Colors.transparent,
                              Colors.transparent,
                              Color.fromARGB(0, 155, 39, 176)
                            ],
                            stops: [
                              0.0,
                              0.08,
                              0.6,
                              1.0
                            ], // 10% purple, 80% transparent, 10% purple
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstOut,
                        child:   ListView.builder(
                                controller: _scrollController,
                              
                                itemCount: modpacklist.length +1,
                                itemBuilder: ((context, index) {               
                                  
                                  if(index == modpacklist.length ) {
                                    print("returned");
                                  return SizedBox(height: 100, child: Center(child:  LoadingAnimationWidget.staggeredDotsWave(
                            color: Theme.of(context).colorScheme.primary,
                            size: 30)));
                                  }

                                  InstallController installcontroller =
                                      installContollers[index];

                                  return 
                                          AnimatedBuilder(
                                              key: Key(
                                                  installcontroller.processId),
                                              animation: installcontroller,
                                              builder: (context, child) =>
                                                  BrowseCard(
                                                   handlerString: widget.providerString,
                                                    processId: installcontroller
                                                        .processId,
                                                    modpackData:
                                                        installcontroller
                                                            .modpackData,
                                                    state:
                                                        installcontroller.state,
                                                    progress: installcontroller
                                                        .progress,
                                                    onCancel: () {
                                                      installcontroller
                                                          .cancel();
                                                    },
                                                    onDownload: () async {
                                                      if (checkForJava() ==
                                                          false) return;
                                                      installcontroller.install(
                                                          version:
                                                              _handler.version);
                                                    },
                                                    onOpen: () async {
                                                      installcontroller.start();
                                                    },
                                                  ));
                                })));
                  }
                  ;

                  return Container();
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
                                width: 220,
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
                            width: 215,
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
