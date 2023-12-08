import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class RoundedTextButton extends StatefulWidget {
  double height;
  double width;
  VoidCallback onTap;
  String text;
  RoundedTextButton({Key? key, required this.text, required this.onTap, this.height = 55, this.width = 155})
      : super(key: key);

  @override
  _RoundedTextButtonState createState() => _RoundedTextButtonState();
}

class _RoundedTextButtonState extends State<RoundedTextButton> {
  bool ispressed = false;
  bool ishovered = false;
  void onDown(TapDownDetails details) {
    setState(() {
      ispressed = true;
    });
  }

  void onUp(TapUpDetails details) {
    setState(() {
      ispressed = false;
    });

    widget.onTap.call();
  }

  void onEnter(PointerEnterEvent event) {
    setState(() {
      ishovered = true;
    });
  }

  void onExit(PointerExitEvent event) {
    setState(() {
      ishovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onEnter: onEnter,
        onExit: onExit,
        child: GestureDetector(
            onTapDown: onDown,
            onTapUp: onUp,
            child: SizedBox(
                height: widget.height,
                width: widget.width,
                child: Center(
                  child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeOutQuart,
                      height: ispressed ? max(widget.height - 10, 10) : widget.height,
                      width: ispressed ? max(widget.width - 20, 10) : widget.width,
                      decoration: BoxDecoration(
                          color: ishovered ? Color.fromARGB(255, 48, 48, 48) : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8)),
                      child: Center(
                        child: Text(
                          widget.text,
                          style: Theme.of(context).typography.black.headlineSmall,
                        ),
                      )),
                ))));
  }
}
