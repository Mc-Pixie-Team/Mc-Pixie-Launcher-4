// ignore_for_file: no_leading_underscores_for_local_identifiers, no_logic_in_create_state, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/models/download_states.dart';
import 'package:mclauncher4/src/widgets/buttons/download_button.dart';
import 'package:mclauncher4/src/widgets/buttons/svg_button.dart';
import '../divider.dart' as divider;

class TaskWidget extends StatefulWidget {
  final Map items;

  TaskWidget({super.key, required this.items});

  @override
  _TaskpageState createState() => _TaskpageState();
}

class _TaskpageState extends State<TaskWidget> {
  List _key = [];

  @override
  Widget build(BuildContext context) {
    _key = widget.items.keys.toList();
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration:
          BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(18)),
      child: ListView.builder(
          itemCount: _key.length,
          itemBuilder: (context, index) {
            return widget.items['${_key[index]}'];
          }),
    );
  }
}

class TaskwidgetItem extends StatefulWidget {
  MainState state = MainState.notinstalled;

  double progress = 0.0;
  double mainprogress = 0.0;
  String name = "";

  VoidCallback cancel;

  TaskwidgetItem({
    Key? key,
    required this.name,
    required this.cancel,
    required this.state,
    required this.progress,
  }) : super(key: key);

  @override
  _TaskwidgetItemState createState() => _TaskwidgetItemState();
}

class _TaskwidgetItemState extends State<TaskwidgetItem> {
  String get getName {
    if (widget.name.length > 8) {
      widget.name = widget.name.replaceRange(8, widget.name.length, "");
      widget.name = '${widget.name}...';
      return widget.name;
    }
    return widget.name;
  }

  String get titleText {
    if (widget.state == MainState.running) return "Running: $getName";
    if (widget.state == MainState.downloadingML) return "Installing Modloader";
    return "Installing: $getName";
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(
        padding: EdgeInsets.all(10.0),
        child: Container(
          height: 85,
          width: double.infinity,
          decoration: ShapeDecoration(
            color: Color(0xFF262626),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: EdgeInsets.only(left: 12, right: 18, top: 4),
                      child: SizedBox(
                        width: 8,
                        height: 5,
                        child: SvgButton.asset('assets/svg/dropdown-icon.svg',
                            color: Theme.of(context).typography.black.displayLarge!.color, onpressed: () {}),
                      )),
                  Text(
                    'Progress',
                    style: Theme.of(context).typography.black.bodySmall,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 26, top: 4),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: titleText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      ),
                      widget.state == MainState.running ? TextSpan() :
                      TextSpan(
                        text: ' ${widget.progress.ceil()}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(left: 27, right: 24, top: 5),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Expanded(
                        child: LinearProgressIndicator(
                      value: widget.progress / 100,
                      borderRadius: BorderRadius.circular(18),
                    )),
                    SizedBox(
                      width: 15,
                    ),
                    SizedBox(
                        height: 20,
                        width: 20,
                        child: DownloadButton(mainState: widget.state, onCancel: widget.cancel, onDownload: () {}, onOpen: () {}, mainprogress: widget.progress,))
                  ]))
            ],
          ),
        ),
      ),
      divider.Divider()
    ]);
  }
}
