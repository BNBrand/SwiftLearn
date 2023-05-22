import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:swift_learn/models/post_model.dart';
import 'package:swift_learn/widgets/loading_image.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile({required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        showDialog(
            context: context,
            builder: (context){
              return PhotoView(
                imageProvider: CachedNetworkImageProvider(post.postImage),
              );
            }
        );
      },
      child: cachedNetworkImage(post.postImage),
    );
  }
}
