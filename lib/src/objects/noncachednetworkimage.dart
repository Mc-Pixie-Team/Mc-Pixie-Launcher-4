import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

class NonCacheNetworkImage extends StatelessWidget {
  const NonCacheNetworkImage(this.imageUrl, {Key? key}) : super(key: key);
  final String imageUrl;
  Future<Uint8List> getImageBytes() async {
    Response response = await get(Uri.parse(imageUrl));
    return response.bodyBytes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: getImageBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) return Image.memory(
          
           fit: BoxFit.cover,
              // fadeOutDuration: const Duration(milliseconds: 1),
              // fadeInDuration: const Duration(milliseconds: 300),
              // fadeInCurve: Curves.easeOutQuad,
              // placeholder: kTransparentImage,
          snapshot.data!);
        return SizedBox(
          width: 100,
          height: 100,
          child: Text("NO DATA"),
        );
      },
    );
  }
}