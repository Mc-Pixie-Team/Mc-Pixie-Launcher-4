import 'dart:convert';
import 'dart:io' show Directory, File, Platform, exit;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mclauncher4/src/objects/accounts/minecraft.dart';
import 'package:mclauncher4/src/pages/home_page/home_page.dart';
import 'package:mclauncher4/src/pages/debug_page.dart';
import 'package:mclauncher4/src/pages/installed_objects_handlers.dart';
import 'package:mclauncher4/src/pages/providers/modlist_page.dart';
import 'package:mclauncher4/src/pages/settings_page/settings_page.dart';
import 'package:mclauncher4/src/pages/splash/splash.dart';
import 'package:mclauncher4/src/pages/user_page/MSPage.dart';
import 'package:mclauncher4/src/pages/user_page/user_page.dart';
import 'package:mclauncher4/src/tasks/apis/curseforge.api.dart';
import 'package:mclauncher4/src/tasks/apis/modrinth.api.dart';
import 'package:mclauncher4/src/tasks/install_object_handler.dart';
import 'package:mclauncher4/src/tasks/models/navigator_key.dart';
import 'package:mclauncher4/src/tasks/models/object_type.dart';
import 'package:mclauncher4/src/tasks/models/settings_keys.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/widgets/coming_in_beta.dart';
import 'package:mclauncher4/src/widgets/internet_connection_checker.dart';
import 'package:mclauncher4/src/widgets/recently_played_list.dart';
import 'package:mclauncher4/src/widgets/side_panel/side_panel.dart';
import 'theme/colorSchemes.dart';
import 'theme/textSchemes.dart';
import 'package:flutter/material.dart';
import 'widgets/navigation_drawer/item_drawer.dart';
import 'package:window_manager/window_manager.dart';
import 'widgets/navigation_drawer/menu_item.dart';
import 'widgets/divider.dart' as div;
import 'package:animations/animations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices =>
      {PointerDeviceKind.touch, PointerDeviceKind.trackpad};

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
        return const BouncingScrollPhysics();
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return const ClampingScrollPhysics();
    }
  }
}

class McLauncher extends StatefulWidget {
  const McLauncher({super.key});

  @override
  State<StatefulWidget> createState() => _McLauncherState();
  // TODO: implement createState

  static _McLauncherState of(BuildContext context) =>
      context.findAncestorStateOfType<_McLauncherState>()!;
}

class _McLauncherState extends State<McLauncher> with WindowListener {
  Future<String> get customWait async {
    await Future.delayed(Duration(seconds: 10));
    return "done!";
  }

  late Widget mainWidget;
  ThemeMode _themeMode = ThemeMode.system;

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    mainWidget = buildMainWidget();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowFocus() {
    print("fouces lol");
    // Make sure to call once.
    setState(() {});
    // do something
  }

  Widget buildMainWidget() {
    return MaterialApp(
        // locale: Locale.fromSubtags(languageCode: "de"),
        scrollBehavior: MyCustomScrollBehavior(),
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        routes: {
          "/test": (context) => Material(child: Debugpage()),
        },
        theme: ThemeData(
            radioTheme: RadioThemeData(
                overlayColor: MaterialStatePropertyAll(Colors.transparent)),
            splashFactory: NoSplash.splashFactory,
            useMaterial3: true,
            colorScheme: lightColorScheme,
            typography: Typography(black: blackTextSchemes),
            scrollbarTheme: ScrollbarThemeData()),
        darkTheme: ThemeData(
            radioTheme: RadioThemeData(
                overlayColor: MaterialStatePropertyAll(Colors.transparent)),
            splashFactory: NoSplash.splashFactory,
            useMaterial3: true,
            colorScheme: darkColorScheme,
            typography: Typography(black: blackTextSchemes)),
        themeMode: _themeMode,
        home: MainPage(),
        builder: (context, child) => Stack(children: [
              child!,
              SizedBox(
                height: 35,
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [],
                    )),
              ),
            ]));
  }

  @override
  Widget build(BuildContext context) {
    rootContext = context;
    return mainWidget;
  }
}

class GlobalObjectHandler {
  static late final InstallObjectHandler handler;
}

// ignore: must_be_immutable
class MainPage extends StatefulWidget {
  int pageIndex = 1;
  int oldPageIndex = 1;
  MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late BuildContext innercontext;

  bool shouldSplashedDisplayed = true;
  bool isSplashed = true;

  EdgeInsets edgeInsets =
      EdgeInsets.only(left: 10, top: 12, right: 10, bottom: 12);

  late InstallObjectHandler installObjectHandler;

  List<Map> publicList = [];

