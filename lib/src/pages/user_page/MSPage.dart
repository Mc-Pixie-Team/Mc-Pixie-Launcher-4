import 'package:mclauncher4/src/objects/accounts/minecraft.dart';
import 'package:mclauncher4/src/tasks/auth/microsoft.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';


import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
                AppLocalizations.of(context)!.profilesHeadline,
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

Future<Map> getMCAccData() async {
  return {"accounts": await MinecraftAccountUtils().getAccounts(), "fav": await MinecraftAccountUtils().getStandard()};
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
          future: getMCAccData(),
          builder: (context, snapshot) {
            String? error = snapshot.error.toString();
            if (error != "null") {
              print('error: ' + error);
            }

            if (snapshot.hasData) {
              List<MinecraftAccount> accounts = snapshot.data?["accounts"] ?? [];
              String favUUID = "";
              if (snapshot.data?["fav"] != null) {
                favUUID = snapshot.data?["fav"].uuid;
              }
              
              return Column(children: [
                ListView.separated(
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
                            print("access_token isnt null");

                            MinecraftAccountUtils()
                                .addAccount(MinecraftAccount(
                                    name: dataNewAcc["xbox_username"]!,
                                    refreshToken: dataNewAcc["refreshToken"]!,
                                    username: dataNewAcc["username"]!,
                                    uuid: dataNewAcc["uuid"]!,
                                    userDetails: dataNewAcc["userDetails"]))
                                .then((value) => {setState(() => {})});
                          }
                        } else {
                          print("Setting account with UUID as standard: " + accounts[index].uuid);

                          setState(() {
                            MinecraftAccountUtils().setStandard(accounts[index]);
                          });
                        }
                      },
                      child: Container(
                          margin: EdgeInsets.only(top: 5, bottom: 5),
                          height: 45,
                          child: (index < accounts.length)
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Container(
                                        clipBehavior: Clip.antiAlias,
                                        decoration: (favUUID == accounts[index].uuid)
                                            ? BoxDecoration(
                                                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 3),
                                                borderRadius: BorderRadius.circular(8))
                                            : BoxDecoration(
                                                border: Border.all(color: Colors.transparent, width: 3), borderRadius: BorderRadius.circular(8)),
                                        child: Stack(children: [
                                          MinecraftHead(
                                            user: accounts[index],
                                            widht: 39,
                                            height: 100,
                                          ),
                                        /*   SizedBox(
                                            width: 39,
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: MinecraftCape(
                                                user: accounts[index],
                                                widht: 19,
                                                height: 20,
                                              ),
                                            ),
                                          ), */
                                        ])),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                      child: Text(
                                        accounts[index].username,
                                        style: Theme.of(context).typography.black.bodyMedium,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            MinecraftAccountUtils().deleteAccount(accounts[index]);
                                          });
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Theme.of(context).colorScheme.primary,
                                        )),
                                    SizedBox(
                                      width: 20,
                                    )
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
                                          height: 45,
                                          width: 45,
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
                                      AppLocalizations.of(context)!.addMinecraftAccount,
                                      style: Theme.of(context).typography.black.bodyMedium,
                                    )
                                  ],
                                )),
                    );
                  },
                )
              ]);
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
