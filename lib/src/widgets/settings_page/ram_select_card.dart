import 'dart:async';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/models/settings_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

class RamSelectCard extends StatefulWidget {
  const RamSelectCard({Key? key}) : super(key: key);

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

  int MEGABYTE = 1024;

  _RamSelectCardState() {
    min = 0;
    max = maxInGB * MEGABYTE;
    print("max: ${max}, min: ${min}");
    divisons = 64;
    print(divisons);
  }

  var settingsBox = Hive.box('settings');

  @override
  void initState() {
    _currentSliderPrimaryValue =
        (settingsBox.get(SettingsKeys.minRamUsage, defaultValue: 256.0) as int)
            .toDouble();
    _currentSliderSecondaryValue =
        (settingsBox.get(SettingsKeys.maxRamUsage, defaultValue: 2048.0) as int)
            .toDouble();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            Padding(padding: EdgeInsets.only(left: 33, right: 33),child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                  5,
                  (int index) =>  Text(index == 0
                      ? "0"
                      : ((index * 4)).toString(), style:Theme.of(context)
                                                  .typography
                                                  .black
                                                  .labelLarge!.copyWith(color: Color.fromARGB(174, 255, 255, 255)),)),
            )),
            Padding(
                padding: EdgeInsets.only(top: 13, left: 40),
                child: Text(
                  "min ${_currentSliderPrimaryValue.ceil()}",
                  style: Theme.of(context).typography.black.bodySmall,
                )),
            Padding(
                padding:
                    EdgeInsets.only(top: 3, left: 30, right: 30, bottom: 10),
                child: SliderTheme(
                    data: SliderThemeData(
                        tickMarkShape: SliderTickMarkShape.noTickMark,
                        overlayShape: SliderComponentShape.noThumb),
                    child: Slider(
                      thumbColor: Theme.of(context).colorScheme.secondary,
                      overlayColor:
                          MaterialStatePropertyAll(Colors.transparent),
                      divisions: divisons,
                      min: min.toDouble(),
                      max: max.toDouble(),
                      value: _currentSliderPrimaryValue,
                      secondaryTrackValue: _currentSliderSecondaryValue,
                      label:
                          _currentSliderPrimaryValue.round().toString() + " MB",
                      onChangeEnd: (value) async {
                        await settingsBox.put(
                            SettingsKeys.minRamUsage, value.ceil());
                      },
                      onChanged: (double value) {
                        setState(() {
                          _currentSliderPrimaryValue =
                              math.min(_currentSliderSecondaryValue, value);
                        });
                      },
                    ))),
            Padding(
                padding: EdgeInsets.only(top: 0, left: 40),
                child: Text(
                  "max ${_currentSliderSecondaryValue.ceil()}",
                  style: Theme.of(context).typography.black.bodySmall,
                )),
            Padding(
                padding:
                    EdgeInsets.only(top: 3, left: 30, right: 30, bottom: 30),
                child: SliderTheme(
                    data: SliderThemeData(
                        tickMarkShape: SliderTickMarkShape.noTickMark,
                        overlayShape: SliderComponentShape.noThumb),
                    child: Slider(
                      thumbColor: Theme.of(context).colorScheme.secondary,
                      overlayColor:
                          MaterialStatePropertyAll(Colors.transparent),
                      min: min.toDouble(),
                      max: max.toDouble(),
                      divisions: divisons,
                      value: _currentSliderSecondaryValue,
                      label: _currentSliderSecondaryValue.round().toString() +
                          " MB",
                      onChangeEnd: (value) {
                        settingsBox.put(SettingsKeys.maxRamUsage, value.ceil());
                        if (settingsBox.get(SettingsKeys.minRamUsage)! >
                            value) {
                          settingsBox.put(
                              SettingsKeys.minRamUsage, value.ceil());
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
