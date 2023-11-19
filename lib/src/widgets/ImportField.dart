import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mclauncher4/src/getApiHandler.dart';
import 'package:mclauncher4/src/tasks/IO_controller.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:uuid/uuid.dart';

class ImportField extends StatefulWidget {
  const ImportField({Key? key}) : super(key: key);

  @override
  _ImportFieldState createState() => _ImportFieldState();
}

class _ImportFieldState extends State<ImportField> {
  int alpha = 255;

  ondownload(DropDoneDetails details) async {
    if (!(details.files.first.path.split(".").last == "zip") &&
        !(details.files.first.path.split(".").last == "mcmp")) return;

   print("start IMPORT");
   ImportExportController().import(details.files.first.path);
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
        onDragExited: (details) {
          setState(() {
            alpha = 255;
          });
        },
        onDragEntered: (details) {
          setState(() {
            alpha = 120;
          });
        },
        onDragDone: ondownload,
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withAlpha(alpha),
              borderRadius: BorderRadius.circular(18)),
          height: 240,
          width: double.infinity,
          child: Center(
            child: SvgPicture.asset('assets/svg/add-icon.svg'),
          ),
        ));
  }
}
