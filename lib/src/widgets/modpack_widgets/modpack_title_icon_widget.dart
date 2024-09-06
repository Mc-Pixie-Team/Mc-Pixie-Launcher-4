import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mclauncher4/src/pages/providers/mod_page.dart';
import 'package:mclauncher4/src/widgets/components/slide_in_animation.dart';
import 'package:mclauncher4/src/widgets/mod_picture.dart';
import 'package:numeral/numeral.dart';
import 'package:transparent_image/transparent_image.dart';

class ModpackTitleIconWidget extends StatefulWidget {
  String? iconUrl;
  String? name;
  int? downloads;
  String? mlVersion;
  String? mcVersion;
  String? alterIconPath;
  String modloader;

  ModpackTitleIconWidget(
      {Key? key,
      required this.modloader,
      this.alterIconPath,
      this.downloads,
      this.iconUrl,
      this.mcVersion,
      this.mlVersion,
      this.name})
      : super(key: key);

  @override
  _ModpackTitleIconWidgetState createState() => _ModpackTitleIconWidgetState();
}

class _ModpackTitleIconWidgetState extends State<ModpackTitleIconWidget> {

    Widget iconhandler() {
    print("icon: ${widget.iconUrl}");
    if (widget.alterIconPath != null && File(widget.alterIconPath!).existsSync()) {
      print("USE Local");

          return Image.memory(
      File(widget.alterIconPath!)
          .readAsBytesSync(),
      gaplessPlayback: true,
    );

    }

  if(widget.iconUrl != null) {
          return FadeInImage.memoryNetwork(
          fit: BoxFit.cover,
          placeholder: kTransparentImage,
          image: widget.iconUrl!);
  }
  throw "COULD NOT FIND IMAGE";
  }

  @override
  Widget build(BuildContext context) {
    return      LayoutBuilder(builder: (context, constraints) {
   
          return    Row(
          
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 40),
          child: Container(clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: Theme.of(context).colorScheme.surfaceContainerHigh), height: 140, width: 140, child: iconhandler(),)
        ),
        const SizedBox(
          width: 20,
        ),
     SlideInAnimation(
            curve: Curves.easeOutQuad,
            duration: const Duration(milliseconds: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
             
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Modpack",
                  style: Theme.of(context)
                      .typography
                      .black
                      .labelLarge!
                      .copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w400),
                ),
           ConstrainedBox(constraints: BoxConstraints(maxWidth: constraints.maxWidth -  200.0),child: Text(
                  widget.name!,
                  style: Theme.of(context).typography.black.displaySmall,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                )),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    StackedItem(
                        type1: "Downloads", type2: widget.downloads!.numeral()),
                    StackedItem(
                        type1: widget.modloader,
                        type2: widget.mlVersion ?? "N/A"),
                    StackedItem(
                        type1: "Minecraft", type2: widget.mcVersion ?? "N/A")
                  ],
                )
              ],
            ))
      ],
    );});
  }
}
