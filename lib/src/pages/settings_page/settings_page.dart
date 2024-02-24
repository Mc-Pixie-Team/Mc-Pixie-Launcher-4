// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:system_info/system_info.dart';



class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _currentSliderPrimaryValue = 8192;
  double _currentSliderSecondaryValue = 16384;
  late int min;
  late int max;
  late double ramUsageMax;
  late double ramUsageMin;
  late int divisons;

  int maxInGB = 16;
  int GIGABYTE = 1024 * 1024;

  int MEGABYTE = 1024;

  _SettingsPageState() {
    min = 0;
    max = maxInGB * MEGABYTE;
    divisons = max ~/ (MEGABYTE / 2);
    ramUsageMax = _currentSliderPrimaryValue * MEGABYTE;
    ramUsageMin = _currentSliderSecondaryValue * MEGABYTE;

    print(SysInfo.getTotalPhysicalMemory() / (65536 * 65536) / 4);
  }

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
                    Text("3"),
                    SizedBox(
                      height: 90,
                    ),
                    Container(
                        height: 200,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(18)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Slider(
                             
                            divisions: divisons,
                              min: min.toDouble(),
                              max: max.toDouble(),
                          
                              value: _currentSliderPrimaryValue,
                              secondaryTrackValue: _currentSliderSecondaryValue,
                              label:
                                  _currentSliderPrimaryValue.round().toString(),
                              onChanged: (double value) {
                                
                                setState(() {
                                  _currentSliderPrimaryValue = math.min(_currentSliderSecondaryValue,  value);                    
                                  
                                });
                                ramUsageMin = _currentSliderPrimaryValue * MEGABYTE;

                                print('MIN Usage: ${_currentSliderPrimaryValue}  | MAX Usage: ${_currentSliderSecondaryValue}');
                              },
                            ),
                            Slider(
                              min: min.toDouble(),
                              max: max.toDouble(),
                              divisions: divisons,
                              value: _currentSliderSecondaryValue,
                              label: _currentSliderSecondaryValue
                                  .round()
                                  .toString(),
                              onChanged: (double value) {
                                setState(() {
                                  _currentSliderSecondaryValue = value;
                                  ramUsageMax = _currentSliderSecondaryValue * MEGABYTE;

                                  if(_currentSliderSecondaryValue < _currentSliderPrimaryValue) {
                                    _currentSliderPrimaryValue = value;
                                    ramUsageMin = _currentSliderPrimaryValue * MEGABYTE;
                                  }                 
                                });
                                 print('MIN Usage: ${_currentSliderPrimaryValue}  | MAX Usage: ${_currentSliderSecondaryValue}');
                              },
                            ),
                          ],
                        ))
                  ],
                ))));
  }
}
