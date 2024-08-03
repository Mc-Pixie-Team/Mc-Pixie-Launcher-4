import 'package:flutter/material.dart';

class OfflineIcon extends StatelessWidget {
  const OfflineIcon({Key? key, required double this.size, this.text = "No Connection 🥲"}) : super(key: key);

  final double size;

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [ Icon(
      Icons.wifi_off,
      size: size,
      color: Theme.of(context).colorScheme.primary,
    ),
    SizedBox(height: 15,),
    Text(text , style: Theme.of(context).typography.black.bodyMedium,)
    ]);
  }
}
