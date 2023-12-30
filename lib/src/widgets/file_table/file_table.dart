import 'package:flutter/material.dart';
import 'package:mclauncher4/src/widgets/file_table/file_table_item.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class FileTable extends StatefulWidget {
  FileTable({ Key? key }) : super(key: key);

  @override
  _FileTableState createState() => _FileTableState();
}

class _FileTableState extends State<FileTable> {
  @override
  Widget build(BuildContext context) {
    return  Column(children: [
      //TOP Drawer
     Row(children: [
      Text("Names"),
      Text("Authors"),
      Text("Version")
     ],),
    
    Expanded(child: DynMouseScroll(
                  animationCurve: Curves.easeOutExpo,
                  scrollSpeed: 0.4,
                  durationMS: 500,
                  builder: (context, _scrollController, physics) => ListView.builder(controller: _scrollController, physics: physics, itemCount: 30, itemBuilder: (BuildContext context, int index, ) =>  FileTableItem(index: index,))))
    ],);
  }
}