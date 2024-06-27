import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class SvgButton extends StatefulWidget {
  double? height;
  double? width;
  EdgeInsets? padding;
  String asset;
  Color? color;
  VoidCallback onpressed;
  Widget? text;

  SvgButton.asset(this.asset,
      {Key? key, required this.onpressed, this.color, this.text, this.height, this.width, this.padding})
      : super(key: key);

  @override
  _SvgButtonState createState() => _SvgButtonState();
}

class _SvgButtonState extends State<SvgButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 120));
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onpressed,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(padding: widget.padding, height: widget.height, width: widget.width, child: SvgPicture.asset(widget.asset,
                  color: (widget.color ?? Theme.of(context).colorScheme.primary)
                      .withOpacity(Tween(begin: 1, end: 0.5)
                          .animate(_controller)
                          .value
                          .toDouble()))),
          onEnter: (e) => _controller.forward(),
          onExit: (e) => _controller.reverse(),
        ));
  }
}
