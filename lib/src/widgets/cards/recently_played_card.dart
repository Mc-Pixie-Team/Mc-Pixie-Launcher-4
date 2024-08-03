import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/install_controller.dart';
import 'package:mclauncher4/src/tasks/installs/install_model.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:mclauncher4/src/widgets/mod_picture.dart';
import 'dart:math' as math;

class RecentlyPlayedCard extends StatefulWidget {
  int index;
  double height;
  InstallController controllerinstance;
  RecentlyPlayedCard(
      {Key? key, required this.index, this.height = 20, required this.controllerinstance})
      : super(key: key);

  @override
  _RecentlyPlayedCardState createState() => _RecentlyPlayedCardState();
}

class _RecentlyPlayedCardState extends State<RecentlyPlayedCard> {

  onChange() {
    var umf = widget.controllerinstance.modpackData;
     umf = umf.copyWith(name: (math.Random().nextDouble() * 100 ).ceilToDouble().toString() );
     widget.controllerinstance.changeModpackData(umf);
  }

  @override
  Widget build(BuildContext context) {
   
    return MouseRegion( cursor: SystemMouseCursors.click, child: GestureDetector(onTapUp: (_) =>  onChange(),
    //widget.controllerinstance.installState == InstallState.installed ?  widget.controllerinstance.start() : null,
      child: Padding(
        padding: !(widget.index + 1 == 5)
            ? EdgeInsets.only(bottom: 10)
            : EdgeInsets.only(bottom: 10),
        child: Container(
          height: widget.height,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 9,
              ),
              ModPicture(
                width: widget.height - 15,
                height: widget.height - 15,
                borderRadius: BorderRadius.circular(8),
                url:
                    "https://media.forgecdn.net/avatars/thumbnails/286/772/256/256/637305737753885398.png",
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Text(
                widget.controllerinstance.modpackData.name ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )),
               SizedBox(
                width: 8,
              ),
            ],
          ),
        ))));
  }
}
