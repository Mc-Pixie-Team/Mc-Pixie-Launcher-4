import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/downloadState.dart';
import 'package:mclauncher4/src/tasks/utils/downloads.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/tasks/utils/utils.dart';
import 'package:mclauncher4/src/widgets/Buttons/downloadButton.dart';

class JavaInstallCard extends StatefulWidget {
  const JavaInstallCard({Key? key}) : super(key: key);

  @override
  _JavaInstallCardState createState() => _JavaInstallCardState();
}

class _JavaInstallCardState extends State<JavaInstallCard> {
  Download _downloader = Download();

  bool get isDownloading =>
      _downloader.downloadstate == DownloadState.customDownload;

  int installStep = 1;
  int stepAmount = 2;

  install() async {
    List<int> _bytes = await _downloader.downloadSingeFileAsBytes(
        "https://cdn.azul.com/zulu/bin/zulu8.72.0.17-ca-jdk8.0.382-win_x64.zip");

    Utils.extractZip(_bytes, '${await getinstances()}');
    _bytes = [];
    installStep++;
    _bytes = await _downloader.downloadSingeFileAsBytes(
        "https://cdn.azul.com/zulu/bin/zulu17.44.53-ca-jdk17.0.8.1-win_x64.zip");

    Utils.extractZip(_bytes, '${await getinstances()}');
    _bytes = [];

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
        child: AnimatedBuilder(
          animation: _downloader,
          builder: (context, child) => Column(children: [
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
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    isDownloading
                        ? DefaultTextStyle(
                            style: TextStyle(),
                            child: Text(
                              '$stepAmount/$installStep',
                              style:
                                  Theme.of(context).typography.black.bodyLarge,
                            ))
                        : TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style:
                                  Theme.of(context).typography.black.labelLarge,
                            )),
                    SizedBox(
                      height: 15,
                    ),
                    isDownloading
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                                width: 280,
                                child: LinearProgressIndicator(
                                  backgroundColor: Theme.of(context).colorScheme.background,
                                  value: _downloader.progress,
                                )))
                        : TextButton(
                            onPressed: install,
                            child: Text(
                              'Install',
                              style:
                                  Theme.of(context).typography.black.labelLarge,
                            )),
                  ]),
            ),
            SizedBox(
              height: 15,
            ),
          ]),
        ));
  }
}
