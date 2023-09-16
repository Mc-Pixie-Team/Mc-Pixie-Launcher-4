import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/downloadState.dart';
import 'package:mclauncher4/src/widgets/SvgButton.dart';
import 'package:transparent_image/transparent_image.dart';

class BrowseCard extends StatefulWidget {
  Map modpacklist;
  final double progress;
  final DownloadState state;
  final VoidCallback onDownload;
  final VoidCallback onCancel;
  final VoidCallback onOpen;

  BrowseCard({
    Key? key,
    required this.modpacklist,
    required this.progress,
    required this.state,
    required this.onDownload,
    required this.onCancel,
    required this.onOpen,
  }) : super(key: key);

  @override
  _BrowseCardState createState() => _BrowseCardState();
}

class _BrowseCardState extends State<BrowseCard> {
  bool ishover = false;

  @override
  Widget build(BuildContext context) {
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
                      child: AnimatedScale(
                          scale: ishover ? 1.2 : 1,
                          duration: Duration(milliseconds: 700),
                          curve: Curves.easeOutExpo,
                          child: FadeInImage.memoryNetwork(
                            fit: BoxFit.fill,
                            fadeOutDuration: Duration(milliseconds: 1),
                            fadeInDuration: Duration(milliseconds: 300),
                            fadeInCurve: Curves.easeOutQuad,
                            placeholder: kTransparentImage,
                            image: widget.modpacklist["icon_url"],
                          ))),
                ),
                Expanded(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 33,
                    ),
                    Text(
                      widget.modpacklist["title"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).typography.black.headlineSmall,
                    ),
                    Text(
                      widget.modpacklist["description"],
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).typography.black.bodyMedium,
                    ),
                    Text('test')
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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgButton.asset(
                              'assets\\svg\\download-icon.svg',
                              onpressed: () {
                                widget.onDownload.call();
                              },
                            ),
                            SvgButton.asset(
                              'assets\\svg\\network-icon.svg',
                              onpressed: () {},
                            ),
                          ],
                        )),
                  ),
                )
              ],
            )));
  }
}
