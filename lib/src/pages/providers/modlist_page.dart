// ignore_for_file: sort_child_properties_last




import 'package:flutter/widgets.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mclauncher4/src/get_api_handler.dart';

import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/install_controller.dart';
import 'package:mclauncher4/src/tasks/models/trigger_model.dart';
import 'package:mclauncher4/src/widgets/buttons/circular_button.dart';
import 'package:mclauncher4/src/widgets/cards/browse_card.dart';
import 'package:mclauncher4/src/widgets/components/fade_in_animation.dart';
import 'package:mclauncher4/src/widgets/components/slide_in_animation.dart';
import 'package:mclauncher4/src/widgets/filter_list.dart';
import 'package:mclauncher4/src/widgets/internet_connection_checker.dart';
import 'package:mclauncher4/src/widgets/offlineIcon.dart';
import 'package:mclauncher4/src/widgets/providers_widget/dropdown_menu.dart';
import 'package:mclauncher4/src/widgets/searchbar.dart' as Searchbar;
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/widgets/divider.dart' as Divider;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class ModListPage extends StatefulWidget {
  Api handler;
  String? rootinstanceName;
  bool isReturnable;
  ModListPage(
      {Key? key,
      required this.handler,
      this.rootinstanceName,
      this.isReturnable = false})
      : super(key: key);

  @override
  _ModListPageState createState() => _ModListPageState();
}

class _ModListPageState extends State<ModListPage>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollController = ScrollController();
  late Widget addButton;
  GlobalKey key = new GlobalKey();
  List installContollers = [];

  List<Widget> filters = [];

  List<String> categories = [];

  List<String> mcVersions = [];

  Trigger _trigger = Trigger();

  List? objects;

  bool hasError = false;

  bool get hasConnection => InternetConnectionCheckerHelper().hasConnection && !hasError ;

  Future<void> modpackInit() async {
    try {
    categories = await widget.handler.getCategories();
    mcVersions = await widget.handler.getAllMV();
    objects = await widget.handler.getModpackList();
    } catch (e) {
      print(e);
      hasError = true;
    }
    
    setState(() {});
  }

  bool iscalled = false;
  String querytext = "";
  List filterStrings = [];
  getMoreData() async {
    if (iscalled) return;
    iscalled = true;
    print('getmore data');
    List rawModpacks = await widget.handler.getMoreModpacks();
    objects!.addAll(rawModpacks);
    installContollers.addAll(List.generate(
        rawModpacks.length,
        (index) => InstallController(
            handler: widget.handler,
            modpackData: widget.handler.convertToLiteUMF(rawModpacks[index]),
            processid: widget.rootinstanceName)));
    setState(() {});
    iscalled = false;
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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => postFrameCallback(context));
    super.initState();
  }

  void postFrameCallback(context) {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          (_scrollController.position.maxScrollExtent)) {
        print('new');
        await getMoreData();
      }
    });

    modpackInit();
  }
  
   void reload() async{

    objects = null;
     _trigger.trigger();
    await modpackInit();
    _trigger.trigger();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: InternetConnectionChecker().onStatusChange,
      builder: (context, snapshot) {
        
        
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
                      AppLocalizations.of(context)!.modpacksProvided + ":",
                      style: Theme.of(context).typography.black.bodySmall,
                    )),
              ),
              Padding(
                padding: EdgeInsets.only(left: 30, bottom: 28),
                child: SlideInAnimation(
                    child: Text(
                  widget.handler.getTitlename(),
                  style: Theme.of(context).typography.black.displaySmall,
                )),
              ),
              Divider.CustomDivider(
                size: 14,
              ),
              SizedBox(
                height: 8,
              ),
           AnimatedBuilder(animation: _trigger, builder: (context, child) =>  objects == null  
                  ? Container()
                  :  Expanded(child:   FadeInAnimation(child: buildModpackList(context))))
            ],
          ), 
         objects != null && hasConnection  ?   Positioned.fill(
              top: 12,
              right: 12,
              child: FadeInAnimation(child:  SlideInAnimation(curve: Curves.easeOutExpo, child: Container(
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
                            child: FilterList(
                              categories: categories,
                              addCategory: (category) {
                                widget.handler.addCategory(category);
                              },
                              removeCategory: (category) {  
                                print("remove");
                                widget.handler.removeCategory(category);
                                reload();
                              },
                            ))),
                    SizedBox(
                      width: 10,
                    ),
                    Dropdownmenu(
                      registry: mcVersions,
                      onchange: (text, oldtext) {
                        key = new GlobalKey();

                        widget.handler.searchMV(text);
                        reload();
                      },
                    ),
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
                        widget.handler.query = querytext;
                        reload();
                      },
                    ),
                  ],
                ),
              )))) : Container(),
          widget.isReturnable
              ? Positioned(
                  top: 0,
                  left: 20,
                  child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 200,
                          height: 50,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Transform.rotate(
                                  angle: 1.6,
                                  child: SvgPicture.asset(
                                    'assets/svg/dropdown-icon.svg',
                                    height: 8,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(left: 14, bottom: 1),
                                  child: Text(
                                      AppLocalizations.of(context)!.homepage,
                                      style: Theme.of(context)
                                          .typography
                                          .black
                                          .titleSmall)),
                              Expanded(child: Container()),
                              SizedBox(
                                width: 15,
                              )
                            ],
                          ),
                        ),
                      )))
              : Container(),
       objects == null ?   Center(
                      child:  hasConnection ? SizedBox(
                        height: 50,
                        width: 50,
                        child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Theme.of(context).colorScheme.primary,
                            size: 30),
                      ):  OfflineIcon(size: 50, text: hasConnection ? "Your are currently offline!" : "We couldn't establish a connection to ${widget.handler.getTitlename()}!",))
                     : Container()
        ])
        );});
  }

  Widget buildModpackList(BuildContext context) {
    print(widget.handler.getTitlename());
    return Center(child: ShaderMask(
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
        child: ListView.builder(
            controller: _scrollController,
            itemCount: objects!.length + 1,
            itemBuilder: ((context, index) {
              if (index == objects!.length) {
                return SizedBox(
                    height: 100,
                    child: Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Theme.of(context).colorScheme.primary,
                            size: 30)));
              }
              print("generating new InstallController...");
              InstallController installcontroller = InstallController(
              isVersion: false,
              handler: widget.handler,
              modpackData: widget.handler.convertToLiteUMF(objects![index]),
              processid: widget.rootinstanceName);

              return BrowseCard(
                key: Key(installcontroller.processId),
                installModel: installcontroller.installModel,
                handlerString: widget.handler.getidname,
                processId: installcontroller.processId,
                modpackData: installcontroller.modpackData,
                onCancel: () {
                  installcontroller.cancel();
                },
                onDownload: () async {
                  installcontroller.install(version: widget.handler.version);
                },
                onOpen: () async {
                  installcontroller.start();
                },
              );
            }))));
  }
}
