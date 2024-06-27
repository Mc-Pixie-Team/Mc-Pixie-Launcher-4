import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mclauncher4/src/tasks/models/download_states.dart';
import 'package:mclauncher4/src/widgets/buttons/play_button.dart';
import 'package:mclauncher4/src/widgets/buttons/svg_button.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mclauncher4/src/widgets/providers_widget/dropdown.dart';

class ModpackActionsMenu extends StatefulWidget {
  MainState state;
  double progress;
  VoidCallback? onPlay;
  VoidCallback? onDelete;
  VoidCallback? onFirstItem;
  VoidCallback? onSecondItem;
  VoidCallback? onFirstMenuItem;
  VoidCallback? onSecondMenuItem;
  VoidCallback? onThirdMenuItem;
  ModpackActionsMenu(
      {Key? key,
      required this.state,
      required this.progress,
      this.onPlay,
      this.onDelete,
      this.onFirstItem,
      this.onSecondItem,
      this.onFirstMenuItem,
      this.onSecondMenuItem,
      this.onThirdMenuItem})
      : super(key: key);

  @override
  _ModpackActionsMenuState createState() => _ModpackActionsMenuState();
}

class _ModpackActionsMenuState extends State<ModpackActionsMenu>
    with SingleTickerProviderStateMixin {
  final dropDownMenuItems = <String, String>{
    'Edit Modpack': "assets/svg/edit-icon.svg",
    'Open Folder': "assets/svg/folder-icon.svg",
    'Visit Site': "assets/svg/network-icon.svg",
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14)),
      padding: EdgeInsets.all(9),
      child: Row(
        children: [
        
          PlayButton(
            onPressed: widget.onPlay ?? () {},
            state: widget.state,
          ),
          SizedBox(
            width: 20,
          ),
          Tooltip(
              waitDuration: Duration(milliseconds: 300),
              exitDuration: Duration(milliseconds: 0),
              textStyle: Theme.of(context).typography.black.bodyMedium,
              message: 'Delete Modpack',
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromARGB(73, 0, 0, 0), blurRadius: 10)
                  ],
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).colorScheme.surface),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).colorScheme.surfaceVariant),
                  height: 34,
                  width: 34,
                  child: SvgButton.asset("assets/svg/trash-icon.svg",
                      padding: EdgeInsets.all(7.0),
                      color: Color(0xFFFF6363),
                      onpressed: widget.onDelete ?? () {}))),
          SizedBox(
            width: 20,
          ),
          Tooltip(
              waitDuration: Duration(milliseconds: 300),
              exitDuration: Duration(milliseconds: 0),
              textStyle: Theme.of(context).typography.black.bodyMedium,
              message: 'Change Modpack Version',
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromARGB(83, 0, 0, 0), blurRadius: 10)
                  ],
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).colorScheme.surface),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).colorScheme.surfaceVariant),
                  height: 34,
                  width: 34,
                  child: SvgButton.asset("assets/svg/switch-icon.svg",
                      padding: EdgeInsets.all(7.0), onpressed: widget.onFirstItem ?? () {}))),
          SizedBox(
            width: 20,
          ),
          Tooltip(
              waitDuration: Duration(milliseconds: 300),
              exitDuration: Duration(milliseconds: 0),
              textStyle: Theme.of(context).typography.black.bodyMedium,
              message: 'Upload Modpack',
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromARGB(83, 0, 0, 0), blurRadius: 10)
                  ],
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).colorScheme.surface),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).colorScheme.surfaceVariant),
                  height: 34,
                  width: 34,
                  child: SvgButton.asset("assets/svg/upload-icon.svg",
                      padding: EdgeInsets.all(7.0), onpressed: widget.onSecondItem ?? () {}))),
          SizedBox(
            width: 20,
          ),
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).colorScheme.surfaceVariant),
              height: 34,
              width: 34,
              child: DropdownButtonHideUnderline(
                  child: DropdownButton2(
                      onChanged: (t) => {
                            if (t == dropDownMenuItems.keys.toList()[0] && widget.onFirstMenuItem != null)
                              {
                                widget.onFirstMenuItem!()
                              }
                            else if (t == dropDownMenuItems.keys.toList()[1] && widget.onSecondMenuItem != null)
                              {
                                widget.onSecondMenuItem!()
                              }
                            else if (t == dropDownMenuItems.keys.toList()[2] && widget.onThirdMenuItem != null)
                              {
                                widget.onThirdMenuItem!()
                              }
                          },
                      menuItemStyleData: MenuItemStyleData(
                        padding: EdgeInsets.only(left: 12),
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        elevation: 0,
                        useSafeArea: false,
                        offset: Offset(-126, -16),
                        width: 160,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      customButton: Icon(
                        Icons.menu_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      items: dropDownMenuItems.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Row(
                            children: [
                              Container(
                                  height: 20,
                                  width: 20,
                                  child: SvgPicture.asset(entry.value,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Text(entry.key,
                                    style: Theme.of(context)
                                        .typography
                                        .black
                                        .labelMedium!
                                        .copyWith(fontWeight: FontWeight.w400)),
                              ),
                            ],
                          ),
                        );
                      }).toList())))
        ],
      ),
    );
  }
}
