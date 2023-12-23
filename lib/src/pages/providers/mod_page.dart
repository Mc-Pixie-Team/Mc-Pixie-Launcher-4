import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/widgets/buttons/svg_button.dart';
import 'package:mclauncher4/src/widgets/components/slide_in_animation.dart';
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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18)),
      child: Stack(
        children: [
          Positioned(
              top: 20,
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
          Positioned(
              top: 60,
              child: Align(
                alignment: Alignment.topLeft,
                //TOP
                child: Column( children: [ Row(children: [
                 Container(
                        margin: const EdgeInsets.only(left: 50),
                        width: 145,
                        height: 145,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Theme.of(context).colorScheme.surface),
                        child: FadeInImage.memoryNetwork(
                          fit: BoxFit.fill,
                          fadeOutDuration: const Duration(milliseconds: 1),
                          fadeInDuration: const Duration(milliseconds: 300),
                          fadeInCurve: Curves.easeOutQuad,
                          placeholder: kTransparentImage,
                          image: widget.modpackData.icon!,
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
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                          ),
                          Text(
                            widget.modpackData.name!,
                            style:
                                Theme.of(context).typography.black.displaySmall,
                          ),
                          SizedBox(
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
                              StackedItem(type1: widget.modpackData.modloader ?? "N/A", type2: widget.modpackData.MLVersion ?? "N/A" ),
                              StackedItem(type1: "Minecraft", type2: widget.modpackData.MCVersion ?? "N/A" )
                            ],
                          )
                        ],
                      ))
                ]),
                  
                ]),
              ))
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
    return Padding(padding: EdgeInsets.only(left: 10, right: 20),child: Column(
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
