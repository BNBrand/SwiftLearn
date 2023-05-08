import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/color.dart';

Widget cachedNetworkImage(postImage){
  return CachedNetworkImage(
      imageUrl: postImage,
    fit: BoxFit.cover,
    placeholder: (context, url) => Center(
        child: CircularProgressIndicator(color: CClass.bTColor2Theme(),)
    ),
    errorWidget: (context, url, error) => const Icon(Icons.error),
  );
}