  List<Widget> _pages(context) => [
        HomePage(
          publicModpackList: publicList,
          installObjectHandler: installObjectHandler,
        ),
        ModListPage(
          installObjectHandler: installObjectHandler,
          handler: new ModrinthApi(),
          key: Key("modrinth"),
        ),

        /* const Debugpage(), */
        ModListPage(
          installObjectHandler: installObjectHandler,
          handler: CurseforgeApi(),
          key: Key("curseforge"),
        ),
        Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(18)),
            child: ComingInBeta(
              key: Key("pixie"),
            )),
        Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(18)),
            child: ComingInBeta(
              key: Key("ftb"),
            )),
        const SettingsPage(),
        const MSPage(),
      ];

  @override
  initState() {
    _preinit();
    _init();
    super.initState();
  }

  _preinit() {
    isSplashed = shouldSplashedDisplayed;
    installObjectHandler = InstallObjectHandler(
        types: [ObjectType.modpack], path: getInstancePath());
    GlobalObjectHandler.handler = installObjectHandler;
  }

  _init() async {
    await MinecraftAccountUtils().initOnFirstStart();
    await installObjectHandler.initialize();
    if (!(await Directory(getHTMLcachePath()).exists())) {
      await Directory(getHTMLcachePath()).create(recursive: true);
    }

    List<String> htmlFiles = [
      "index.html",
      "styles.css"
    ];
    for (var file in htmlFiles) {
      await _copyHtmlChache(file);
    }

    publicList = await getPublicList();
    setState(() {
      isSplashed = false;
    });
  }

  Future _copyHtmlChache(String file) async {
    ByteData data = await rootBundle.load("assets/htmlcache/$file");
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    String path = p.join(getHTMLcachePath(), file);
    await File(path).writeAsBytes(bytes);
  }

  Future<List<Map>> getPublicList() async {
    print("test");
    var res = await http
        .get(Uri.parse("https://mc-pixie.com/api/modpacks/publiclist"))
        .timeout(Duration(seconds: 20));
    List publicList = await jsonDecode(utf8.decode(res.bodyBytes))["data"];
    List<Map> return_value = [];

    for (var listitem in publicList) {
      if (listitem is Map) {
        return_value.add(listitem);
      }
    }
    ;

    return return_value;
  }

  RectTween _createRectTween(Rect? begin, Rect? end) {
    return MaterialRectArcTween(begin: begin, end: end);
  }

  Navigator _getNavigator(BuildContext context) {
    return Navigator(
      initialRoute: "/",
      observers: [HeroController(createRectTween: _createRectTween)],
      onGenerateRoute: (RouteSettings settings) {
        print(settings.name);
        //you need to code the routes using settings == "[route name]"
        return CupertinoPageRoute(
            settings: settings,
            builder: (context) {
              innercontext = context;
              return PageTransitionSwitcher(
                duration: const Duration(milliseconds: 400),
                reverse: widget.pageIndex < widget.oldPageIndex,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    key: UniqueKey(),
                    child: _pages(context)[widget.pageIndex]),
                transitionBuilder:
                    (child, primaryAnimation, secondaryAnimation) =>
                        SharedAxisTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.vertical,
                  fillColor: Colors.transparent,
                  child: child,
                ),
              );
            });
      },
    );
  }

  void onDrawerChange(int index) async {
    widget.oldPageIndex = widget.pageIndex;

    if (index != widget.oldPageIndex) {
      if (Navigator.canPop(innercontext)) {
        Navigator.popUntil(innercontext, (route) {
          return route.settings.name == "/";
        });
        await Future.delayed(Duration(milliseconds: 450));
      }
      setState(() {
        widget.pageIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      isSplashed
          ? Container(
              height: double.infinity,
              width: double.infinity,
              child: SplashScreen(),
            )
          : Container(),
      AnimatedOpacity(
          opacity: isSplashed ? 0.0 : 1.0,
          curve: Curves.linear,
          duration: Duration(milliseconds: 400),
          child: isSplashed
              ? SizedBox.shrink()
              : Row(
                  children: [
                    Container(
                      height: double.infinity,
                      width: 200,
                      decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.surfaceContainer),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            height: Platform.isMacOS ? 40 : 28,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 30),
                            child: Align(
                              child: MenuItem(
                                onClick: () => onDrawerChange(6),
                                title: "Profile",
                                icon: Icon(
                                  Icons.person,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 15,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 30),
                            child: MenuItem(
                              onClick: () => onDrawerChange(5),
                              title: "Settings",
                              icon: Icon(
                                Icons.settings,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          Padding(
                              child: div.CustomDivider(
                                size: 20,
                              ),
                              padding: EdgeInsets.only(top: 20, bottom: 20)),
                          ItemDrawer(
                              offset: 0,
                              onChange: (index) {
                                index = index + 1;
                                onDrawerChange(index);
                              },
                              title: "providers",
                              children: <ItemDrawerItem>[
                                ItemDrawerItem(
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                  ),
                                  title: 'Modrinth',
                                ),
                                ItemDrawerItem(
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                  ),
                                  title: 'Curseforge',
                                ),
                                ItemDrawerItem(
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                  ),
                                  title: 'Pixie',
                                ),
                                ItemDrawerItem(
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                  ),
                                  title: 'FTB',
                                ),
                              ]),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 15, right: 15, top: 10, bottom: 17),
                              child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHigh,
                                      borderRadius: BorderRadius.all(
                                          Radius.elliptical(18, 18))),
                                  width: double.infinity,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: 15,
                                        right: 15,
                                      ),
                                      child: MenuItem(
                                        width: 140,
                                        onClick: () async {
                                          int index = 0;
                                          print('change: ' + index.toString());
                                          widget.oldPageIndex =
                                              widget.pageIndex;

                                          if (Navigator.canPop(innercontext)) {
                                            Navigator.popUntil(innercontext,
                                                (route) {
                                              return route.settings.name == "/";
                                            });

                                            await Future.delayed(
                                                Duration(milliseconds: 450));
                                          }
                                          if (index != widget.oldPageIndex) {
                                            setState(() {
                                              widget.pageIndex = index;
                                            });
                                          }
                                        },
                                        title: "My Modpacks",
                                        icon: Icon(
                                          Icons.folder,
                                          size: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ),
                                  ))),
                          div.CustomDivider(
                            size: 20,
                          ),
                          Expanded(child: SizedBox.expand()),
                          // Expanded(child:Padding(padding: EdgeInsets.only(left: 15, right: 15, top: 23), child:
                          // RecentlyPlayedList(installObjectHandler: installObjectHandler,))),
                          Text(
                            "Alpha Build!",
                            textAlign: TextAlign.start,
                            style: Theme.of(context)
                                .typography
                                .black
                                .bodySmall!
                                .copyWith(
                                    color: Color.fromARGB(110, 197, 197, 197)),
                          ),
                          Text(
                            "OS: ${Platform.operatingSystemVersion}, Lang: ${Platform.localeName}",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .typography
                                .black
                                .bodySmall!
                                .copyWith(
                                    color: Color.fromARGB(69, 189, 189, 189)),
                          ),
                          SizedBox(
                            height: 15,
                          )
                        ],
                      ),
                    ),
                    Expanded(
                        child: Padding(
                            padding: edgeInsets,
                            child: _getNavigator(context))),

                    SidePanel(
                      controller: StaticSidePanelController.controller,
                    )

                    // SizeTransition(sizeFactor: 1, child: Padding(padding: edgeInsets,),)
                  ],
                )),
      SizedBox(
          height: 30,
          child: WindowCaption(
            brightness: Brightness.dark,
            backgroundColor: Colors.transparent,
          ))
    ]));
  }
}

