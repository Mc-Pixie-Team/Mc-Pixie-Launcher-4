import 'dart:ui';
import 'package:flutter/material.dart';

class BlurredContainer extends StatelessWidget {
  final Widget child;
  final double blurIntensity;
  final Color? overlayColor; // Make overlayColor optional

  BlurredContainer({
    required this.child,
    this.blurIntensity = 5.0,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurIntensity, sigmaY: blurIntensity),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Container(
            color: overlayColor ?? Colors.transparent, // Use overlayColor if provided, otherwise transparent
            child: child,
          ),
        ],
      ),
    );
  }
}
