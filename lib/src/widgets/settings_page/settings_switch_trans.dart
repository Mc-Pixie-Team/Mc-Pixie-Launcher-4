import 'package:flutter/material.dart';

class SettingsSwitchTrans extends StatefulWidget {
  String text;
  bool value;
  Function(bool value) onpressed;
  SettingsSwitchTrans({ Key? key, required this.text, required this.value, required this.onpressed }) : super(key: key);

  @override
  _SettingsSwitchTransState createState() => _SettingsSwitchTransState();
}

class _SettingsSwitchTransState extends State<SettingsSwitchTrans> {
  bool isEnabled = false;
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(left: 15, right: 40),child: SizedBox(height: 20, width: double.infinity,child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(widget.text, style: Theme.of(context).typography.black.labelLarge,), Expanded(child: SizedBox.expand()), SwitchTheme(data: SwitchThemeData(thumbColor: MaterialStatePropertyAll(Colors.white), overlayColor: MaterialStatePropertyAll(Colors.transparent) ), child:  Switch( value: widget.value, onChanged: (value) {       

          widget.onpressed.call(value);
        }))
    ],),));
  }
}