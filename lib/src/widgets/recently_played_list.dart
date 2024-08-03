import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mclauncher4/src/pages/installed_modpacks_handler.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/widgets/cards/recently_played_card.dart';
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

    return 
         Container(
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
                    child: ValueListenableBuilder(valueListenable: InstalledModpacksHandler.globalInstallControllers, builder: (context, value, child) => ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return AnimatedBuilder(animation: value[index].installModel, builder:(context, child) =>  RecentlyPlayedCard(index: index, height: widget.elemHeight, controllerinstance: value[index]));
                      },
                    )),
                  ),
                ],
              ),
            ),
          );
        
  }
}
