import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:mclauncher4/src/pages/user_page/sidePanelWidget.dart';
import 'package:mclauncher4/src/pages/user_page/textFieldWithEnter.dart';
import 'package:mclauncher4/src/theme/scrollphysics.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.error,
      ),
      child: Align(
        child: SizedBox(
          width: 550,
          child: SidePanelWidget(
            title: "Name, Microsoft",
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(children: [
                SizedBox(
                  height: 20,
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 70.0, right: 70.0),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.surface),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text("Username", style: Theme.of(context).typography.black.bodyMedium!.merge(TextStyle(color: Colors.white))),
                          TextFieldWithEnter(
                            presetValue: "ancientxfire",
                            maxLenght: 20,
                            minLenght: 5,
                            onError: () {
                              final snackBar = SnackBar(
                                content: Text(
                                  "Error!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ",
                                  style:
                                      Theme.of(context).typography.black.bodyMedium!.merge(TextStyle(color: Theme.of(context).colorScheme.onError)),
                                ),
                                backgroundColor: Theme.of(context).colorScheme.error,
                                action: SnackBarAction(
                                  label: 'OK',
                                  onPressed: () {
                                    // Some code to undo the change.
                                  },
                                ),
                              );

                              // Find the ScaffoldMessenger in the widget tree
                              // and use it to show a SnackBar.
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            },
                            onSubmit: () {
                              final snackBar = SnackBar(
                                content: Text(
                                  "Updated Username ",
                                  style:
                                      Theme.of(context).typography.black.bodyMedium!.merge(TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                                ),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                action: SnackBarAction(
                                  label: 'OK',
                                  onPressed: () {
                                    // Some code to undo the change.
                                  },
                                ),
                              );

                              // Find the ScaffoldMessenger in the widget tree
                              // and use it to show a SnackBar.
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            },
                          )
                        ],
                      ),
                    ))
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
