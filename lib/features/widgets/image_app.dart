import 'dart:typed_data';

import 'package:flutter/material.dart';

class ImageApp extends StatelessWidget {

  Uint8List? url;
  double? height;
  double? width;
  BoxFit? fit;

  ImageApp({
    super.key,
    this.url,
    this.height,
    this.width,
    this.fit
  });

  @override
  Widget build(BuildContext context) {

    if(url == null){
      return Image.asset(
        "assets/utils/Image-not-found.png",
        height: height,
        width: width,
        fit: fit,
      );
    }

    return Image.memory(
      url!,
      height: height,
      width: width,
      fit: fit,
    );

  }
}
