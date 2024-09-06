import 'dart:async';
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mclauncher4/src/pages/installed_mod/installed_home_page.dart';
import 'package:mclauncher4/src/pages/installed_mod/installed_mods_page.dart';
import 'package:mclauncher4/src/pages/providers/modlist_page.dart';
import 'package:mclauncher4/src/tasks/apis/curseforge.api.dart';
import 'package:mclauncher4/src/tasks/install_object_handler.dart';
import 'package:mclauncher4/src/tasks/installs/install_model.dart';
import 'package:mclauncher4/src/tasks/models/modloader_type.dart';
import 'package:mclauncher4/src/tasks/models/object_type.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:mclauncher4/src/theme/custom_page_transition.dart';
import 'package:mclauncher4/src/widgets/buttons/text_icon_button.dart';
import 'package:mclauncher4/src/widgets/coming_in_beta.dart';
import 'package:mclauncher4/src/widgets/components/slide_in_animation.dart';
import 'package:mclauncher4/src/widgets/searchbar.dart';
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
    required this.controllerInstance,
  });

  @override
  _InstalledModPageState createState() => _InstalledModPageState();
}

class _InstalledModPageState extends State<InstalledModPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<String> commandline = [];

  ScrollController scrollController = ScrollController();

  String searchquery = "";

  ObjectType? currentType;

  late Map<String, Map> _pages;

  late String _pageKey;

  late InstallObjectHandler _handler;

  @override
  void dispose() {
      super.dispose();
    if (!_handler.isdisposed) {
      print("dispose");
      _handler.dispose();
    }
    
  }

  List<ObjectType> types = [
    ObjectType.mod,
    ObjectType.resource,
    ObjectType.shader,
  ];

  @override
  void initState() {
    super.initState();

    widget.controllerInstance.installModel.addListener(() {
      if(_handler.isdisposed) return;
      setState(() {});
    });

    _handler = InstallObjectHandler(
      types: types,
      processId: widget.controllerInstance.processId,
      path: path.join(getInstancePath(), widget.controllerInstance.processId),
    );

    _handler.initialize();

    widget.controllerInstance.addBeforeDeleteListener(() {
      if (!_handler.isdisposed) {
        print("dispose");
        _handler.dispose();
      }
    });

    generatePages();

    _pageKey = _pages.keys.toList()[1];
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

  generatePages() {
    Map pagesTypes = Map.fromIterable(types,
        key: (type) => ObjectTypeTools.toName(type),
        value: (type) => {
              "type": type,
              "page": AnimatedBuilder(
                 key: Key(type.toString()),
                  animation: _handler,
                  builder: (context, child) => _handler.isFetching
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Loading Mods...", style: Theme.of(context).typography.black.titleSmall,),
                              SizedBox(
                                height: 50,
                                width: 50,
                                child: LoadingAnimationWidget.staggeredDotsWave(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 30),
                              )
                            ],
                          ),
                        )
                      : AnimatedBuilder(
                         
                          animation: _handler.installControllers,
                          builder: (context, child) {
                            List<InstallController> sortedList =
                                _handler.installControllers.value.toList();

                            if (!searchquery.isEmpty)
                              sortedList.removeWhere((element) =>
                                  !((element.modpackData.name!.toUpperCase())
                                      .contains(searchquery.toUpperCase())));

                            return ModsPage(
                                installControllers: sortedList,
                                type: type,
                                instanceName:
                                    widget.controllerInstance.processId);
                          })),
            });

    _pages = {
      "Console": {
        "page": Container(
          margin: EdgeInsets.only(left: 50, right: 50, bottom: 50),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color.fromARGB(120, 0, 0, 0)),
          child: ComingInBeta(),
        ),
        "type": null,
      },
      ...pagesTypes
    };
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
    print("build");
    super.build(context);
    return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 40,
              ),
              Stack(
                fit: StackFit.loose,
                children: [
                  Container(
                      width: double.infinity,
                      child: ModpackTitleIconWidget(
                        alterIconPath: path.join(getInstancePath(),
                            widget.controllerInstance.processid, "icon.png"),
                        modloader:
                            widget.controllerInstance.modpackData.modloader !=
                                    null
                                ? ModloaderTypeTools.toName(widget
                                    .controllerInstance.modpackData.modloader!)
                                : "",
                        downloads:
                            widget.controllerInstance.modpackData.downloads,
                        iconUrl: widget.controllerInstance.modpackData.icon,
                        mcVersion:
                            widget.controllerInstance.modpackData.MCVersion,
                        mlVersion:
                            widget.controllerInstance.modpackData.MLVersion ??
                                "fd",
                        name: widget.controllerInstance.modpackData.name,
                      )),
                  Positioned(
                      right: 0,
                      bottom: 0,
                      child: AnimatedBuilder(
                          animation: widget.controllerInstance.installModel,
                          builder: (BuildContext context, Widget? child) =>
                              ModpackActionsMenu(
                                  onDelete: () => onDelete(context),
                                  onPlay: onPlay,
                                  onSecondMenuItem: onOpenFolder,
                                  state: widget.controllerInstance.installModel
                                      .installState,
                                  progress: widget.controllerInstance
                                      .installModel.progress))),
                ],
              ),
              const SizedBox(
                height: 55,
              ),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ...List.generate(_pages.keys.length, (index) {
                  var key = _pages.keys.toList()[index];
                  return Padding(
                    padding: EdgeInsets.only(left: 40),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        currentType = _pages[key]!["type"];
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
                Expanded(
                    child: SizedBox(
                  height: 0,
                  width: double.infinity,
                )),
                AnimatedOpacity(
                    opacity: currentType == null ? 0 : 1,
                    duration: Duration(milliseconds: 400),
                    child: Searchbar(
                      borderRadius: BorderRadius.circular(10),
                      expandedWidth: 170,
                      iconColor: Theme.of(context).colorScheme.primary,
                      onchange: (text) {
                        if (currentType == null) return;
                        searchquery = text;
                        setState(() {
                          generatePages();
                        });
                      },
                      onsubmit: () {},
                    )),
                AnimatedOpacity(
                    opacity: currentType == null ? 0 : 1,
                    duration: Duration(milliseconds: 400),
                    child: TextIconButton(
                      onPressed: () {
                        if (currentType == null) return;
                        var curseforgeapi = CurseforgeApi();
                        curseforgeapi.setObjectType(currentType!);
                        curseforgeapi.searchMV(
                            widget.controllerInstance.modpackData.MCVersion!);

                        if (currentType == ObjectType.mod) {
                          curseforgeapi.searchML(
                              widget.controllerInstance.modpackData.modloader);
                        }
                        Navigator.of(context).push(SlowCupertinoPageRoute(
                            allowSnapshotting: false,
                            maintainState: true,
                            builder: (context) => ModListPage(
                                  installObjectHandler: _handler,
                                  handler: curseforgeapi,
                                  rootinstanceName:
                                      widget.controllerInstance.processid,
                                  isReturnable: true,
                                )));
                      },
                      text: "Add Object",
                      icon: SvgPicture.asset("assets/svg/add-icon.svg",
                          height: 15,
                          width: 15,
                          color: Theme.of(context).colorScheme.primary),
                    ))
              ]),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                  child: PageTransitionSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _pages[_pageKey]!["page"],
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
        ));
  }
}
