import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/models/dumf_model.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/widgets/file_table/file_table_item.dart';
import 'package:mclauncher4/src/widgets/file_table/file_table_shining.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class FileTable extends StatefulWidget {
  DUMF? details;
  FileTable({Key? key, this.details}) : super(key: key);

  @override
  _FileTableState createState() => _FileTableState();
}

class _FileTableState extends State<FileTable> {
  List<UMF>? versions;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    versions = widget.details?.versions;
    print("redo");
    return Column(children: [
      //TOP Drawer
      Row(
        children: [Text("Names"), Text("Authors"), Text("Version")],
      ),

      Expanded(
          child: Stack(children: [
        
            AnimatedOpacity(opacity: versions == null ? 1: 0, duration: Duration(milliseconds: 600), child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => FileTableShining(
                      index: index,
                    ))),
            AnimatedOpacity(opacity: versions != null ? 1: 0, duration: Duration(milliseconds: 600),child: DynMouseScroll(
                animationCurve: Curves.easeOutExpo,
                scrollSpeed: 0.4,
                durationMS: 500,
                builder: (context, _scrollController, physics) =>
                    ListView.builder(
                        controller: _scrollController,
                        physics: physics,
                        itemCount: versions!.length,
                        itemBuilder: (
                          BuildContext context,
                          int index,
                        ) =>
                            FileTableItem(
                              index: index,
                              umf: versions![index],
                            )))),
             
      ]))
    ]);
  }
}
