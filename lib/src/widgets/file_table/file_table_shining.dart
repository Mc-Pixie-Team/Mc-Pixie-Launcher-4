import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'dart:math';

class FileTableShining extends StatefulWidget {
  int index;
  FileTableShining({Key? key, required this.index}) : super(key: key);

  @override
  _FileTableShiningState createState() => _FileTableShiningState();
}

class _FileTableShiningState extends State<FileTableShining>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    print(widget.index);
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: Random().nextInt(600) + 800))
          ..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    super.initState();
  }

  @override
  void dispose() {
    
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Opacity(
        opacity: _animation.value,
        child: child,
      ),
      child: Container(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 28,
            ),
            Container(
                width: 29,
                height: 29,
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 59, 59, 59),
                    borderRadius: BorderRadius.circular(4))),
          ],
        ),
      ),
    );
  }
}
