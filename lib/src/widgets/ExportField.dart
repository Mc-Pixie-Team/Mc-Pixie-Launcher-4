import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/IOController.dart';
import 'package:mclauncher4/src/widgets/components/editableTextField.dart';
import 'package:mclauncher4/src/widgets/divider.dart' as Divider;
import 'package:mclauncher4/src/widgets/explorer/explorer.dart';
import 'package:mclauncher4/src/widgets/explorer/fileListController.dart';

// ignore: must_be_immutable
class ExportField extends StatefulWidget {

  String processId = ""; 

   ExportField({Key? key, required this.processId}) : super(key: key);

  @override
  _ExportFieldState createState() => _ExportFieldState();
}

class _ExportFieldState extends State<ExportField> {
  TextEditingController textEditingController_1 = TextEditingController();
  TextEditingController textEditingController_2 = TextEditingController();




  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      width: 500,
      height: 800,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
       borderRadius: BorderRadius.circular(18),
       border: Border.all(width: 1.0, color: Color.fromARGB(255, 56, 56, 56))
      ),
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
              style: Theme.of(context)
                  .typography
                  .black
                  .headlineSmall,
            ),
          ),
          SizedBox(
            height: 18,
          ),
          Divider.Divider(
            size: 24,
          ),
          Expanded(
              child: SingleChildScrollView(
                  child: Padding(
            padding: EdgeInsets.only(left: 48),
            child: Column( crossAxisAlignment: CrossAxisAlignment.start,  children: [

                SizedBox(
            height: 22,
            width: double.infinity,
          ),
          Text("Profile Name:",
          
              style: Theme.of(context)
                  .typography
                  .black
                  .headlineSmall),
            SizedBox(
            height: 6,
          ),
          EditableTextField(height: 38, width: 241,),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text("Name of your modpack or server profile.\n(ex: MyModpack, Big recomming)",
            
                style: Theme.of(context)
                    .typography
                    .black
                    .bodySmall),
          ),
          SizedBox(
            height: 18,
          ),
           Text("Package Version:",
          
              style: Theme.of(context)
                  .typography
                  .black
                  .headlineSmall),
            SizedBox(
            height: 6,
          ),
          EditableTextField(height: 38, width: 241,),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text("Package Version. (ex: 1.0.0)",
            
                style: Theme.of(context)
                    .typography
                    .black
                    .bodySmall),
          ),
          SizedBox(
            height: 22,
          ),
          TextButton(onPressed: () => ImportExportController().export(widget.processId, FileList.files), child: Text('EXPORT_')),
          Text("Included Files:",
          
              style: Theme.of(context)
                  .typography
                  .black
                  .headlineSmall),
                   SizedBox(
            height: 10,
          ),
           Explorer()
            ]),
          )))
        ],
      ),
    );
  }
}
