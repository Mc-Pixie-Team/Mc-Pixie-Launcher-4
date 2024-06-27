import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class  SlowMaterialPageRoute extends MaterialPageRoute {
  @override
  Duration get transitionDuration => const Duration(milliseconds: 4400);

  

 SlowMaterialPageRoute({builder, super.allowSnapshotting = true,}) : super(builder: builder);
}

class SlowCupertinoPageRoute extends CupertinoPageRoute {
  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);
   SlowCupertinoPageRoute({builder, super.allowSnapshotting = true, super.maintainState, super.barrierDismissible, super.fullscreenDialog, super.settings}) : super(builder: builder);
}