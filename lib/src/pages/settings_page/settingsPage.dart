import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:mclauncher4/src/objects/accounts/minecraft.dart';
import 'package:mclauncher4/src/pages/user_page/sidePanelWidget.dart';
import 'package:mclauncher4/src/pages/user_page/subPages/userAndMSPage.dart';
import 'package:mclauncher4/src/pages/user_page/textFieldWithEnter.dart';
import 'package:mclauncher4/src/tasks/auth/microsoft.dart';
import 'package:mclauncher4/src/tasks/storrage/secureStorrage.dart';
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
        child: Text(
          "Somebody has to implement this 🤔🤔🤔🤔🤔",
          style: Theme.of(context).typography.black.headlineLarge,
        ),
      ),
    );
  }
}
