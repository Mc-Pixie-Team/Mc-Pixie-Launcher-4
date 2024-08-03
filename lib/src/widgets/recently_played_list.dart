import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/widgets/mod_picture.dart';
import 'package:hive/hive.dart' as hive;

class RecentlyPlayedList extends StatefulWidget {
  RecentlyPlayedList({Key? key, this.width = 200, this.height = 300, this.elemHeight = 50}) : super(key: key);
  final double width;
  final double height;

  final double elemHeight;
  @override
  _RecentlyPlayedListState createState() => _RecentlyPlayedListState();
}

class _RecentlyPlayedListState extends State<RecentlyPlayedList> {
  @override
  Widget build(BuildContext context) {
    hive.Box boxRaw = hive.Hive.box("RecentlyPlayed");
    return StreamBuilder<hive.BoxEvent>(
        stream: boxRaw.watch(),
        builder: (context, value) {
          return Container(
            height: widget.height,
            width: widget.width,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0), // Adjust padding as needed
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.expand_more,
                        size: 20,
                        color: Theme.of(context).typography.black.bodyMedium!.color,
                      ),
                      SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.recentlyPlayed,
                        style: Theme.of(context).typography.black.bodySmall,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Padding(
                            padding: !(index + 1 == 5) ? EdgeInsets.only(bottom: 10) : EdgeInsets.only(bottom: 10),
                            child: Container(
                              height: widget.elemHeight,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 9,
                                  ),
                                  ModPicture(
                                    width: widget.elemHeight - 15,
                                    height: widget.elemHeight - 15,
                                    borderRadius: BorderRadius.circular(8),
                                    url: "https://media.forgecdn.net/avatars/thumbnails/286/772/256/256/637305737753885398.png",
                                    color: Theme.of(context).colorScheme.surfaceVariant,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("Fabulously Optimized".split("").take(12).join("") + "...")
                                ],
                              ),
                            ));
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
