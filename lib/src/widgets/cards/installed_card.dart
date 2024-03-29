import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/models/download_states.dart';
import 'package:mclauncher4/src/tasks/IO_controller.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/tasks/utils/path.dart';
import 'package:mclauncher4/src/widgets/buttons/svg_button.dart';
import 'package:mclauncher4/src/widgets/buttons/download_button.dart';
import 'package:mclauncher4/src/widgets/export_field.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:path/path.dart' as path;

class InstalledCard extends StatefulWidget {
  final MainState state;
  final double progress;
  final VoidCallback onCancel;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final UMF modpackData;
  final String processId;
  InstalledCard(
      {Key? key,
      required this.onDelete,
      required this.processId,
      required this.modpackData,
      required this.state,
      required this.progress,
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
      widget.state == MainState.downloadingMinecraft ||
      widget.state == MainState.downloadingML ||
      widget.state == MainState.downloadingMods ||
      widget.state == MainState.running;

  AsyncSnapshot<Uint8List> snapshot = AsyncSnapshot.nothing();

  @override
  void initState() {
    print('init');
    super.initState();
  }

  Widget iconhandler() {
    print("icon: ${widget.modpackData.icon}");
    if (widget.modpackData.icon != null) {
      return FadeInImage.memoryNetwork(
          fit: BoxFit.cover, placeholder: kTransparentImage, image: widget.modpackData.icon!);
    }

    return Image.memory(
      File(path.join(getInstancePath(), widget.processId, "icon.png")).readAsBytesSync(),
      gaplessPlayback: true,
    );
    
    
  }

  onExport() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'export menu',
      barrierColor: Colors.black38,
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (ctx, anim1, anim2) =>Center(
          child: DefaultTextStyle(
              style: TextStyle(),
              child: ExportField(
                processId: widget.processId,
              ))),
      transitionBuilder: (context, anim1, anim2, child) {  


        
        
         Animation<double> ani = CurvedAnimation(parent: anim1, curve: Curves.easeOutExpo, reverseCurve: Curves.easeInExpo);
    
      return     ScaleTransition(
        scale: ani,
        filterQuality: FilterQuality.high,
        child:  FadeTransition(opacity: ani, child:  child));
 
   
  

  });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 180,
        height: 260,
        decoration: ShapeDecoration(
          color: Color(0xFF292929),
          shadows: [BoxShadow(spreadRadius: 3, blurRadius: 13, color: Color.fromARGB(57, 0, 0, 0))],
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
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(10)),
                      child: iconhandler()))),
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
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Padding(
                                  padding: EdgeInsets.only(left: 12),
                                  child: Text(
                                    widget.modpackData.name!,
                                    style: Theme.of(context).typography.black.titleMedium,
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(left: 12),
                                  child: Text(
                                    'by N/A',
                                    style: Theme.of(context).typography.black.bodySmall,
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
                                    padding: EdgeInsets.all(10).copyWith(top: 10, bottom: 15),
                                    child: GestureDetector(
                                        onTap: widget.onOpen,
                                        child: Container(
                                            height: double.infinity,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                color: Theme.of(context).colorScheme.surfaceVariant),
                                            child: Center(
                                                child: widget.state == MainState.installed
                                                    ? Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                          Text(
                                                            'Play',
                                                            style: Theme.of(context).typography.black.titleMedium,
                                                          ),
                                                           Padding( padding: EdgeInsets.only(top: 15, bottom: 15), child:  Container( height: double.infinity, width: 1, color: Theme.of(context).colorScheme.outline)),
                                                          SvgButton.asset('assets/svg/export-import-icon.svg',
                                                              onpressed: onExport),
                                                              SvgButton.asset('assets/svg/trash-icon.svg',
                                                              onpressed: widget.onDelete)
                                                        ],
                                                      )
                                                    : SizedBox(
                                                        height: 23,
                                                        width: 23,
                                                        child: DownloadButton(
                                                          mainState: widget.state,
                                                          mainprogress: widget.progress,
                                                          onCancel: widget.onCancel,
                                                          onOpen: widget.onOpen,
                                                          onDownload: () {},
                                                        ))))))))
                      ]))))
        ]));
  }
}
