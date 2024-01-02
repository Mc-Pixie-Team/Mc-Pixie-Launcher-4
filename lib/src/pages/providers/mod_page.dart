// ignore_for_file: prefer_interpolation_to_compose_strings, unnecessary_cast

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/widgets/buttons/svg_button.dart';
import 'package:mclauncher4/src/widgets/components/slide_in_animation.dart';
import 'package:mclauncher4/src/widgets/file_table/file_table.dart';
import 'package:mclauncher4/src/widgets/mod_picture.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:mclauncher4/src/widgets/divider.dart' as divider;

class ModPage extends StatefulWidget {
  UMF modpackData;

  ModPage({Key? key, required this.modpackData}) : super(key: key);

  @override
  _ModPageState createState() => _ModPageState();
}

class _ModPageState extends State<ModPage> {
  @override
  void initState() {
    print("init");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String modloaderstring = "";
    for (String modl in widget.modpackData.modloader) {
      modloaderstring += "$modl ";
    }

    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18)),
      child: Stack(
        children: [
          Positioned(
              top: 35,
              left: 20,
              child: SvgButton.asset(
                "assets/svg/dropdown-icon.svg",
                onpressed: () => Navigator.of(context).pop(),
                color: Theme.of(context).colorScheme.secondary,
                text: Text(
                  "Modpacks",
                  style: Theme.of(context).typography.black.labelLarge,
                ),
              )),
          Positioned.fill(
            top: 70,
            child: Column(children: [
              Row(children: [
                Padding(
                  padding: EdgeInsets.only(left: 40),
                  child: ModPicture(
                    width: 160,
                    url: widget.modpackData.icon!,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                SlideInAnimation(
                    curve: Curves.easeOutQuad,
                    duration: const Duration(milliseconds: 800),
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
                              .copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                        Text(
                          
                          widget.modpackData.name!,
                          style:
                              Theme.of(context).typography.black.displaySmall,
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
                              type2: widget.modpackData.downloads! > 999
                                  ? (((widget.modpackData.downloads! / 1000)
                                                  as double)
                                              .round())
                                          .toString() +
                                      'k'
                                  : widget.modpackData.downloads!.toString(),
                            ),
                            StackedItem(
                                type1: modloaderstring,
                                type2: widget.modpackData.MLVersion ?? "N/A"),
                            StackedItem(
                                type1: "Minecraft",
                                type2: widget.modpackData.MCVersion ?? "N/A")
                          ],
                        )
                      ],
                    ))
              ]),
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Text("Home"),
                  SizedBox(
                    width: 30,
                  ),
                  Text("Versions")
                ],
              ),
              const SizedBox(
                height: 6,
              ),
              divider.Divider(
                size: 32,
              ),
              const SizedBox(
                height: 30,
              ),
              Expanded(child: FileTable())
            ]),
          )
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class StackedItem extends StatelessWidget {
  String type1;
  String type2;

  StackedItem({required this.type1, required this.type2});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(right: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type1,
              style: Theme.of(context).typography.black.bodyMedium,
            ),
            SizedBox(
              height: 3,
            ),
            Text(
              type2,
              style: Theme.of(context).typography.black.labelLarge,
            )
          ],
        ));
  }
}
