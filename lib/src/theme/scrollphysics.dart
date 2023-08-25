import 'package:flutter/material.dart';
import 'dart:math' as math;

class PixieScrollSimulation extends Simulation {
  final double initPosition;
  final double velocity;
  final double afterPosition;

  PixieScrollSimulation({required this.initPosition, required this.afterPosition, required this.velocity});

  @override
  double x(double time) {
    var timechange = 1 - time;
    double veloc = -math.pow(time, 2) * velocity;
    double max;
/*     print("init: $initPosition");
    print("after: $afterPosition"); */

    if (afterPosition > initPosition) {
      max = initPosition - veloc;
    } else {
      max = initPosition + veloc;
    }
    /* print("max: $max"); */
    if (max <= 0.0) {
      max = 0.0;
    }
    return max;
  }

  @override
  double dx(double time) {
    double veloc = -math.pow(time, 2) * velocity;

    return veloc;
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
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
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

    return PixieScrollSimulation(afterPosition: oldPixelTemp, initPosition: position.pixels, velocity: 30.0);
  }
}

class CustomSimulation extends Simulation {
  final double initPosition;
  final double velocity;

  CustomSimulation({required this.initPosition, required this.velocity});

  @override
  double x(double time) {
    var max =
        math.max(math.min(initPosition, 0.0), initPosition + velocity * time);

    // print(max.toString());

    return max;
  }

  @override
  double dx(double time) {
    // print(velocity.toString());
    return velocity;
  }

  @override
  bool isDone(double time) {
    return false;
  }
}


