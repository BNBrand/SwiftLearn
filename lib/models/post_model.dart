import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../utils/colors.dart';
import '../utils/utils.dart';

class Post extends StatefulWidget {
  final String postId;
  final String uid;
  final String caption;
  final String email;
  final String photoURL;
  final String displayName;
  final String postImange;
  final dynamic stars;

  Post({
    required this.postImange,
    required this.uid,
    required this.email,
    required this.photoURL,
    required this.postId,
    required this.caption,
    required this.stars,
    required this.displayName
  });

  factory  Post.fromDocument(DocumentSnapshot doc){
    return Post(
      uid: FirebaseAuth.instance.currentUser!.uid,
      postImange: doc['postImage'],
      postId: doc['postId'],
      displayName: doc['displayName'],
      photoURL: doc['photoURL'],
      email: doc['email'],
      caption: doc['caption'],
      stars: doc['stars'],
    );
  }

  int getLikeCount(stars){
    if(stars == null){
      return 0;
    }
    int count = 0;
    stars.values.forEach((val){
      if(val == true){
        count +=1;
      }
    });
    return count;
  }

  @override
  State<Post> createState() => _PostState(
    postId: postId,
    postImange: postImange,
    uid: uid,
    photoURL: photoURL,
    displayName: displayName,
    caption: caption,
    email: email,
    stars: stars,
    likeCount: getLikeCount(stars),
  );
}

class _PostState extends State<Post> {

  final String postId;
  final String uid;
  final String caption;
  final String email;
  final String photoURL;
  final String displayName;
  final String postImange;
  int likeCount;
  Map stars;

  _PostState({
    required this.postImange,
    required this.uid,
    required this.email,
    required this.photoURL,
    required this.postId,
    required this.caption,
    required this.stars,
    required this.displayName,
    required this.likeCount,
  });

  buildPostHeader(){
    return FutureBuilder(
        future: FirebaseFirestore.instance.collection('posts').doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('userPost').doc(Uuid().v4()).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error loading caption');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: buttonColor2,));
          }
        return ListTile(
          leading: GestureDetector(
            onTap: (){},
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(photoURL),
            ),
          ),
          title: Text(displayName,overflow: TextOverflow.ellipsis,),
          subtitle: Text(email,overflow: TextOverflow.ellipsis,),
          trailing: IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: (){},
          ),
        );
      }
    );
  }
  buildCaption(){
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Text(caption),
    );
  }
  buildPostImage(){
    return GestureDetector(
          onTap: (){},
          onLongPress: (){},
          child: Container(
            height: 250.0,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(postImange),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
  }
  buildPostFooter(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$likeCount Stars'),
                Text('$comments Comments')
              ],
            ),
          ),
          SizedBox(height: 5.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.star)
              ),
              IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.comment)
              )
            ],
          ),
          Divider(
            thickness: 5,
          )
        ],
      ),
    );
  }

  int comments = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          buildPostHeader(),
          buildCaption(),
          buildPostImage(),
          buildPostFooter(),
        ],
      ),
    );
  }
}
