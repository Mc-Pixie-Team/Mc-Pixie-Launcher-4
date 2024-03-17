// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/app.dart';
import 'package:mclauncher4/src/tasks/models/settings_keys.dart';
import 'package:mclauncher4/src/widgets/settings_page/ram_select_card.dart';
import 'package:mclauncher4/src/widgets/settings_page/settings_switch_trans.dart';
import 'package:mclauncher4/src/widgets/divider.dart' as divider;
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _currentSliderPrimaryValue = 2048;
  double _currentSliderSecondaryValue = 4096;
  late int min;
  late int max;
  late int divisons;

  int maxInGB = 16;
  int GIGABYTE = 1024 * 1024;

  int MEGABYTE = 1024;

  _SettingsPageState() {
    min = 2048;
    max = maxInGB * MEGABYTE;
    divisons = 24;
  }

  bool islight = true;
  @override
  Widget build(BuildContext context) {
    return Container(
        clipBehavior: Clip.antiAlias,
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Theme.of(context).colorScheme.surfaceVariant,
        ),
        child: Center(
            child: SizedBox(
                width: 480,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      "Settings",
                      style: Theme.of(context).typography.black.displaySmall,
                    ),
                    SizedBox(
                      height: 90,
                    ),
                    RamSelectCard(),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      width: double.infinity,
                      height: 400,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          SizedBox(height: 13),
                          SettingsSwitchTrans(text: "Start project on install", settingsKey: SettingsKeys.maxRamUsage, value: true, onpressed:(value) {
                           
                          },),
                          SizedBox(height: 13),
                          divider.CustomDivider(size: 15, color: Color(0x23A6A6A6),),
                            SizedBox(height: 13),
                          SettingsSwitchTrans(text: "Dark/light mode", settingsKey: SettingsKeys.maxRamUsage, value: islight, onpressed: (value) {
                            if(value) {
                              McLauncher.of(context).changeTheme(ThemeMode.dark);
                               setState(() {
                                islight = value;
                              });
                            }else {
                              McLauncher.of(context).changeTheme(ThemeMode.light);
                              setState(() {
                                islight = value;
                              });
                            }
                          },),
                          SizedBox(height: 13),
                          divider.CustomDivider(size: 15, color: Color(0x23A6A6A6),),
                            SizedBox(height: 13),
                         
                          
                        ],
                      ),
                    )
                  ],
                ))));
  }
}
