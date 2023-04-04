import 'package:flutter/material.dart';
import 'package:swift_learn/utils/colors.dart';

import '../../widgets/loading_image.dart';

class ImageView extends StatefulWidget {
  final String postImage;
  final Function buildPostFooter;

  ImageView({required this.buildPostFooter,required this.postImage});

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor2,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              cachedNetworkImage(widget.postImage),
              widget.buildPostFooter()
            ],
          ),
        ),
      ),
    );

  }
}
