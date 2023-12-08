import 'package:flutter/material.dart';
import 'package:mclauncher4/src/widgets/Providers/dropdown.dart';
import 'package:mclauncher4/src/widgets/Providers/dropdown_menu.dart';

class Debugpage extends StatefulWidget {
  const Debugpage({Key? key}) : super(key: key);

  @override
  _DebugpageState createState() => _DebugpageState();
}

class _DebugpageState extends State<Debugpage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration:
          BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          DropDown(),
          SizedBox(
            height: 30,
          ),
          Dropdownmenu(),
          Dropdownmenu()
        ],
      ),
    );
  }
}
