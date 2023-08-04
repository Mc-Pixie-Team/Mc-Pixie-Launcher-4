import 'package:flutter/material.dart';
import 'dart:math' as math;

class PixieScrollSimulation extends Simulation {
  final double initPosition;
  final double velocity;
  final double afterPosition;

  PixieScrollSimulation(
      {required this.initPosition,
      required this.afterPosition,
      required this.velocity});

  @override
  double x(double time) {
    var timechange = 1 - time;

    var max = initPosition + (time * (velocity + timechange * velocity));
    if (afterPosition > initPosition) {
      max = math.max(
          initPosition - (time * (velocity + timechange * velocity)), 0.0);
    }

    return max;
  }

  @override
  double dx(double time) {
    return velocity;
  }

  @override
  bool isDone(double time) {
    var timechange = 1 - time;

    if (time >= 1) {
      //  print('true');
      return true;
    }

    return false;
  }
}

class PixieScrollPhysics extends ScrollPhysics {
  double oldPixel = 0.0;

  @override
  ScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PixieScrollPhysics();
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    var oldPixelTemp = oldPixel;
    // print('redo');

    if (position.pixels.round() == oldPixel.round()) {
      return super.createBallisticSimulation(position, velocity);
    }
    double result = (oldPixelTemp - position.pixels);
    if (result < 0) {
      result *= -1;
    }
    // print('result: ' + result.toString());
    if (result < 99) {
      return super.createBallisticSimulation(position, velocity);
    }
    this.oldPixel = position.pixels;
    //  print(position.extentBefore);
    //  print(position.extentAfter);
    //  print(position.extentInside);
    //  print(position.maxScrollExtent);

    return PixieScrollSimulation(
        afterPosition: oldPixelTemp,
        initPosition: position.pixels,
        velocity: 30.0);
  }
}
