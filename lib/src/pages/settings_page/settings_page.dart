// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:mclauncher4/src/objects/accounts/minecraft.dart';

import 'package:mclauncher4/src/pages/user_page/side_panel_widget.dart';
import 'package:mclauncher4/src/pages/user_page/subPages/userAndMSPage.dart';
import 'package:mclauncher4/src/pages/user_page/text_field_with_enter.dart';
import 'package:mclauncher4/src/tasks/auth/microsoft.dart';
import 'package:mclauncher4/src/tasks/storrage/secure_storage.dart';
import 'package:mclauncher4/src/theme/scrollphysics.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        child: Align(
          alignment: Alignment.center,
          child: HexagonWidget(child: Container(color: Colors.amber, height: 200, width: 200,),)
        ));
  }
}

class HexagonWidget extends StatelessWidget {
  final Widget child;

  const HexagonWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
        clipBehavior: Clip.antiAlias, clipper: HexagonClipper(), child: child);
  }
}

class HexagonPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint hexagonPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    Path hexagonPath = getHexagonPath(size);
    canvas.drawPath(hexagonPath, hexagonPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

Path getHexagonPath(Size size) {
  double radius = size.width / 2;
  double centerX = size.width / 2;
  double centerY = size.height / 2;

  Path hexagonPath = Path();
  hexagonPath.moveTo(centerX + radius, centerY);
  for (int i = 1; i <= 6; i++) {
    double x = centerX + radius * cos(i * pi / 3);
    double y = centerY + radius * sin(i * pi / 3);
    hexagonPath.lineTo(x, y);
  }
  hexagonPath.close();
  return hexagonPath;
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path hexagonPath = getHexagonPath(size);
    return hexagonPath;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
