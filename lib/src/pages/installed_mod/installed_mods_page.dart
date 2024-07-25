import 'dart:convert';
import 'dart:io';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:mclauncher4/src/pages/providers/modlist_page.dart';
import 'package:mclauncher4/src/tasks/apis/curseforge.api.dart';
import 'package:mclauncher4/src/tasks/apis/files/files_handler.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/tasks/models/value_notifier_list.dart';
import 'package:mclauncher4/src/tasks/murmur_hash.dart';
import 'package:mclauncher4/src/widgets/animated_text.dart';
import 'package:mclauncher4/src/widgets/buttons/svg_button.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:numeral/numeral.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:mclauncher4/src/widgets/divider.dart' as divider;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ModsPage extends StatefulWidget {
  List<UMF> files;
  ModsPage({Key? key, required this.files}) : super(key: key);

  @override
  _ModsPageState createState() => _ModsPageState();
}

class _ModsPageState extends State<ModsPage> {
  @override
  Widget build(BuildContext context) {
    print("build");
    return Column(children: [
      SizedBox(
        height: 8,
      ),
      Row(children: [
        Expanded(
            child: Container(
          height: 38,
          margin: EdgeInsets.only(left: 38, right: 10),
          decoration: ShapeDecoration(
            color: Theme.of(context).colorScheme.surface,
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
                widget.files.length.toString(),
                style: Theme.of(context).typography.black.bodySmall!.copyWith(color: Theme.of(context).colorScheme.outline),
              ),
              SizedBox(
                width: 60,
              ),
              Text(
                AppLocalizations.of(context)!.name,
                style: Theme.of(context).typography.black.bodySmall!.copyWith(color: Theme.of(context).colorScheme.outline),
              ),
              SizedBox(
                width: 310,
              ),
              Text(" " + AppLocalizations.of(context)!.author,
                  style: Theme.of(context).typography.black.bodySmall!.copyWith(color: Theme.of(context).colorScheme.outline)),
              SizedBox(
                width: 163,
              ),
              Text(AppLocalizations.of(context)!.download,
                  style: Theme.of(context).typography.black.bodySmall!.copyWith(color: Theme.of(context).colorScheme.outline))
            ],
          ),
        )),
        GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ModListPage(providerString: "curseforge")));
            },
            child: Container(
              height: 38,
              width: 130,
              margin: EdgeInsets.only(left: 10, right: 49),
              padding: EdgeInsets.only(right: 3),
              decoration: ShapeDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 7,
                    cornerSmoothing: 1,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SvgPicture.asset("assets/svg/add-icon.svg", height: 15, width: 15, color: Theme.of(context).colorScheme.primary),
                  Text(
                    AppLocalizations.of(context)!.addMods,
                    textAlign: TextAlign.center,
                  )
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
              builder: (context, _scrollController, physics) => ListView.builder(
                  physics: physics,
                  controller: _scrollController,
                  itemCount: widget.files.length,
                  itemBuilder: (context, index) {
                    var current = widget.files[index];
                    return Container(
                      margin: EdgeInsets.only(
                        left: 38,
                        right: 49,
                      ),
                      padding: EdgeInsets.only(
                        left: 20,
                      ),
                      decoration: ShapeDecoration(
                        color: index.isOdd ? null : Theme.of(context).colorScheme.surface,
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 7,
                            cornerSmoothing: 1,
                          ),
                        ),
                      ),
                      child: ModItem(
                        name: current.name ?? "",
                        downloads: current.downloads,
                        author: current.author,
                      ),
                    );
                  })))
    ]);
  }
}

class ModItem extends StatelessWidget {
  String name;
  String? author;
  int? downloads;
  ModItem({Key? key, required this.name, required this.author, required this.downloads}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 50,
        width: double.infinity,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
              width: 300,
              child: Text(
                this.name,
              )),
          SizedBox(
            width: 60,
          ),
          SizedBox(
              width: 300,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    this.author ?? AppLocalizations.of(context)!.notAvailable,
                    style: Theme.of(context).typography.black.bodyMedium,
                  ))),
          this.downloads == null
              ? Container()
              : Text(
                  this.downloads!.numeral(),
                  style: Theme.of(context).typography.black.bodyMedium,
                )
        ]));
  }
}
