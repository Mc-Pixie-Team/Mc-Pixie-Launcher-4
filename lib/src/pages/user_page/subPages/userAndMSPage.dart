import 'package:mclauncher4/src/objects/accounts/minecraft.dart';
import 'package:mclauncher4/src/pages/user_page/side_panel_widget.dart';
import 'package:mclauncher4/src/pages/user_page/text_field_with_enter.dart';
import 'package:mclauncher4/src/tasks/auth/microsoft.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:mclauncher4/src/widgets/side_panel/side_panel.dart';

class UserAndMSPage extends StatefulWidget {
  const UserAndMSPage({Key? key}) : super(key: key);

  @override
  _UserAndMSPageState createState() => _UserAndMSPageState();
}

class _UserAndMSPageState extends State<UserAndMSPage> {
  @override
  void initState() {
    super.initState();
  }

  onReturn() {
    print('return');
    SidePanel().pop(
        Container(
            height: double.infinity,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/backgound_blue.jpg',
              fit: BoxFit.cover,
            ),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: Color.fromARGB(0, 27, 124, 204))),
        280.0);
  }

  @override
  Widget build(BuildContext context) {
    return SidePanelWidget(
      title: "Name, Microsoft",
      onpressed: onReturn,
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(children: [
          SizedBox(
            height: 20,
          ),
          username(context),
          SizedBox(
            height: 20,
          ),
          TextLabel(),
          MinecraftAccounts(),
        ]),
      ),
    );
  }

  Padding username(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 70.0, right: 70.0),
        child: Container(
          height: 40,
          decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.surface),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 10,
              ),
              Text("Username",
                  style: Theme.of(context).typography.black.bodyMedium!.merge(TextStyle(color: Colors.white))),
              TextFieldWithEnter(
                presetValue: "has to be implemented",
                maxLenght: 20,
                minLenght: 5,
                onError: () {
                  final snackBar = SnackBar(
                    content: Text(
                      "Error!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ",
                      style: Theme.of(context)
                          .typography
                          .black
                          .bodyMedium!
                          .merge(TextStyle(color: Theme.of(context).colorScheme.onError)),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.error,
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
                onSubmit: () {
                  final snackBar = SnackBar(
                    content: Text(
                      "Updated Username ",
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
              ),
            ],
          ),
        ));
  }
}

class TextLabel extends StatelessWidget {
  const TextLabel({super.key, required});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 70.0, right: 70.0, bottom: 5),
      child: SizedBox(
        width: 500,
        child: Row(
          children: [
            Text(
              "Minecraft Accounts:",
              style: Theme.of(context).typography.black.bodySmall,
            )
          ],
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
    return Padding(
      padding: const EdgeInsets.only(left: 70.0, right: 70.0),
      child: AnimatedContainer(
        curve: Curves.decelerate,
        duration: Duration(milliseconds: 300),
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.only(top: 5, bottom: 5),
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
          child: FutureBuilder(
            future: MinecraftAccountUtils().getAccounts(),
            builder: (context, snapshot) {
              print(snapshot.error);
              if (snapshot.hasData) {
                List<MinecraftAccount> accounts = snapshot.data ?? [];
                return ListView.separated(
                  scrollDirection: Axis.vertical,
                  separatorBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Divider(
                      color: Color.fromARGB(44, 255, 255, 255),
                    ),
                  ),
                  itemCount: accounts.length + 1,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () async {
                        if (index >= accounts.length) {
                          print("add Account!");
                          Map dataNewAcc = await Microsoft().authenticate();
                          if (dataNewAcc["access_token"] != "") {
                            setState(() {
                              MinecraftAccountUtils().addAccount(MinecraftAccount(
                                  name: dataNewAcc["xbox_username"] ?? "",
                                  refreshToken: dataNewAcc["refreshToken"] ?? "",
                                  username: dataNewAcc["username"] ?? "",
                                  uuid: dataNewAcc["uuid"] ?? ""));
                            });
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
                              ),
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: LinearProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
