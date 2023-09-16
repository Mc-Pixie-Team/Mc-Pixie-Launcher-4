import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mclauncher4/src/app.dart';
import 'package:mclauncher4/src/tasks/auth/supabase.dart';
import 'package:mclauncher4/src/widgets/autoGradient.dart';
import 'package:mclauncher4/src/widgets/gradiantText.dart';
import "package:mclauncher4/src/tasks/auth/supabase.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.pop(context);
      }),
      body: Stack(children: [
        Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: RadialGradient(
              stops: [0.1, 0.9],
              colors: [Color(0xff151515), Color(0xff0D0D0D)],
            )),
            child: Stack(children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GradientTextWidget(
                      text: "Hello, ||mumslyer_2023_yt||?",
                      gradient: LinearGradient(
                          //stops: [0, 1],
                          begin: Alignment.topLeft,
                          end: Alignment(1, 1),
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.tertiary,
                          ]),
                      textStyle: Theme.of(context).typography.black.headlineLarge!,
                    )
                  ],
                ),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Joshi", style: Theme.of(context).typography.black.bodyLarge),
                        Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Container(
                              width: 1,
                              height: 20,
                              color: Theme.of(context).colorScheme.outline,
                            )),
                        Text("MC-Pixie inc ©", style: Theme.of(context).typography.black.bodyLarge),
                        Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Container(
                              width: 1,
                              height: 20,
                              color: Theme.of(context).colorScheme.outline,
                            )),
                        Text("Matze", style: Theme.of(context).typography.black.bodyLarge),
                      ],
                    ),
                  ))
            ])),
        SizedBox(
          height: 35,
          child: Align(
              alignment: Alignment.topLeft,
              child: Row(
                children: [Expanded(child: MoveWindow()), WindowButtons()],
              )),
        )
      ]),
    );
  }
}