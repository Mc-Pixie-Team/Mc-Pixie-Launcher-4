// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/app.dart';
import 'package:mclauncher4/src/pages/settings_page/dev_settings_page.dart';
import 'package:mclauncher4/src/tasks/models/settings_keys.dart';
import 'package:mclauncher4/src/theme/custom_page_transition.dart';
import 'package:mclauncher4/src/widgets/settings_page/ram_select_card.dart';
import 'package:mclauncher4/src/widgets/settings_page/settings_switch_trans.dart';
import 'package:mclauncher4/src/widgets/divider.dart' as divider;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var settingsBox = Hive.box('settings');

  Map keys = {
    "Start After installation": SettingsKeys.startAfterInstall,
    "Enable Developer Mode": SettingsKeys.enableDeveloperMode,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
        clipBehavior: Clip.antiAlias,
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Theme.of(context).colorScheme.surfaceContainer,
        ),
        child: Center(
            child: SizedBox(
                width: 480,
                child: ValueListenableBuilder(
                    valueListenable: settingsBox.listenable(),
                    builder: (context, box, widget) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 40,
                            ),
                            Text(
                              "Settings",
                              style: Theme.of(context)
                                  .typography
                                  .black
                                  .displaySmall,
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
                                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(18)),
                              child: Column(
                                  children: List.generate(
                                      keys.keys.length,
                                      (index) => Column(
                                            children: [
                                              SizedBox(height: 13),
                                              SettingsSwitchTrans(
                                                text: keys.keys.toList()[index],
                                                value: settingsBox.get(keys
                                                    .values
                                                    .toList()[index]),
                                                onpressed: (value) {
                                                  settingsBox.put(
                                                      keys.values
                                                          .toList()[index],
                                                      value);
                                                },
                                              ),
                                              SizedBox(height: 13),
                                              divider.CustomDivider(
                                                size: 15,
                                                color: Color(0x23A6A6A6),
                                              ),
                                            ],
                                          ))),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            settingsBox.get(SettingsKeys.enableDeveloperMode) ?
                            MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTapUp: (details) => Navigator.push(context, SlowCupertinoPageRoute(builder: (context) => DevSettingsPage() )),
                                    child: Container(
                                        width: double.infinity,
                                        height: 60,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface),
                                        child: Align(
                                          alignment: Alignment(-0.80, 0),
                                          child: Text(
                                            "Developer Settings",
                                            style: Theme.of(context)
                                                .typography
                                                .black
                                                .labelLarge!
                                                .copyWith(
                                          
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                          ),
                                        )))) : SizedBox.shrink()
                          ],
                        )))));
  }
}
