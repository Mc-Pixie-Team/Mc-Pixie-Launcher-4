import 'dart:io';

import 'package:archive/archive.dart';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/models/download_states.dart';
import 'package:mclauncher4/src/tasks/utils/downloader.dart';
import 'package:mclauncher4/src/tasks/utils/downloads_utils.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:mclauncher4/src/widgets/buttons/download_button.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class JavaInstallCard extends StatefulWidget {
  const JavaInstallCard({Key? key}) : super(key: key);

  @override
  _JavaInstallCardState createState() => _JavaInstallCardState();
}

class _JavaInstallCardState extends State<JavaInstallCard> {
  double downloadprecentage = 0.0;

  int installStep = 1;
  int stepAmount = 2;

  install() async {
    // List<int> _bytes = await _downloader "https://cdn.azul.com/zulu/bin/zulu17.44.53-ca-jdk17.0.8.1-win_x64.zip"
    //     .downloadSingeFileAsBytes("https://cdn.azul.com/zulu/bin/zulu8.72.0.17-ca-jdk8.0.382-win_x64.zip");

    List<String> links = [
       "https://cdn.azul.com/zulu/bin/zulu8.72.0.17-ca-jdk8.0.382-win_x64.zip",
      "https://cdn.azul.com/zulu/bin/zulu17.44.53-ca-jdk17.0.8.1-win_x64.zip"
    ];

    print("start download");
    for (String link in links) {
      String filename = Uuid().v1() + ".zip";
      final downloader =
          Downloader(link, path.join(await  getinstances(), filename));

      await downloader.startDownload(
          onProgress: (percentage) => setState(() {
                downloadprecentage = percentage / 100;
              }));
      await downloader.unzip(deleteOld: true);
    installStep++;
    }

    print("end download");

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Color.fromARGB(90, 0, 0, 0), blurRadius: 16)
          ],
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18)),
      height: 200,
      width: 400,
      child: Column(children: [
        SizedBox(
          height: 30,
        ),
        DefaultTextStyle(
          style: TextStyle(),
          child: Text(
            'Java not installed',
            style: Theme.of(context).typography.black.headlineMedium,
          ),
        ),
        SizedBox(
          height: 15,
        ),
        DefaultTextStyle(
            style: TextStyle(),
            child: Text(
              'Click on installed to Atomatically install java',
              style: Theme.of(context).typography.black.bodyLarge,
            )),
        Expanded(child: Container()),
        SizedBox(
          height: 30,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            downloadprecentage > 0.0
                ? DefaultTextStyle(
                    style: TextStyle(),
                    child: Text(
                      '$stepAmount/$installStep',
                      style: Theme.of(context).typography.black.bodyLarge,
                    ))
                : TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).typography.black.labelLarge,
                    )),
            SizedBox(
              height: 15,
            ),
            downloadprecentage > 0.0
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                        width: 280,
                        child: LinearProgressIndicator(
                          backgroundColor:
                              Theme.of(context).colorScheme.background,
                          value: downloadprecentage,
                        )))
                : TextButton(
                    onPressed: install,
                    child: Text(
                      'Install',
                      style: Theme.of(context).typography.black.labelLarge,
                    )),
          ]),
        ),
        SizedBox(
          height: 15,
        ),
      ]),
    );
  }
}
