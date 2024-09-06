import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomizedDropdownMenu extends StatefulWidget {
  List<String> items;
  bool enabled;
  TextEditingController? controller;
  void Function(String?)? onSelected;
  String? initialSelection;
  CustomizedDropdownMenu({Key? key, required this.items, this.controller, this.onSelected,this.initialSelection, this.enabled = true}) : super(key: key);

  @override
  _CustomizedDropdownMenuState createState() => _CustomizedDropdownMenuState();
}

class _CustomizedDropdownMenuState extends State<CustomizedDropdownMenu> {
  ButtonStyle getbuttonStyle(BuildContext context) => ButtonStyle(
   
      fixedSize: WidgetStatePropertyAll(Size(double.infinity, 48)),
      overlayColor: WidgetStatePropertyAll(Colors.transparent),
      padding: WidgetStatePropertyAll(EdgeInsets.only(left: 13)),
      textStyle: WidgetStatePropertyAll(TextStyle(
          fontSize: 16,
          color: Theme.of(context)
              .typography
              .black
              .labelMedium!
              .color!
              .withOpacity(0.86))));

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        child: DropdownMenuTheme(
            data: DropdownMenuThemeData(
                inputDecorationTheme: InputDecorationTheme(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                      left: 13,
                    )),
                textStyle: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context)
                        .typography
                        .black
                        .labelMedium!
                        .color!
                        .withOpacity(0.86)),
                menuStyle: MenuStyle(
                  
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
                  maximumSize:
                      WidgetStatePropertyAll(Size(double.infinity, 200)),
                    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
                  elevation: WidgetStatePropertyAll<double>(0),
                )),
            child: DropdownMenu(
              initialSelection: widget.initialSelection,
                controller: widget.controller,
                enabled: widget.enabled,
                onSelected: widget.onSelected,
                expandedInsets: EdgeInsets.all(0),
                dropdownMenuEntries: List.generate(
                    widget.items.length,
                    (index) => DropdownMenuEntry(
                        value: widget.items.toList()[index],
                        label: widget.items.toList()[index],
                        style: getbuttonStyle(context))))));
  }
}
