import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mclauncher4/src/pages/providers/modlist_page.dart';

class TextIconButton extends StatefulWidget {
 EdgeInsets margin;
  VoidCallback onPressed;
  Widget icon;
  String text;
  TextIconButton({ Key? key, required this.onPressed, required this.text, required this.icon, this.margin = const EdgeInsets.only(left: 10, right: 49) }) : super(key: key);

  @override
  _TextIconButtonState createState() => _TextIconButtonState();
}

class _TextIconButtonState extends State<TextIconButton> {
  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
            onTap: widget.onPressed,
            child: Container(
              height: 38,
              width: 114,
              margin: widget.margin,
              padding: EdgeInsets.only(right: 3),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(8)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                widget.icon,
                  Text(
                    widget.text,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ));
  }
}