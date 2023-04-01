import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/utils/colors.dart';

Widget cachedNetworkImage(postImage){
  return CachedNetworkImage(
      imageUrl: postImage,
    fit: BoxFit.cover,
    placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(color: buttonColor2,)
    ),
    errorWidget: (context, url, error) => const Icon(Icons.error),
  );
}