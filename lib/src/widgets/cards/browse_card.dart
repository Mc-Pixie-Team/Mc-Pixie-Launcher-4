// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mclauncher4/src/pages/providers/mod_page.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/models/download_states.dart';
import 'package:mclauncher4/src/tasks/fabric/fabric.dart';
import 'package:mclauncher4/src/tasks/forge/forge.dart';
import 'package:mclauncher4/src/tasks/models/modloaderVersion.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/tasks/models/version_object.dart';
import 'package:mclauncher4/src/theme/custom_page_transition.dart';
import 'package:mclauncher4/src/widgets/buttons/svg_button.dart';
import 'package:mclauncher4/src/widgets/buttons/download_button.dart';
import 'package:mclauncher4/src/widgets/mod_picture.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:numeral/numeral.dart';
// ignore: must_be_immutable
class BrowseCard extends StatefulWidget {
  UMF modpackData;
  VoidCallback onDownload;
  VoidCallback onCancel;
  VoidCallback onOpen;
  MainState state;
  double progress;
  String processId;
  String handlerString;
  BrowseCard({
    Key? key,
    required this.handlerString,
    required this.processId,
    required this.modpackData,
    required this.progress,
    required this.state,
    required this.onDownload,
    required this.onCancel,
    required this.onOpen,
  }) : super(key: key);

  String get process_id => processId;

  @override
  _BrowseCardState createState() => _BrowseCardState();
}

class _BrowseCardState extends State<BrowseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 130));

    _animation = Tween(begin: 1.0, end: 0.96).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));
    Numeral.digits = 1;

    super.initState();
  }

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
    return  Padding(
        padding: EdgeInsets.only(
          top: 30,
          left: 32,
          right: 32,
        ),
        child: MouseRegion(
            cursor: MouseCursor.defer,
            onExit: (PointerExitEvent event) => _controller.reverse(),
            child: GestureDetector(
                onTapDown: (details) => _controller.forward(),
                onTapUp: (details)  {
           
                 // _controller.reverse();
                Navigator.push(
    context,
   SlowMaterialPageRoute(allowSnapshotting: false, builder: (context) =>  ModPage(handlerString: widget.handlerString, modpackData: widget.modpackData),
  ));
                 

                },
                child: ScaleTransition(
                  filterQuality: FilterQuality.high,
                    scale: _animation,
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
                              child: ModPicture(width: 127, url: widget.modpackData.icon!, color:  Theme.of(context).colorScheme.surfaceVariant,),
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
                                  widget.modpackData.name!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .typography
                                      .black
                                      .headlineSmall,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                SizedBox(
                                    width: 400,
                                    child: Text(
                                      widget.modpackData.description!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .typography
                                          .black
                                          .bodyMedium,
                                    )),
                                Expanded(
                                  child: Container(),
                                ),
                                Row(
                                  children: [
                                widget.modpackData.likes != null ?  Row(children: [
                                   SvgPicture.asset(
                                      'assets/svg/heart-icon.svg',
                                      width: 12,
                                    ) ,
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      widget.modpackData.likes!.numeral(),
                                         
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
                                 ],): SizedBox.shrink(), 
                                    SvgPicture.asset(
                                      'assets/svg/download-full-icon.svg',
                                      width: 14,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      widget.modpackData.downloads!.numeral()
                                    ),
                                    SizedBox(width: 15),
                                    Expanded(
                                        child: SizedBox(
                                            height: 17,
                                            child: ListView.separated(
                                                scrollDirection:
                                                    Axis.horizontal,
                                               itemBuilder: (context, index) {
                                                  return Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 5, right: 5),
                                                      child: Text(
                                                        capitalize(widget
                                                                .modpackData
                                                                .categories![
                                                            index]),
                                                        style: TextStyle(
                                                          color: Color.fromARGB(
                                                              132,
                                                              226,
                                                              226,
                                                              226),
                                                          fontSize: 13,
                                                       
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          height: 0,
                                                        ),
                                                      ));
                                                },
                                                separatorBuilder:
                                                    (context, index) {
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
                                                itemCount: widget.modpackData
                                                    .categories!.length)))
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant,
                                    ),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          DownloadButton(
                                              mainState: widget.state,
                                              mainprogress: widget.progress,
                                              onOpen: widget.onOpen,
                                              onCancel: widget.onCancel,
                                              onDownload: widget.onDownload),
                                          SvgButton.asset(
                                              'assets/svg/network-icon.svg',
                                              onpressed: () {})
                                        ]),
                                  ),
                                ))
                          ],
                        ))))));
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
            valueColor:
                AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
            strokeWidth: 2,
            value: isFetching ? null : progress / 100,
          );
        },
      ),
    );
  }
}
