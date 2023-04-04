import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/models/user_model.dart';
import 'package:swift_learn/screens/more/profile/profile_screen.dart';

import '../utils/colors.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String caption;
  final String email;
  final String photoURL;
  final String displayName;
  final String postImage;
  final dynamic stars;

  Post({
    required this.postImage,
    required this.ownerId,
    required this.email,
    required this.photoURL,
    required this.postId,
    required this.caption,
    required this.stars,
    required this.displayName
  });

  factory  Post.fromDocument(DocumentSnapshot doc){
    return Post(
      ownerId: doc['ownerId'],
      postImage: doc['postImage'],
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
    postImage: postImage,
    ownerId: ownerId,
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
  final String ownerId;
  final String caption;
  final String email;
  final String photoURL;
  final String displayName;
  final String postImage;
  int likeCount;
  Map stars;
  bool isStarred = false;
  int starCount = 0;

  _PostState({
    required this.postImage,
    required this.ownerId,
    required this.email,
    required this.photoURL,
    required this.postId,
    required this.caption,
    required this.stars,
    required this.displayName,
    required this.likeCount,
  });

  // handleStarPost(){
  //  bool _isStarred = stars[FirebaseAuth.instance.currentUser!.uid] == true;
  //
  //  if(_isStarred){
  //    FirebaseFirestore.instance.collection('posts').doc(DateTime.now().millisecondsSinceEpoch.toString()).update({
  //      'stars.${FirebaseAuth.instance.currentUser!.uid}': false
  //    });
  //    setState(() {
  //      likeCount -=1;
  //      isStarred = false;
  //      stars[ownerId] == false;
  //    });
  //  }else if(!_isStarred){
  //    FirebaseFirestore.instance.collection('posts')
  //        .doc(DateTime.now().millisecondsSinceEpoch.toString()).update({
  //      'stars.${FirebaseAuth.instance.currentUser!.uid}': true
  //    });
  //    setState(() {
  //      likeCount +=1;
  //      isStarred = true;
  //      stars[ownerId] == true;
  //    });
  //  }
  // }
  handleStarPost() async{
    isStarred = true;
    await FirebaseFirestore.instance.collection('posts').doc(DateTime.now().millisecondsSinceEpoch.toString())
        .collection('stars').doc(FirebaseAuth.instance.currentUser!.uid).
    set({
      'star' : isStarred
    });
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('posts').where('postId', isEqualTo: postId).get();
    setState(() {
      starCount = snapshot.docs.length;
    });
  }
  handleStarPostCount() async{
    if(isStarred){
      await handleStarPost();
      setState(() {
        isStarred = true;
      });
    }else{
      await  FirebaseFirestore.instance.collection('posts').doc(DateTime.now().millisecondsSinceEpoch.toString())
          .collection('stars').doc(FirebaseAuth.instance.currentUser!.uid).delete();
      setState(() {
        isStarred = false;
      });
    }
  }

  buildPostHeader(){
        return FutureBuilder(
            future: FirebaseFirestore.instance.collection('users').doc(ownerId).get(),
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(color: buttonColor2,));
              }
              Users user = Users.fromDocument(snapshot.data!);
            return ListTile(
              leading: GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return ProfileScreen(profileId: ownerId,);
                  }));
                },
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(user.photoURL),
                ),
              ),
              title: Text(user.displayName,overflow: TextOverflow.ellipsis,),
              subtitle: Text(user.email,overflow: TextOverflow.ellipsis,),
              trailing: IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: (){},
              ),
            );
          }
        );
  }
  buildCaption(){
    return Text(caption);
  }
  buildPostImage(){
    return GestureDetector(
          onTap: (){},
          onLongPress: handleStarPost,
          child: Container(
            height: 250.0,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(postImage),
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
                Text('$starCount Stars'),
                Text('$comments Comments')
              ],
            ),
          ),
          SizedBox(height: 5.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: handleStarPostCount,
                  icon: Icon(Icons.star,
                  color: isStarred ? starColor : textColor1,
                  )
              ),
              IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.comment,color: buttonColor2,)
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
    isStarred = (stars[ownerId] == true);
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
