import 'package:flutter/material.dart';

class AnimatedText extends StatefulWidget {
  String text;
  String get getText => text;
  Duration duration;
  TextStyle? style;
  AnimatedText(String this.text, {Key? key, required this.duration, this.style})
      : super(
          key: key,
        );

  @override
  _AnimatedTextState createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  String? oldText;

  late AnimationController _controller;
  late Animation _ani;
  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _ani = CurveTween(curve: Curves.easeOutExpo).animate(_controller);
    _ani.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  void didUpdateWidget(covariant AnimatedText oldWidget) {
    this.oldText = oldWidget.getText;
    if (oldWidget.getText != widget.getText) {
      _controller.reset();
      _controller.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        child: Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Stack(
              children: [
                Opacity(
                    opacity: Tween(begin: 1.0, end: 0.0)
                        .transform(_ani.value as double),
                    child: Transform.scale(
                      transformHitTests: false,
                      scale: Tween(begin: 1.0, end: 0.0)
                          .transform(_ani.value as double),
                      child: Text(oldText ?? widget.text, style: widget.style),
                    )),
                Opacity(
                    opacity: _ani.value as double,
                    child: Transform.scale(
                      transformHitTests: false,
                      scale: _ani.value as double,
                      child: Text(
                        widget.text,
                        style: widget.style,
                      ),
                    ))
              ],
            )));
  }
}
