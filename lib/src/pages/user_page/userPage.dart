import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mclauncher4/src/tasks/auth/supabase.dart';
import 'package:mclauncher4/src/widgets/barGraph.dart';
import 'package:mclauncher4/src/widgets/bluredContainer.dart';
import 'package:mclauncher4/src/widgets/loginCardSupabase.dart';
import 'package:mclauncher4/src/widgets/settingsList.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  final supabase = Supabase.instance.client;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: Stack(
        children: [
          /* Center(
            child: SettingsList(
              names: [
                "Name, Phone Number",
                "Password & Security",
                "Privacy™",
                "Email",
                "Subscriptions & Servers",
              ],
              functions: [
                () {
                  print("a");
                },
                () {
                  print("a");
                },
                () {
                  print("a");
                },
                () {
                  print("a");
                },
                () {
                  print("a");
                },
                () {
                  print("a");
                },
                () {
                  print("a");
                },
                () {
                  print("a");
                },
                () {
                  print("a");
                },
              ],
            ),
          ), */
          Center(
            child: BarGraph(
              values: [
                20,
                40,
                60,
                80,
                100,
                80,
                60,
              ],
            ),
          ),
          (supabaseHelpers().isLoggedIn())
              ? Align(
                  alignment: Alignment(0.96, -0.9651111111),
                  child: TextButton(
                    child: SizedBox(
                        width: 85,
                        height: 35,
                        child: Center(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [Text("LogOut"), Icon(Icons.logout)]))),
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                        backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.surface)),
                    onPressed: () {
                      setState(() {
                        supabaseHelpers().signoutUser();
                      });
                    },
                  ),
                )
              : BlurredContainer(
                  blurIntensity: 5, // Adjust blur intensity
                  overlayColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                  child: Center(
                    child: Center(
                      child: LoginCardSupabase(),
                    ),
                  ))
        ],
      ),
    );
  }
}
