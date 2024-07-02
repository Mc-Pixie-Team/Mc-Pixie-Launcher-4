import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/IO_controller.dart';

import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/widgets/rounded_text_button.dart';
import 'package:mclauncher4/src/widgets/components/editable_text_field.dart';
import 'package:mclauncher4/src/widgets/divider.dart' as Divider;
import 'package:mclauncher4/src/widgets/explorer/explorer.dart';
import 'package:mclauncher4/src/widgets/explorer/file_listcontroller.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:path/path.dart' as path;


// ignore: must_be_immutable
class ExportField extends StatefulWidget {
  String processId = "";

  ExportField({Key? key, required this.processId}) : super(key: key);

  @override
  _ExportFieldState createState() => _ExportFieldState();
}

class _ExportFieldState extends State<ExportField> {
  bool isexporting = false;
  TextEditingController textEditingController_1 = TextEditingController();
  TextEditingController textEditingController_2 = TextEditingController();
  ImportExportController exportController = ImportExportController();

  Future<Directory> get getModpackDir async => Directory( path.join(getInstancePath(), widget.processId));

  onPressed() async {
    print(isexporting);
    if (isexporting) return;
    isexporting = true;

    await exportController.export(
        widget.processId, FileList.files, "${textEditingController_1.text}-${textEditingController_2.text}");
    Navigator.of(context).pop();
    //i know it is a bit cheap, but it works
    isexporting = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      width: 550,
      height: 800,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(width: 1.0, color: Color.fromARGB(255, 56, 56, 56))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 18,
          ),
          Padding(
            padding: EdgeInsets.only(left: 27),
            child: Text(
              'Export',
              style: Theme.of(context).typography.black.headlineSmall,
            ),
          ),
          SizedBox(
            height: 18,
          ),
          Divider.CustomDivider(
            size: 24,
          ),
          Expanded(
              child: DynMouseScroll(
                  animationCurve: Curves.easeOutExpo,
                  scrollSpeed: 1.0,
                  durationMS: 650,
                  builder: (context, _scrollController, physics) => SingleChildScrollView(
                      controller: _scrollController,
                      physics: physics,
                      child: Padding(
                        padding: EdgeInsets.only(left: 48),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          SizedBox(
                            height: 30,
                            width: double.infinity,
                          ),
                          Text("Profile Name:", style: Theme.of(context).typography.black.headlineSmall),
                          SizedBox(
                            height: 6,
                          ),
                          EditableTextField(
                            textController: textEditingController_1,
                            height: 38,
                            width: 241,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text("Name of your modpack or server profile.\n(ex: MyModpack, Big recomming)",
                                style: Theme.of(context).typography.black.bodySmall),
                          ),
                          SizedBox(
                            height: 18,
                          ),
                          Text("Package Version:", style: Theme.of(context).typography.black.headlineSmall),
                          SizedBox(
                            height: 6,
                          ),
                          EditableTextField(
                            textController: textEditingController_2,
                            height: 38,
                            width: 241,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text("Package Version. (ex: 1.0.0)",
                                style: Theme.of(context).typography.black.bodySmall),
                          ),
                          SizedBox(
                            height: 35,
                          ),
                          Text("Included Files:", style: Theme.of(context).typography.black.headlineSmall),
                          SizedBox(
                            height: 10,
                          ),
                          FutureBuilder(
                              future: getModpackDir,
                              builder: ((context, snapshot) => snapshot.hasData
                                  ? Explorer(
                                      rootDir: snapshot.data!,
                                    )
                                  : Container()))
                        ]),
                      )))),
          Row(
            children: [
              SizedBox(
                width: 20,
              ),
              SizedBox(
                  width: 150,
                  child: Text("Mods that aren’t regonized are automatically put to override",
                      style: Theme.of(context).typography.black.bodySmall)),
              Expanded(
                  child: Container(
                width: double.infinity,
              )),
              AnimatedBuilder(
                  animation: exportController,
                  builder: (context, child) => 
                  // exportController.state == ExportImport.notHandeled
                  //     ? Row(mainAxisSize: MainAxisSize.min, children: [
                  //         RoundedTextButton(
                  //           text: "Cancel",
                  //           onTap: () {
                  //             if (!isexporting) Navigator.of(context).pop();
                  //           },
                  //         ),
                  //         SizedBox(
                  //           width: 20,
                  //         ),
                  //         RoundedTextButton(
                  //           text: "Export",
                  //           onTap: () async => await onPressed(),
                  //         ),
                  //       ])
                  //     : 
                      SizedBox(
                          height: 50,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                            Text(
                              // exportController.state == ExportImport.fetching
                              //     ? 
                                  "Convert..."
                              //     : "${(exportController.progress * 100).round()}%",
                              // style: Theme.of(context).typography.black.bodyMedium
                              ,
                            ),
                            SizedBox(
                                width: 300,
                                height: 5,
                                child: LinearProgressIndicator(
                                  borderRadius: BorderRadius.circular(18),
                                  // value: exportController.state == ExportImport.fetching
                                  //     ? null
                                  //     : exportController.progress,
                                ))
                          ]))),
              SizedBox(
                width: 20,
              ),
            ],
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
