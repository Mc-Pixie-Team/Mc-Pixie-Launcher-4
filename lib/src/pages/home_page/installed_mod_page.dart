import 'dart:async';

import 'package:flutter/material.dart';

class InstalledModPage extends StatefulWidget {
  Stream<String> stream;
  InstalledModPage({Key? key, required this.stream}) : super(key: key);

  @override
  _InstalledModPageState createState() => _InstalledModPageState();
}

class _InstalledModPageState extends State<InstalledModPage> {

  List<String> commandline = [];
 late TextSelectionControls selectionControls;
 late FocusNode focusNote;
 late StreamSubscription<String> subscription;
  @override
  void initState() {
  

    selectionControls = DesktopTextSelectionControls();
    focusNote = FocusNode();

 widget.stream.listen((data) {
    setState(() {
      
    });
   
  });
  

    super.initState();
  }

  @override
  void dispose() {
 
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Theme.of(context).colorScheme.surfaceVariant,
        ),
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Container(
            color: Colors.black,
            child: Container(),
              
            ),
          ),
        ),
      
    );
  }
}
