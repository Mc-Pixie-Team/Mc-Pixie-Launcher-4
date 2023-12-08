// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mclauncher4/src/tasks/models/download_states.dart';
import 'package:mclauncher4/src/tasks/fabric/fabric.dart';
import 'package:mclauncher4/src/tasks/forge/forge.dart';
import 'package:mclauncher4/src/tasks/models/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:mclauncher4/src/widgets/Buttons/SvgButton.dart';
import 'package:mclauncher4/src/widgets/Buttons/downloadButton.dart';
import 'package:transparent_image/transparent_image.dart';

class BrowseCard extends StatefulWidget {
  Map modpacklist;
  final VoidCallback onDownload;
  final VoidCallback onCancel;
  final VoidCallback onOpen;
  final MainState mainState;
  final double mainprogress;
  final double progress;
  final String processId;
  BrowseCard({
    Key? key,
    required this.processId,
    required this.mainprogress,
    required this.modpacklist,
    required this.progress,
    required this.mainState,
    required this.onDownload,
    required this.onCancel,
    required this.onOpen,
  }) : super(key: key);

  String get process_id => processId;

  @override
  _BrowseCardState createState() => _BrowseCardState();
}

class _BrowseCardState extends State<BrowseCard> {
  String capitalize(String myString) {
    myString = myString
        .replaceAll(RegExp(' +'), ' ')
        .split(' ')
        .map((capitalizedString) =>
            capitalizedString.substring(0, 1).toUpperCase() +
            capitalizedString.substring(1))
        .join(' ');
    return myString;
  }

 

  @override
  Widget build(BuildContext context) {
    print('test');
    return Padding(
        padding: EdgeInsets.only(
          top: 30,
          left: 32,
          right: 32,
        ),
        child: Container(
            clipBehavior: Clip.antiAlias,
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(17),
                  child: Container(
                      width: 127,
                      height: 127,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Theme.of(context).colorScheme.surfaceVariant),
                      child: FadeInImage.memoryNetwork(
                        fit: BoxFit.fill,
                        fadeOutDuration: Duration(milliseconds: 1),
                        fadeInDuration: Duration(milliseconds: 300),
                        fadeInCurve: Curves.easeOutQuad,
                        placeholder: kTransparentImage,
                        image: widget.modpacklist["icon_url"],
                      )),
                ),
                Expanded(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 25,
                    ),
                    Text(
                      widget.modpacklist["title"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).typography.black.headlineSmall,
                    ),
                    SizedBox(width: 400, child:
                    Text(
                      widget.modpacklist["description"],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).typography.black.bodyMedium,
                    )),
                    Expanded(
                      child: Container(),
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets\\svg\\heart-icon.svg',
                          width: 12,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          widget.modpacklist["follows"] > 999
                              ? (((widget.modpacklist["follows"] / 1000)
                                              as double)
                                          .round())
                                      .toString() +
                                  'k'
                              : widget.modpacklist["follows"].toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        SvgPicture.asset(
                          'assets\\svg\\download-full-icon.svg',
                          width: 14,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          widget.modpacklist["downloads"] > 999
                              ? (((widget.modpacklist["downloads"] / 1000)
                                              as double)
                                          .round())
                                      .toString() +
                                  'k'
                              : widget.modpacklist["downloads"].toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                            child: SizedBox(
                                height: 17,
                                child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                          padding: EdgeInsets.only(
                                              left: 5, right: 5),
                                          child: Text(
                                            capitalize(
                                                widget.modpacklist["categories"]
                                                    [index]),
                                            style: TextStyle(
                                              color: Color.fromARGB(132, 226, 226, 226),
                                              fontSize: 13,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w500,
                                              height: 0,
                                            ),
                                          ));
                                    },
                                    separatorBuilder: (context, index) {
                                      return Container(
                                        width: 5.0,
                                        height: 5.0,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline),
                                      );
                                    },
                                    itemCount: widget
                                        .modpacklist["categories"].length)))
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                )),
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: 45,
                        width: 95,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              DownloadButton(
                                  mainState: widget.mainState,
                                  mainprogress: widget.mainprogress,
                                  onOpen: widget.onOpen,
                                  onCancel: widget.onCancel,
                                  onDownload: widget.onDownload),
                              SvgButton.asset('assets\\svg\\network-icon.svg',
                                  onpressed: () {})
                            ]),
                      ),
                    ))
              ],
            )));
  }
}

@immutable
class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget({
    super.key,
    required this.downloadProgress,
    required this.isDownloading,
    required this.isFetching,
  });

  final double downloadProgress;
  final bool isDownloading;
  final bool isFetching;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: downloadProgress),
        duration: const Duration(milliseconds: 200),
        builder: (context, progress, child) {
          return CircularProgressIndicator(
            backgroundColor: isDownloading
                ? Theme.of(context).colorScheme.outline
                : Colors.white.withOpacity(0),
            valueColor: AlwaysStoppedAnimation(
             
                 Theme.of(context).colorScheme.primary),
            strokeWidth: 2,
            value: isFetching ? null : progress / 100,
          );
        },
      ),
    );
  }
}
