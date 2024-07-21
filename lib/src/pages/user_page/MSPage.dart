import 'package:mclauncher4/src/objects/accounts/minecraft.dart';
import 'package:mclauncher4/src/pages/user_page/side_panel_widget.dart';
import 'package:mclauncher4/src/pages/user_page/text_field_with_enter.dart';
import 'package:mclauncher4/src/tasks/auth/microsoft.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:mclauncher4/src/widgets/side_panel/side_panel.dart';

import 'package:uuid/v4.dart';
import 'package:uuid/v5.dart';

class MSPage extends StatefulWidget {
  const MSPage({Key? key}) : super(key: key);

  @override
  _MSPageState createState() => _MSPageState();
}

class _MSPageState extends State<MSPage> {
  @override
  void initState() {
    super.initState();
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
          width: 500,
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 40,
              ),
              Text(
                "Profiles",
                style: Theme.of(context).typography.black.displaySmall,
              ),
              SizedBox(
                height: 30,
              ),
              MinecraftAccounts(),
            ]),
          ),
        ),
      ),
    );
  }
}

class MinecraftAccounts extends StatefulWidget {
  MinecraftAccounts({
    Key? key,
  }) : super(key: key);

  @override
  _MinecraftAccountsState createState() => _MinecraftAccountsState();
}

class _MinecraftAccountsState extends State<MinecraftAccounts> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("builder");
    return AnimatedContainer(
      curve: Curves.decelerate,
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(18)),
      margin: EdgeInsets.only(top: 5, bottom: 5),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8),
        child: FutureBuilder(
          future: MinecraftAccountUtils().getAccounts(),
          builder: (context, snapshot) {
            print('error: ' + snapshot.error.toString());

            if (snapshot.hasData) {
              List<MinecraftAccount> accounts = snapshot.data ?? [];
              return ListView.separated(
                scrollDirection: Axis.vertical,
                separatorBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 3, top: 3),
                  child: Divider(
                    color: Color.fromARGB(44, 255, 255, 255),
                  ),
                ),
                itemCount: accounts.length + 1,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      if (index == accounts.length) {
                        print("add Account!");
                        Map dataNewAcc = await Microsoft().authenticate();
                        if (dataNewAcc["access_token"] != "") {
                          print("isnt null");

                          MinecraftAccountUtils()
                              .addAccount(MinecraftAccount(
                                  name: dataNewAcc["xbox_username"]!,
                                  refreshToken: dataNewAcc["refreshToken"]!,
                                  username: dataNewAcc["username"]!,
                                  uuid: dataNewAcc["uuid"]!))
                              .then((value) => {setState(() => {})});
                        }
                      } else {
                        print("Setting account with UUID as standard: " + accounts[index].uuid);
                        //MinecraftAccountUtils().deleteAccount(accounts[index]);
                        setState(() {
                          MinecraftAccountUtils().setStandard(accounts[index]);
                        });
                      }
                    },
                    child: Container(
                        margin: EdgeInsets.only(top: 5, bottom: 5),
                        height: 40,
                        child: (index < accounts.length)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  MinecraftHead(
                                    user: accounts[index],
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Expanded(
                                    child: Text(
                                      accounts[index].username,
                                      style: Theme.of(context).typography.black.bodyMedium,
                                    ),
                                  ),
                                  FutureBuilder(
                                      future: MinecraftAccountUtils().getStandard(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return (snapshot.data!.uuid == accounts[index].uuid)
                                              ? Padding(
                                                  padding: EdgeInsets.only(right: 15),
                                                  child: Icon(
                                                    Icons.star,
                                                    color: Theme.of(context).typography.black.bodyMedium?.color,
                                                  ),
                                                )
                                              : Padding(padding: EdgeInsets.only(right: 15), child: SizedBox());
                                        }
                                        return CircularProgressIndicator();
                                      })
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(color: ui.Color.fromARGB(72, 97, 97, 97)),
                                        child: SizedBox(
                                          child: Icon(
                                            Icons.person_add_alt_1_rounded,
                                            color: Theme.of(context).typography.black.bodyMedium?.color,
                                          ),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    "Add Minecraft Account",
                                    style: Theme.of(context).typography.black.bodyMedium,
                                  )
                                ],
                              )),
                  );
                },
              );
            } else {
              return Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(40)),
                  margin: EdgeInsets.only(left: 40, right: 40, top: 30, bottom: 30),
                  child: LinearProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

Future<void> _displayTextInputDialog(BuildContext context, TextEditingController _textFieldController1, TextEditingController _textFieldController2,
    String title, String hint_text1, String hint_text2) async {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: Text(title),
            content: Column(
              children: [
                TextField(
                  controller: _textFieldController1,
                  decoration: InputDecoration(hintText: hint_text1),
                ),
                TextField(
                  onSubmitted: (value) {
                    Navigator.pop(context, _textFieldController2.value);
                  },
                  controller: _textFieldController2,
                  decoration: InputDecoration(hintText: hint_text2),
                ),
              ],
            ));
      });
}
