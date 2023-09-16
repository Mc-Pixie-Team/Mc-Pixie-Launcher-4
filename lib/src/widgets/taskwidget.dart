// ignore_for_file: no_leading_underscores_for_local_identifiers, no_logic_in_create_state, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/downloadState.dart';
import 'package:mclauncher4/src/widgets/SvgButton.dart';
import './divider.dart' as divider;

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
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18)),
      child: ListView.builder(
          itemCount: _key.length,
          itemBuilder: (context, index) {
            return widget.items['${_key[index]}'];
          }),
    );
  }
}

class TaskwidgetItem extends StatefulWidget {
  MainState mainState = MainState.notinstalled;
  double progress = 0.0;
  double mainprogress = 0.0;
  var installState;

  VoidCallback cancel;

  TaskwidgetItem(
      {Key? key,
      required this.cancel,
      required this.mainState,
      required this.progress,
      required this.mainprogress,
      required this.installState})
      : super(key: key);

  @override
  _TaskwidgetItemState createState() => _TaskwidgetItemState();
}

class _TaskwidgetItemState extends State<TaskwidgetItem> {
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                      padding: EdgeInsets.only(left: 10, right: 8, top: 4),
                      child: SizedBox(
                        width: 8,
                        height: 5,
                        child: SvgButton.asset('assets/svg/dropdown-icon.svg',
                            color: Theme.of(context)
                                .typography
                                .black
                                .displayLarge!
                                .color,
                            onpressed: () {}),
                      )),
                  Text(
                    'Progress',
                    style: Theme.of(context).typography.black.bodySmall,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 26,top: 4),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'The Revenge',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      ),
                      TextSpan(
                        text: ': 69%',
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
              Padding(padding: EdgeInsets.only(left: 27, right: 24), child:
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              
               Expanded(child: LinearProgressIndicator(
                  value: widget.mainprogress / 100,
                  borderRadius: BorderRadius.circular(18),
                )),
                SizedBox(width: 15,),
                SizedBox(height: 20, width: 20, child:
                SvgButton.asset('assets/svg/cancel-icon.svg',color: Theme.of(context).colorScheme.secondary, onpressed: widget.cancel))
              ]))
            ],
          ),
        ),
      ),
      divider.Divider()
    ]);
  }
}
