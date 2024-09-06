import 'dart:convert';
import 'dart:io';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:mclauncher4/src/pages/providers/modlist_page.dart';
import 'package:mclauncher4/src/tasks/apis/curseforge.api.dart';
import 'package:mclauncher4/src/tasks/install_controller.dart';
import 'package:mclauncher4/src/tasks/install_object_handler.dart';
import 'package:mclauncher4/src/tasks/models/object_type.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/tasks/models/value_notifier_list.dart';
import 'package:mclauncher4/src/tasks/murmur_hash.dart';
import 'package:mclauncher4/src/theme/custom_page_transition.dart';
import 'package:mclauncher4/src/widgets/animated_text.dart';
import 'package:mclauncher4/src/widgets/buttons/svg_button.dart';
import 'package:mclauncher4/src/widgets/buttons/text_icon_button.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:numeral/numeral.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:mclauncher4/src/widgets/divider.dart' as divider;


class ModsPage extends StatefulWidget {
  List<InstallController> installControllers;
  String instanceName;
  ObjectType type;
  ModsPage(
      {Key? key,
      required this.installControllers,
      required this.instanceName,
      required this.type})
      : super(key: key);

  @override
  _ModsPageState createState() => _ModsPageState();
}

class _ModsPageState extends State<ModsPage> {
  @override
  Widget build(BuildContext context) {
    List sorted = widget.installControllers.toList();
    sorted.removeWhere((element) => element.modpackData.type != widget.type);
    print("build");
    return Column(children: [
      SizedBox(
        height: 8,
      ),
      Row(children: [
        Expanded(
            child: Container(
          height: 38,
          margin: EdgeInsets.only(left: 38, right: 48),
          decoration: ShapeDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 7,
                cornerSmoothing: 1,
              ),
            ),
          ),
          padding: EdgeInsets.all(9.0),
          child: Row(
            children: [
              Text(
                "Name",
                style: Theme.of(context)
                    .typography
                    .black
                    .bodySmall!
                    .copyWith(color: Theme.of(context).colorScheme.outline),
              ),
              SizedBox(
                width: 346,
              ),
              Text("Author",
                  style: Theme.of(context)
                      .typography
                      .black
                      .bodySmall!
                      .copyWith(color: Theme.of(context).colorScheme.outline)),
                SizedBox(width: 214,),
              Text("Downloads",
                  style: Theme.of(context)
                      .typography
                      .black
                      .bodySmall!
                      .copyWith(color: Theme.of(context).colorScheme.outline)),
           
            ],
          ),
        )),

 
      ]),
      SizedBox(
        height: 10,
      ),
      Expanded(
          child: DynMouseScroll(
              animationCurve: Curves.easeOutExpo,
              scrollSpeed: 0.5,
              durationMS: 400,
              builder: (context, _scrollController, physics) =>
                  ListView.builder(
                      physics: physics,
                      controller: _scrollController,
                      itemCount: sorted.length,
                      itemBuilder: (context, index) {
                        InstallController current = sorted[index];
                        return Container(
                          margin: EdgeInsets.only(
                            left: 38,
                            right: 49,
                          ),
                          padding: EdgeInsets.only(
                            left: 5,
                          ),
                          decoration: ShapeDecoration(
                            color: index.isEven
                                ? null
                                : Theme.of(context).colorScheme.surfaceContainerHigh,
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 7,
                                cornerSmoothing: 1,
                              ),
                            ),
                          ),
                          child: ModItem(
                            onDelete: current.delete,
                            imageuri: current.modpackData.icon,
                            name: current.modpackData.name ?? "",
                            downloads: current.modpackData.downloads,
                            author: current.modpackData.author,
                          ),
                        );
                      })))
    ]);
  }
}

class ModItem extends StatelessWidget {
  String name;
  String? imageuri;
  String? author;
  int? downloads;
  VoidCallback onDelete;
  ModItem(
      {Key? key,
      required this.onDelete,
      required this.name,
      required this.author,
      required this.downloads,
      this.imageuri})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 58,
        width: double.infinity,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                 width: 40,
                 margin: EdgeInsets.only(right: 15, left: 5),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                   
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child :  imageuri == null
                      ? SizedBox.shrink()
                      : Image.network(imageuri!, errorBuilder: (context, error, stackTrace) => Container(),)),
              SizedBox(
                  width: 300,
                  child: Text(
                    this.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )),
              SizedBox(
                width: 12,
              ),
              SizedBox(
                  width: 250,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        this.author ??
                            "not available",
                        style: Theme.of(context).typography.black.bodyMedium,
                      ))),
              this.downloads == null
                  ? Container()
                  : Text(
                      this.downloads!.numeral(),
                      style: Theme.of(context).typography.black.bodyMedium,
                    ),
            Expanded(child: SizedBox.expand()),
            SizedBox(height: 18, child: SvgButton.asset("assets/svg/trash-icon.svg", onpressed: onDelete)),
            SizedBox(width: 30,)
            ]));
  }
}
