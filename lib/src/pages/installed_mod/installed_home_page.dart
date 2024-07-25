import 'dart:convert';
import 'dart:io';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

class InstalledHomePage extends StatefulWidget {
  String processId;
  InstalledHomePage({Key? key, required this.processId}) : super(key: key);

  @override
  _InstalledHomePageState createState() => _InstalledHomePageState();
}

class _InstalledHomePageState extends State<InstalledHomePage> {
  @override
  void initState() {
    super.initState();
  }

  Future<String> getBody() async {
    List manifest = jsonDecode(await File(path.join(getInstancePath(), "manifest.json")).readAsString());
    var body = manifest.singleWhere((element) => element["processId"] == widget.processId)["body"];
    if (body == null) throw "NOT FOUND";
    return body;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getBody(),
      builder: (context, snapshot) => snapshot.hasData
          ? WebviewWidget(
              cachHTMLFile: File(path.join(getHTMLcachePath(), "index.html")),
              body: snapshot.data! == "" ? "<div> NOTING HERE </div>" : snapshot.data!,
            )
          : Container(),
    );
  }
}
