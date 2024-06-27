import 'package:flutter/material.dart';
import 'package:mclauncher4/src/pages/providers/mod_page.dart';
import 'package:mclauncher4/src/widgets/components/slide_in_animation.dart';
import 'package:mclauncher4/src/widgets/mod_picture.dart';
import 'package:numeral/numeral.dart';

class ModpackTitleIconWidget extends StatefulWidget {
  String? iconUrl;
  String? name;
  int? downloads;
  String? mlVersion;
  String? mcVersion;
  List<String> modloader;
  
  ModpackTitleIconWidget(
      {Key? key,
      required this.modloader,
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
  String modloaderstring = "";

  @override
  Widget build(BuildContext context) {
     modloaderstring = "";
    for (String modl in widget.modloader) {
     
   modloaderstring += "$modl ";
    }

    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 40),
          child: ModPicture(
            width: 140,
            height: 140,
            url: widget.iconUrl!,
            color: Theme.of(context).colorScheme.surface,
          ),
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
              children: [
                Text(
                  "Modpack",
                  style: Theme.of(context)
                      .typography
                      .black
                      .labelLarge!
                      .copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w400),
                ),
                Text(
                  widget.name!,
                  style: Theme.of(context).typography.black.displaySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    StackedItem(
                      type1: "Downloads",
                      type2: widget.downloads!.numeral()
                    ),
                    StackedItem(
                        type1: modloaderstring,
                        type2: widget.mlVersion ?? "N/A"),
                    StackedItem(
                        type1: "Minecraft",
                        type2: widget.mcVersion ?? "N/A")
                  ],
                )
              ],
            ))
      ],
    );
  }
}
