import 'package:flutter/material.dart';
import 'dart:math' as math;

class PixieScrollSimulation extends Simulation {
  final double initPosition;
  final double velocity;
  final double afterPosition;

  PixieScrollSimulation({
    required this.initPosition,
    required this.afterPosition,
    required this.velocity,
  });

  @override
  double x(double time) {
    // print(time);
    // print(velocity);
    //(begin as dynamic) + ((end as dynamic) - (begin as dynamic)) * t
    print(initPosition);
    print(afterPosition);
    return  initPosition + afterPosition- initPosition * time;
  }

  @override
  double dx(double time) {
    return velocity;
    
  }

  @override
  bool isDone(double time) {
    return time >= 1;
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

    if (position.pixels.round() == oldPixel.round()) {
      return super.createBallisticSimulation(position, velocity);
    }

    double result = (oldPixelTemp - position.pixels).abs();

    if (result < 99) {
      return super.createBallisticSimulation(position, velocity);
    }

    this.oldPixel = position.pixels;

    return PixieScrollSimulation(
      afterPosition: oldPixelTemp,
      initPosition: position.pixels,
      velocity: 30.0,
    );
  }
}

class CustomSimulation extends Simulation {
  final double initPosition;
  final double velocity;

  CustomSimulation({required this.initPosition, required this.velocity});

  @override
  double x(double time) {
    return initPosition + velocity * time;
  }

  @override
  double dx(double time) {
    return velocity;
  }

  @override
  bool isDone(double time) {
    return false;
  }
}
