import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mclauncher4/src/app.dart';
import 'package:mclauncher4/src/widgets/components/autoGradient.dart';
import 'package:mclauncher4/src/widgets/components/gradiantText.dart';
import 'package:mclauncher4/src/widgets/loginCardSupabase.dart';

class pixieLoginScreen extends StatefulWidget {
  const pixieLoginScreen({Key? key}) : super(key: key);

  @override
  _pixieLoginScreenState createState() => _pixieLoginScreenState();
}

class _pixieLoginScreenState extends State<pixieLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  children: [LoginCardSupabase()],
                ),
              ),
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
