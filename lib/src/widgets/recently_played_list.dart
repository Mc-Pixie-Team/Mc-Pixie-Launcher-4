import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mclauncher4/src/pages/installed_objects_handlers.dart';
import 'package:mclauncher4/src/tasks/install_object_handler.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/widgets/cards/recently_played_card.dart';
import 'package:mclauncher4/src/widgets/mod_picture.dart';
import 'package:hive/hive.dart' as hive;

class RecentlyPlayedList extends StatefulWidget {
  RecentlyPlayedList({Key? key, this.width = double.infinity, this.height = double.infinity, this.elemHeight = 50, required this.installObjectHandler}) : super(key: key);
  InstallObjectHandler installObjectHandler;
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
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
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
                        "Recently Played",
                        style: Theme.of(context).typography.black.bodySmall,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ValueListenableBuilder(valueListenable: widget.installObjectHandler.installControllers, builder: (context, value, child) => ListView.builder(
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
