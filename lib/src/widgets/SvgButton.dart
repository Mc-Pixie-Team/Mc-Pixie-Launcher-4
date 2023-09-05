import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SvgButton extends StatefulWidget {
  SvgButton.asset(this.asset, {Key? key, required this.onpressed})
      : super(key: key);
  String asset;
  VoidCallback onpressed;
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
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onpressed,
        child: MouseRegion(
          child: SvgPicture.asset(widget.asset,
              color: Theme.of(context).colorScheme.primary.withOpacity(
                  Tween(begin: 1, end: 0.5)
                      .animate(_controller)
                      .value
                      .toDouble())),
          onEnter: (e) => _controller.forward(),
          onExit: (e) => _controller.reverse(),
        ));
  }
}
