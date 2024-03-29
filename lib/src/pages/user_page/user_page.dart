import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mclauncher4/src/pages/user_page/side_panel_widget.dart';
import 'package:mclauncher4/src/pages/user_page/subPages/userAndMSPage.dart';
import 'package:mclauncher4/src/pages/user_page/text_field_with_enter.dart';
import 'package:mclauncher4/src/tasks/auth/supabase.dart';
import 'package:mclauncher4/src/tasks/discord/discordRP.dart';
import 'package:mclauncher4/src/widgets/side_panel/side_panel.dart';
import 'package:mclauncher4/src/widgets/bar_graph.dart';
import 'package:mclauncher4/src/widgets/components/blured_container.dart';
import 'package:mclauncher4/src/widgets/login_card_supabase.dart';
import 'package:mclauncher4/src/widgets/settings_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late FocusNode _focusNode;
  late final TextEditingController _textController;
  final supabase = Supabase.instance.client;
  bool isdisposed = false;

  @override
  void initState() {
    isdisposed = false;
    _textController = TextEditingController();

    _focusNode = FocusNode();
 

      supabase.auth.onAuthStateChange.listen((event) { 
            if(!isdisposed){
              setState(() {
                
              });
            }
      });

    super.initState();
  }

  @override
  void dispose() {
    isdisposed = true;
    

    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    bool hasPFP = false;
    bool hasUsername = false;
    if (supabaseHelpers().isLoggedIn()) {
      hasPFP = !(supabase.auth.currentUser?.userMetadata?["avatar_url"] == null);
    } else {
      hasPFP = false;
    }
    if (supabaseHelpers().isLoggedIn()) {
      hasUsername = !(supabase.auth.currentUser?.userMetadata?["name"] == null);
    } else {
      hasUsername = false;
    }
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 20),
                    child: SizedBox(
                      width: 500,
                      child: Row(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: const Color.fromARGB(19, 255, 255, 255)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: hasPFP
                                  ? Image.network(
                                      supabase.auth.currentUser?.userMetadata?["avatar_url"],
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(FontAwesomeIcons.user),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, top: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(
                                        text: (hasUsername)
                                            ? (supabase.auth.currentUser!.userMetadata?["name"])
                                            : "your_name_here"));
                                    final snackBar = SnackBar(
                                      content: Text(
                                        'Saved to Clipboard',
                                        style: Theme.of(context)
                                            .typography
                                            .black
                                            .bodyMedium!
                                            .merge(TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
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
                                  child: Text(
                                    hasUsername ? supabase.auth.currentUser?.userMetadata!["name"] : "no username!",
                                    style: Theme.of(context).typography.black.headlineLarge,
                                  ),
                                ),
                                Text(
                                  (supabaseHelpers().isLoggedIn())
                                      ? (supabase.auth.currentUser?.userMetadata?["email"] ?? "MAIL")
                                      : "your_name_here@gmail.com",
                                  style: Theme.of(context)
                                      .typography
                                      .black
                                      .labelMedium!
                                      .merge(TextStyle(color: Color.fromARGB(146, 255, 255, 255))),
                                ),
                                SizedBox(
                                  height: 52,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    width: 500,
                    child: Row(
                      children: [
                        Text(
                          "Account Settings:",
                          style: Theme.of(context).typography.black.labelSmall,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SettingsList(names: [
                    "Name, Microsoft",
                    "Password & Security",
                    "Privacy",
                    "Email",
                    "Subscriptions & Servers"
                  ], functions: [
                    () {
                      SidePanel().pop(UserAndMSPage(), 555);
                    },
                    () {
                      SidePanel().pop(
                          Container(
                            color: Colors.teal,
                          ),
                          550);
                    },
                    () {
                      SidePanel().pop(
                          Container(
                            color: Colors.teal,
                          ),
                          550);
                    },
                    () {
                      SidePanel().pop(
                          Container(
                            color: Colors.teal,
                          ),
                          550);
                    },
                    () {
                      SidePanel().pop(
                          Container(
                            color: Colors.teal,
                          ),
                          550);
                    },
                  ]),
                  SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: 500,
                    child: Row(
                      children: [
                        Text(
                          "Usage Stats:",
                          style: Theme.of(context).typography.black.labelSmall,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  BarGraph(
                    labels: [
                      "Mo",
                      "Di",
                      "Mi",
                      "Do",
                      "Fr",
                      "Sa",
                      "So",
                    ],
                    barHeight: 220,
                    values: [
                      15,
                      15,
                      15,
                      15,
                      95,
                      95,
                      60,
                    ],
                  ),
                ]),
              ),
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
                      child: LoginCardSupabase(onLogin: () async {
                     
                     
                      },),
                    ),
                  ))
        ],
      ),
    );
  }
}
