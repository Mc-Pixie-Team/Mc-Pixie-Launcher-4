import 'package:flutter/material.dart';
import 'package:mclauncher4/src/widgets/bluredContainer.dart';

class SidePanelWidget extends StatefulWidget {
  SidePanelWidget({Key? key, required this.title, required this.child}) : super(key: key);
  String title;
  Widget child;
  @override
  _SidePanelWidgetState createState() => _SidePanelWidgetState();
}

class _SidePanelWidgetState extends State<SidePanelWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: Theme.of(context).colorScheme.surfaceVariant),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: widget.child,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Column(children: [
              Container(
                height: 50,
                decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18))),
                clipBehavior: Clip.antiAlias,
                child: BlurredContainer(
                  overlayColor: Color.fromARGB(4, 255, 255, 255),
                  child:
                      Center(child: Text(style: Theme.of(context).typography.black.bodyMedium!.merge(TextStyle(color: Colors.white)), widget.title)),
                ),
              ),
              Divider(
                height: 0.02,
                color: Color.fromARGB(44, 255, 255, 255),
              )
            ]),
          )
        ],
      ),
    );
  }
}
