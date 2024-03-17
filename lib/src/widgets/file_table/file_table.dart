import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/models/dumf_model.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/widgets/file_table/file_table_item.dart';
import 'package:mclauncher4/src/widgets/file_table/file_table_shining.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:mclauncher4/src/widgets/divider.dart' as divider;

class FileTable extends StatefulWidget {
  DUMF? details;
  String? providerString;
  FileTable({Key? key, this.details, this.providerString}) : super(key: key);

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
    return Column(children: [
      //TOP Drawer
      Row(
        children: [
          SizedBox(
            width: 60,
          ),
          Text(
            "Names",
            style: Theme.of(context).typography.black.bodySmall!.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
          SizedBox(
            width: 235,
          ),
          Text(" Authors",
              style: Theme.of(context).typography.black.bodySmall!.copyWith(color: Theme.of(context).colorScheme.outline)),
          SizedBox(
            width: 80,
          ),
          Text(" Version",
              style: Theme.of(context).typography.black.bodySmall!.copyWith(color: Theme.of(context).colorScheme.outline))
        ],
      ),
      SizedBox(height: 8,),
       divider.CustomDivider(size: 30,),
      Expanded(
          child: Stack(children: [
        AnimatedOpacity(
            opacity: versions == null ? 1 : 0,
            duration: Duration(milliseconds: 600),
            child: versions == null
                ? ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => FileTableShining(
                          index: index,
                        ))
                : Container()),
        AnimatedOpacity(
            opacity: versions != null ? 1 : 0,
            duration: Duration(milliseconds: 600),
            child: DynMouseScroll(
                animationCurve: Curves.easeOutExpo,
                scrollSpeed: 0.4,
                durationMS: 500,
                builder: (context, _scrollController, physics) =>
                    versions != null
                        ? 
                        
                       ListView.builder(
                            controller: _scrollController,
                            physics: physics,
                            itemCount: versions!.length,
                            itemBuilder: (
                              BuildContext context,
                              int index,
                            ) =>
                                FileTableItem(
                                  providerString: widget.providerString!,
                                  index: index,
                                  umf: versions![index],
                                ))
                        : Container())),
      ]))
    ]);
  }
}
