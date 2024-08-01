import 'package:flutter/material.dart';

class OfflineIcon extends StatelessWidget {
  const OfflineIcon({Key? key, required double this.size}) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.wifi_off,
      size: size,
    );
  }
}
