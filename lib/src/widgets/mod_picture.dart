import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class ModPicture extends StatelessWidget {
  const ModPicture({
    super.key,
    required this.width,
    required this.height,
    required this.url,
    required this.color,
  });

  final String url;
  final double height;
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Hero(
        tag: url,
        child: Container(
          clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color:color),
            child: FadeInImage.memoryNetwork(
              fit: BoxFit.cover,
              fadeOutDuration: const Duration(milliseconds: 1),
              fadeInDuration: const Duration(milliseconds: 300),
              fadeInCurve: Curves.easeOutQuad,
              placeholder: kTransparentImage,
              image: url,
            )),
      ),
    );
  }
}
