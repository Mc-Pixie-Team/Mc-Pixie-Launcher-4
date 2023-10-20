import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/downloadState.dart';
import 'package:mclauncher4/src/tasks/IOController.dart';
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
                      child: FadeInImage.memoryNetwork(
                          fit: BoxFit.cover,
                          placeholder: kTransparentImage,
                          image:
                              'https://images.unsplash.com/photo-1622737133809-d95047b9e673?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1932&q=80')))),
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
                                        'by ATM Team',
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
                                                    ? Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                                      Text(
                                                        'Play',
                                                        style: Theme.of(context)
                                                            .typography
                                                            .black
                                                            .titleMedium,
                                                      ),
                                                      SvgButton.asset('assets/svg/cancel-icon.svg', onpressed: () => {
                                                        ImportExportController().export(widget.processId)
                                                      })
                                                    ],)
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
