import 'package:flutter/material.dart';
import 'package:mclauncher4/src/widgets/rounded_text_button.dart';

class Screen extends StatefulWidget {
  const Screen({ Key? key }) : super(key: key);

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Align(alignment: Alignment.center, child: GestureDetector(child: DefaultTextStyle(
  style: TextStyle(),
  child: RoundedTextButton(text: "return", onTap: () => Navigator.pop(context),),)),),
    );
  }
}