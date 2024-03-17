import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/models/settings_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

class RamSelectCard extends StatefulWidget {
  const RamSelectCard({ Key? key }) : super(key: key);

  @override
  _RamSelectCardState createState() => _RamSelectCardState();
}

class _RamSelectCardState extends State<RamSelectCard> {

  double _currentSliderPrimaryValue = 2048;
  double _currentSliderSecondaryValue = 4096;
  late int min;
  late int max;
  late int divisons;
  late Timer saveTimer;

  int maxInGB = 16;
  int GIGABYTE = 1024 * 1024;

  int MEGABYTE = 1024;

  _RamSelectCardState() {
    min = 2048;
    max = maxInGB * MEGABYTE;
    divisons = 24;
  }

  @override
  void initState() {
  


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return                     Container(
                       
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(18)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                             SizedBox(
                              height: 20,
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 36, right: 34),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(
                                        4,
                                        (index) => Text(
                                              (((index +1) / 4) * maxInGB)
                                                      .round()
                                                      .toString() +
                                                  "G",
                                              style: Theme.of(context)
                                                  .typography
                                                  .black
                                                  .labelLarge!.copyWith(color: Color.fromARGB(174, 255, 255, 255)),
                                            )))),
                          
                            Padding(padding: EdgeInsets.only(top: 13, left: 40),child:
                            Text(
                              "min ${_currentSliderPrimaryValue.ceil()}",
                              style:
                                  Theme.of(context).typography.black.bodySmall,
                            )),
                          Padding(padding: EdgeInsets.only(top: 3, left: 30,right: 30,bottom: 10),child:  SliderTheme(
                                data: SliderThemeData(
                                  tickMarkShape: SliderTickMarkShape.noTickMark,
                                    overlayShape: SliderComponentShape.noThumb),
                                child: Slider(
                                  thumbColor:
                                      Theme.of(context).colorScheme.secondary,
                                  overlayColor: MaterialStatePropertyAll(
                                      Colors.transparent),
                                  divisions: divisons,
                                  min: min.toDouble(),
                                  max: max.toDouble(),
                                  value: _currentSliderPrimaryValue,
                                  secondaryTrackValue:
                                      _currentSliderSecondaryValue,
                                  label: _currentSliderPrimaryValue
                                          .round()
                                          .toString() +
                                      " MB",
                                  onChangeEnd: (value) async{
                                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await  prefs.setInt(SettingsKeys.minRamUsage, value.ceil());
                                  },
                                  onChanged: (double value) {
                                    setState(() {
                                      _currentSliderPrimaryValue = math.min(
                                          _currentSliderSecondaryValue, value);
                                    });
                                  },
                                ))),
                                  Padding(padding: EdgeInsets.only(top: 0, left: 40),child:
                            Text(
                              "max ${_currentSliderSecondaryValue.ceil()}",
                              style:
                                  Theme.of(context).typography.black.bodySmall,
                            )),
                          Padding(padding: EdgeInsets.only(top: 3, left:30,right: 30,bottom: 30),child:   SliderTheme(
                                data: SliderThemeData(
                                  tickMarkShape: SliderTickMarkShape.noTickMark,
                                    overlayShape: SliderComponentShape.noThumb),
                                child: Slider(
                                  thumbColor:
                                      Theme.of(context).colorScheme.secondary,
                                  overlayColor: MaterialStatePropertyAll(
                                      Colors.transparent),
                                  min: min.toDouble(),
                                  max: max.toDouble(),
                                  divisions: divisons,
                                  value: _currentSliderSecondaryValue,
                                  label: _currentSliderSecondaryValue
                                          .round()
                                          .toString() +
                                      " MB",
                                       onChangeEnd: (value) async{
                                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await  prefs.setInt(SettingsKeys.maxRamUsage, value.ceil());
                                   if (await prefs.getInt(SettingsKeys.minRamUsage)! >
                                          value) {
                                            await prefs.setInt(SettingsKeys.minRamUsage, value.ceil());
                                          }
                                  },
                                  onChanged: (double value) {
                                    setState(() {
                                      _currentSliderSecondaryValue = value;

                                      if (_currentSliderSecondaryValue <
                                          _currentSliderPrimaryValue) {
                                        _currentSliderPrimaryValue = value;
                                      }
                                    });
                                  },
                                )))
                          ],
                        ));
  }
}