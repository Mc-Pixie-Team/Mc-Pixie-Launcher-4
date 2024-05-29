// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

 var settingsBox = Hive.box('settings');





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
                child:  ValueListenableBuilder(
      valueListenable: settingsBox.listenable(),
      builder: (context, box, widget) => Column(
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
                          SettingsSwitchTrans(text: "Start project on install",  value: settingsBox.get(SettingsKeys.startAfterInstall), onpressed:(value) {
                           settingsBox.put(SettingsKeys.startAfterInstall, value);
                          },),
                          SizedBox(height: 13),
                          divider.CustomDivider(size: 15, color: Color(0x23A6A6A6),),
                            SizedBox(height: 13),
                       
                     
                         
                          
                        ],
                      ),
                    )
                  ],
                )))));
  }
}
