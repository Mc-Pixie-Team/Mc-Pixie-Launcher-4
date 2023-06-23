import 'dart:io';
import 'theme/colorSchemes.dart';
import 'theme/textSchemes.dart';
import 'package:flutter/material.dart';
import 'widgets/itemDrawer.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'widgets/menuItem.dart';
import 'widgets/divider.dart' as Div;

class McLauncher extends StatelessWidget {
  const McLauncher({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme,
          typography: Typography(black: blackTextSchemes)),
      darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          typography: Typography(black: blackTextSchemes)),
      themeMode: ThemeMode.dark,
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Row(
        children: [
          Container(
            height: double.infinity,
            width: 200,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant),
            child: Column(
              children: [
                Container(
                  height: 28,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: MenuItem(
                    title: 'Profile',
                    icon: Icon(
                      Icons.person,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Container(
                  height: 15,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: MenuItem(
                    title: 'Settings',
                    icon: Icon(
                      Icons.settings,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Padding(
                    child: Div.Divider(
                      size: 20,
                    ),
                    padding: EdgeInsets.only(top: 20, bottom: 20)),
                ItemDrawer(
                  callback: ( e) {
                    print(e);
                  },
                  title: 'Providers',
                  children: [
                  ItemDrawerItem(
                    
                    icon: Icon(
                      Icons.sms,
                      size: 14,
                    ),
                    title: 'Curseforge',
                  )
                ])
              ],
            ),
          ),
        ],
      ),
      SizedBox(
        height: 35,
        child: Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [Expanded(child: MoveWindow()), WindowButtons()],
            )),
      )
    ]));
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: const Color.fromARGB(255, 0, 0, 0),
    mouseOver: const Color.fromARGB(255, 233, 30, 98),
    mouseDown: const Color(0xFFB71C1C), //Code by Mc-PIXIE
    iconMouseOver: const Color.fromARGB(255, 255, 255, 255),
    iconMouseDown: const Color.fromARGB(255, 255, 255, 255));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color.fromARGB(126, 117, 185, 194),
    mouseDown: const Color.fromARGB(43, 0, 187, 212),
    iconNormal: const Color(0xFFFFB0C8),
    iconMouseOver: const Color.fromARGB(255, 233, 30, 98));

class WindowButtons extends StatelessWidget {
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
          colors: closeButtonColors,
          onPressed: () {
            print('close');
            exit(0);
          },
        ),
      ],
    );
  }
}
