import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';

class FileTableItem extends StatefulWidget {
  int index;
  FileTableItem({Key? key, required this.index}) : super(key: key);

  @override
  _FileTableItemState createState() => _FileTableItemState();
}

class _FileTableItemState extends State<FileTableItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      width: double.infinity,
      margin: EdgeInsets.only(left: 28, right: 28),
      decoration: ShapeDecoration(
        color:
            widget.index.isOdd ? null : Theme.of(context).colorScheme.surface,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 7,
            cornerSmoothing: 1,
          ),
        ),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(width: 28,),
        Container(width: 29, height: 29, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(4) ), child: Text(widget.index.toString()),)
      ],),
    );
  }
}
