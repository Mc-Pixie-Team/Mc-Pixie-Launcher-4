import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/downloadState.dart';
import 'package:mclauncher4/src/tasks/IOController.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/widgets/Buttons/SvgButton.dart';
import 'package:mclauncher4/src/widgets/Buttons/downloadButton.dart';
import 'package:transparent_image/transparent_image.dart';

class InstalledCard extends StatefulWidget {
  final MainState mainState;
  final double mainprogress;
  final VoidCallback onCancel;
  final VoidCallback onOpen;
  final Map modpackData;
  final String processId;
  InstalledCard(
      {Key? key,
      required this.processId,
      required this.modpackData,
      required this.mainState,
      required this.mainprogress,
      required this.onCancel,
      required this.onOpen})
      : super(key: key);

  String get process_id => processId;

  @override
  _InstalledCardState createState() => _InstalledCardState();
}

class _InstalledCardState extends State<InstalledCard> {
  bool ishovered = false;
  late bool isDownloading;

  bool get _isDownloading =>
      widget.mainState == MainState.downloadingMinecraft ||
      widget.mainState == MainState.downloadingML ||
      widget.mainState == MainState.downloadingMods ||
      widget.mainState == MainState.running;


  Widget iconhandler() {
    if(widget.modpackData["icon_url"] != null) {
      return FadeInImage.memoryNetwork(
                          fit: BoxFit.cover,
                          placeholder: kTransparentImage,
                          image:
                              widget.modpackData["icon_url"]);
    }
    return Image.memory(File("${getInstancePathSync()}\\${widget.processId}\\icon.png").readAsBytesSync(),  fit: BoxFit.cover,);
    
  }

  onExport() {
    showGeneralDialog(
      barrierLabel: 'Java not installed',
      barrierColor: Colors.black38,
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) => Center(
        child: Container(
          height: 600,
          width: 500,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).colorScheme.surfaceVariant),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
              ),
              DefaultTextStyle(style: TextStyle(), child:  Text(
                "Export...",
                style: Theme.of(context).typography.black.displaySmall,
              ),),
             
              Expanded(child: SizedBox.expand()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CupertinoButton.filled(
                    onPressed: () =>
                        ImportExportController().export(widget.processId),
                    child: Text('Export'),
                  ),
                  CupertinoButton.filled(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
      transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: FadeTransition(
          child: child,
          opacity: anim1,
        ),
      ),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 180,
        height: 260,
        decoration: ShapeDecoration(
          color: Color(0xFF292929),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: EdgeInsets.all(10),
              child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(8)),
                      child:iconhandler() ))),
          Expanded(
              child: MouseRegion(
                  onEnter: (e) => setState(() {
                        ishovered = true;
                      }),
                  onExit: (e) => setState(() {
                        ishovered = false;
                      }),
                  child: SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: Stack(children: [
                        AnimatedOpacity(
                            duration: Duration(milliseconds: 100),
                            opacity: _isDownloading
                                ? 0
                                : ishovered
                                    ? 0
                                    : 1,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding: EdgeInsets.only(left: 12),
                                      child: Text(
                                        widget.modpackData["name"],
                                        style: Theme.of(context)
                                            .typography
                                            .black
                                            .titleMedium,
                                      )),
                                  Padding(
                                      padding: EdgeInsets.only(left: 12),
                                      child: Text(
                                        'by N/A',
                                        style: Theme.of(context)
                                            .typography
                                            .black
                                            .bodySmall,
                                      ))
                                ])),
                        Align(
                            alignment: Alignment.center,
                            child: AnimatedOpacity(
                                duration: Duration(milliseconds: 100),
                                opacity: _isDownloading
                                    ? 1
                                    : ishovered
                                        ? 1
                                        : 0,
                                child: Padding(
                                    padding: EdgeInsets.all(10)
                                        .copyWith(top: 15, bottom: 15),
                                    child: GestureDetector(
                                        onTap: widget.onOpen,
                                        child: Container(
                                            height: double.infinity,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceVariant),
                                            child: Center(
                                                child: widget.mainState ==
                                                        MainState.installed
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Text(
                                                            'Play',
                                                            style: Theme.of(
                                                                    context)
                                                                .typography
                                                                .black
                                                                .titleMedium,
                                                          ),
                                                          SvgButton.asset(
                                                              'assets/svg/cancel-icon.svg',
                                                              onpressed:
                                                                  onExport)
                                                        ],
                                                      )
                                                    : SizedBox(
                                                        height: 23,
                                                        width: 23,
                                                        child: DownloadButton(
                                                          mainState:
                                                              widget.mainState,
                                                          mainprogress: widget
                                                              .mainprogress,
                                                          onCancel:
                                                              widget.onCancel,
                                                          onOpen: widget.onOpen,
                                                          onDownload: () {},
                                                        ))))))))
                      ]))))
        ]));
  }
}
