import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SvgButton extends StatefulWidget {
  SvgButton.asset(this.asset,
      {Key? key, required this.onpressed, this.color, this.text})
      : super(key: key);
  String asset;
  Color? color;
  VoidCallback onpressed;
  Widget? text;
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
          child: SizedBox(
              child: Row(children: [ SvgPicture.asset(widget.asset,
                  color: (widget.color ?? Theme.of(context).colorScheme.primary)
                      .withOpacity(Tween(begin: 1, end: 0.5)
                          .animate(_controller)
                          .value
                          .toDouble())),
                          
                          ... widget.text != null ? [
                            SizedBox(width: 20,),
                            widget.text!
                          ] :[]
                          
                          ])),
          onEnter: (e) => _controller.forward(),
          onExit: (e) => _controller.reverse(),
        ));
  }
}
