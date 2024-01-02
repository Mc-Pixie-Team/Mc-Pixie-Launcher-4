import 'package:flutter/material.dart';

class  SlowMaterialPageRoute extends MaterialPageRoute {
  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

 SlowMaterialPageRoute({builder, super.allowSnapshotting = false}) : super(builder: builder);
}