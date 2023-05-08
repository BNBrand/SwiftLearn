import 'package:flutter/material.dart';
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
              return AlertDialog(
                content: cachedNetworkImage(post.postImage),
                scrollable: true,
                contentPadding: EdgeInsets.zero,
              );
            }
        );
      },
      child: cachedNetworkImage(post.postImage),
    );
  }
}
