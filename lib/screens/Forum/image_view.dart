import 'package:flutter/material.dart';

import '../../utils/color.dart';
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
        backgroundColor: CClass.bGColor2Theme(),
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