/* class WindowButtons extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //Code by Mc-PIXIE

        MinimizeWindowButton(
          colors: buttonColors,
        ),
        MaximizeWindowButton(
          colors: buttonColors,
        ),
        CloseWindowButton(
            colors: closebuttonColors,
            onPressed: () {
              print('close');
              exit(0);
            }),
      ],
    );
  }
} */
class WindowButtons extends StatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  _WindowButtonsState createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  late var listener;
  bool isConnected = true;

  @override
  void initState() {
    // TODO: implement initState
    isConnected = InternetConnectionCheckerHelper().hasConnection;
    listener = InternetConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          print('Data connection is available.');
          setState(() {
            isConnected = true;
          });
          break;
        case InternetConnectionStatus.disconnected:
          print('You are disconnected from the internet.');
          setState(() {
            isConnected = false;
          });
          break;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //Code by Mc-PIXIE
        !isConnected
            ? IgnorePointer(
                child: Padding(
                padding: const EdgeInsets.only(
                  top: 13,
                ),
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: Theme.of(context).colorScheme.error,
                          width: 3)),
                  width: 90,
                  height: 25,
                  child: Center(
                    child: (Text(
                      "OFFLINE",
                      style: Theme.of(context)
                          .typography
                          .black
                          .labelMedium!
                          .copyWith(
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2),
                    )),
                  ),
                ),
              ))
            : SizedBox.shrink(),

//HERE SE BUTTONS
      ],
    );
  }
}
