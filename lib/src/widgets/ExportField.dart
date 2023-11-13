import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/IOController.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/widgets/RoundedTextButton.dart';
import 'package:mclauncher4/src/widgets/components/editableTextField.dart';
import 'package:mclauncher4/src/widgets/divider.dart' as Divider;
import 'package:mclauncher4/src/widgets/explorer/explorer.dart';
import 'package:mclauncher4/src/widgets/explorer/fileListController.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:glowy_borders/glowy_borders.dart';
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
  Future<Directory> get getModpackDir async =>
  Directory(await getInstancePath() + "\\${widget.processId}");


   onPressed() async{
    print(isexporting);
    if(isexporting) return;
    isexporting = true;
 
   await ImportExportController.export(widget.processId, FileList.files, "${textEditingController_1.text}-${textEditingController_2.text}");
  Navigator.of(context).pop();
    //i know it is a bit cheap, but it works
    isexporting = false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBorder(
          animationTime: 3,
            borderSize: 1,
            glowSize: 10,
            gradientColors: [
              Colors.transparent,
              Colors.transparent,
              Colors.transparent,
              Colors.purple.shade50
            ],
            
            borderRadius: BorderRadius.all(Radius.circular(18)),
            child:   Container(
      clipBehavior: Clip.hardEdge,
      width: 500,
      height: 800,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
          border:
              Border.all(width: 1.0, color: Color.fromARGB(255, 56, 56, 56))),
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
          Divider.Divider(
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 30,
                width: double.infinity,
              ),
              Text("Profile Name:",
                  style: Theme.of(context).typography.black.headlineSmall),
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
                child: Text(
                    "Name of your modpack or server profile.\n(ex: MyModpack, Big recomming)",
                    style: Theme.of(context).typography.black.bodySmall),
              ),
              SizedBox(
                height: 18,
              ),
              Text("Package Version:",
                  style: Theme.of(context).typography.black.headlineSmall),
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
              Text("Included Files:",
                  style: Theme.of(context).typography.black.headlineSmall),
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
              SizedBox(width: 20,),
              SizedBox(width: 200, child:
              Text("Mods that aren’t regonized are automatically put to override",

                    style: Theme.of(context).typography.black.bodySmall)),
                    Expanded(child: Container(width: double.infinity,)),
            RoundedTextButton(onTap: () async => await onPressed(),),
              SizedBox(width: 20,),
            ],
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    ));
  }
}
