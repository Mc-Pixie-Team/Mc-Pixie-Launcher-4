import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mclauncher4/src/app.dart';
import 'package:mclauncher4/src/widgets/autoGradient.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mclauncher4/src/widgets/circularButton.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginCardSupabase extends StatefulWidget {
  const LoginCardSupabase({Key? key}) : super(key: key);

  @override
  _LoginCardSupabaseState createState() => _LoginCardSupabaseState();
}

class _LoginCardSupabaseState extends State<LoginCardSupabase> {
  late TextEditingController _textControllerEmail;
  late TextEditingController _textControllerPassword;
  late FocusNode _focusNodeEmail;
  late FocusNode _focusNodePassword;
  @override
  void initState() {
    super.initState();
    _textControllerEmail = TextEditingController();
    _textControllerPassword = TextEditingController();
    _focusNodeEmail = FocusNode();
    _focusNodePassword = FocusNode();
  }

  bool isObsured = true;
  @override
  final supabase = Supabase.instance.client;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      width: 350,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.only(left: 40.0, top: 30, right: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientTextWidget(
              text: "Pixie ||Login||.",
              gradient: LinearGradient(
                  //stops: [0, 1],
                  begin: Alignment.topLeft,
                  end: Alignment(1, 1),
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                  ]),
              textStyle: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                height: 32 / 24,
              ),
            ),
            SizedBox(
              height: 35,
            ),
            Text(
              "E-Mail",
              style: Theme.of(context).typography.black.labelLarge,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: InkWell(
                onTap: () {
                  _focusNodeEmail.requestFocus();
                },
                child: Container(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: EditableText(
                        selectionColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        cursorHeight: 24,
                        cursorOffset: Offset(0, 2),
                        controller: _textControllerEmail,
                        backgroundCursorColor: Color.fromARGB(0, 168, 14, 14),
                        focusNode: _focusNodeEmail,
                        cursorColor: Theme.of(context).colorScheme.primary,
                        style: TextStyle(fontSize: 20, color: Theme.of(context).typography.black.labelMedium!.color!.withOpacity(0.86)),
                      ),
                    ),
                  ),
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),
            SizedBox(
              height: 35,
            ),
            Text(
              "Password",
              style: Theme.of(context).typography.black.labelLarge,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: InkWell(
                onTap: () {
                  _focusNodePassword.requestFocus();
                },
                child: Container(
                  child: Center(
                    child: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Row(children: [
                          Expanded(
                            child: EditableText(
                              selectionColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              cursorHeight: 24,
                              cursorOffset: Offset(0, 2),
                              controller: _textControllerPassword,
                              backgroundCursorColor: Color.fromARGB(0, 168, 14, 14),
                              focusNode: _focusNodePassword,
                              cursorColor: Theme.of(context).colorScheme.primary,
                              obscureText: isObsured,
                              style: TextStyle(fontSize: 20, color: Theme.of(context).typography.black.labelMedium!.color!.withOpacity(0.86)),
                            ),
                          ),
                          InkWell(
                            mouseCursor: MouseCursor.defer,
                            child: Icon(
                              isObsured ? Icons.visibility_off : Icons.visibility,
                              size: 20,
                            ),
                            onTap: () {
                              setState(() {
                                isObsured = !isObsured;
                              });
                            },
                          )
                        ])),
                  ),
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            InkWell(
              child: Text(
                "You dont have a account? Click here!",
                style: Theme.of(context).typography.black.bodySmall!.apply(decoration: TextDecoration.underline),
              ),
              onTap: () async {
                var result = await Process.run("rundll32", ['url.dll,FileProtocolHandler', 'https://mc-pixie.com/newlogin']);
              },
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircularButton(
                  height: 41,
                  width: 41,
                  child: Icon(
                    FontAwesomeIcons.google,
                    size: 16,
                  ),
                  onClick: () async {
                    supabase.auth.signInWithOAuth(Provider.google,
                        redirectTo: "http://localhost:2695/redirect", authScreenLaunchMode: LaunchMode.inAppWebView);
                    bool sucess = await oauthReturnServer(context, supabase);
                    if (sucess == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MainPage()),
                      );
                    }
                  },
                ),
                CircularButton(
                  height: 41,
                  width: 41,
                  child: Icon(
                    FontAwesomeIcons.microsoft,
                    size: 16,
                  ),
                  onClick: () async {
                    supabase.auth.signInWithOAuth(Provider.azure,
                        redirectTo: "http://localhost:2695/redirect", authScreenLaunchMode: LaunchMode.inAppWebView, scopes: "email");
                    bool sucess = await oauthReturnServer(context, supabase);
                    if (sucess == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MainPage()),
                      );
                    }
                  },
                ),
                CircularButton(
                  height: 41,
                  width: 41,
                  child: Icon(
                    FontAwesomeIcons.discord,
                    size: 16,
                  ),
                  onClick: () async {
                    supabase.auth.signInWithOAuth(Provider.discord,
                        redirectTo: "http://localhost:2695/redirect", authScreenLaunchMode: LaunchMode.inAppWebView);
                    bool sucess = await oauthReturnServer(context, supabase);
                    if (sucess == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MainPage()),
                      );
                    }
                  },
                ),
              ],
            ),
            Expanded(
              child: SizedBox(
                height: 1,
              ),
            ),
            Row(children: [
              InkWell(
                  child: Text(
                    "Skip",
                    style: Theme.of(context)
                        .typography
                        .black
                        .bodyLarge!
                        .merge(TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  }),
              Expanded(
                child: SizedBox(
                  height: 1,
                ),
              ),
              InkWell(
                child: Text(
                  "Login",
                  style: Theme.of(context)
                      .typography
                      .black
                      .bodyLarge!
                      .merge(TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
                ),
                onTap: () async {
                  bool hasError = false;
                  print(_textControllerEmail.text);

                  print(_textControllerPassword.text);

                  try {
                    await supabase.auth.signInWithPassword(password: _textControllerPassword.text, email: _textControllerEmail.text);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MainPage()),
                    );
                  } catch (e) {
                    print(e);
                    final snackBar = SnackBar(
                      content: Text(
                        (e as AuthException).message,
                        style: Theme.of(context).typography.black.bodyLarge!.merge(TextStyle(color: Theme.of(context).colorScheme.onError)),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      action: SnackBarAction(
                        label: 'OK',
                        textColor: Theme.of(context).colorScheme.onError,
                        onPressed: () {
                          // Some code to undo the change.
                        },
                      ),
                    );

                    // Find the ScaffoldMessenger in the widget tree
                    // and use it to show a SnackBar.
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
              )
            ]),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}

Future<String> getFileData(String path) async {
  return await rootBundle.loadString(path);
}

Future<bool> oauthReturnServer(context, supabase) async {
  bool hasError = false;
  var server = await HttpServer.bind(InternetAddress.anyIPv6, 2695, shared: true);

  server.idleTimeout = Duration(seconds: 20);
  await server.forEach((HttpRequest request) async {
    switch (request.uri.path) {
      case "/redirect":
        String text = await getFileData("assets/redirect.html");
        request.response.headers.add("mimeType", "text/html;charset=utf-8");
        request.response.headers.add("Content-Type", "text/html");
        request.response.write(text);
        break;
      case "/auth":
        request.response.write("logged in! You can now close this window!");
        supabase.auth.getSessionFromUrl(request.uri).catchError((e) {
          print(e);
          final snackBar = SnackBar(
            content: const Text('The login was unsuccesfull!'),
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
          hasError = true;
        });
        server.close();
        break;
      default:
    }

    request.response.close();
  });
  return !hasError;
}
