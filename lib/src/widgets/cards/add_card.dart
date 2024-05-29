import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class AddCard extends StatefulWidget {
  const AddCard({Key? key}) : super(key: key);

  @override
  _AddCardState createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  onAddModpack() {}

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(top: 8),child: MouseRegion(
        cursor: SystemMouseCursors.click,
        hitTestBehavior: HitTestBehavior.deferToChild,
        child: GestureDetector(
            onTap: onAddModpack,
            child: DottedBorder(
              dashPattern: [2, 2],
              color: Theme.of(context).colorScheme.outlineVariant,
              strokeWidth: 1,
              borderType: BorderType.RRect,
              radius: Radius.circular(18),
              child: Container(
                width: 165,
                height: 245,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.outlineVariant,
                        size: 34,
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text(
                        "Add",
                        style: Theme.of(context)
                            .typography
                            .black
                            .bodyMedium!
                            .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant),
                      )
                    ],
                  ),
                ),
              ),
            ))));
  }
}
