import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SvgButton extends StatefulWidget {
  SvgButton({Key? key, required this.svg, required this.onpressed})
      : super(key: key);

  SvgPicture svg;
  VoidCallback onpressed;
  @override
  _SvgButtonState createState() => _SvgButtonState();
}

class _SvgButtonState extends State<SvgButton> {
  @override
  Widget build(BuildContext context) {
    
    return InkWell(
      
      child: widget.svg,
      onTap: widget.onpressed,
    );
  }
}
