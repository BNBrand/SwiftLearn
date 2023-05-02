import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/screens/more/profile/profile_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../utils/colors.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String postImage;
  final String ownerId;

  Comments({
    required this.ownerId,
    required this.postImage,
    required this.postId
});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {

  bool isCommented = true;
  String? displayNameUser = '';
  String? photoURLUser = '';
  String? commentId = Uuid().v4();

  Future _getData() async{
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then((snapshot) async{
      if(snapshot.exists){
        setState(() {
          displayNameUser = snapshot.data()!['displayName'];
          photoURLUser = snapshot.data()!['photoURL'];
        });
      }
    });
  }

  TextEditingController commentController = TextEditingController();

  handleComment() async{
    await FirebaseFirestore.instance.collection('comments').doc(widget.postId)
        .collection('commentData').doc(commentId).set(
        {
          'comment' : commentController.text.trim(),
          'displayName' : displayNameUser,
          'photoURL' : photoURLUser,
          'createdAt' : Timestamp.now(),
          'postId' : widget.postId,
          'uid' : FirebaseAuth.instance.currentUser!.uid
        });
    await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update(
        {
          'comments': FieldValue.increment(1)
        });
    await handleCommentFeed();
    commentController.clear();
  }
  handleCommentFeed() async{
    await FirebaseFirestore.instance.collection('feed').doc(widget.ownerId)
        .collection('feedData').doc(widget.postId)
        .set({
      'type': 'comment',
      'commentData': commentController.text.trim(),
      'displayName': displayNameUser,
      'photoURL': photoURLUser,
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'postId': widget.postId,
      'createdAt': Timestamp.now(),
      'postImage': widget.postImage
    });
  }

  postComment(){
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('comments').doc(widget.postId)
            .collection('commentData').orderBy('createdAt', descending: false).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: buttonColor2,));
          }
          List<Comment> comments = [];
          snapshot.data!.docs.forEach((doc) {
            comments.add(Comment.fromDocument(doc));
          });
          return ListView(children: comments,);
        }
    );
  }

  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: backgroundColor2,
        title: Text('Comments'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: postComment()),
          Divider(),
          Container(
            color: secondaryBackgroundColor,
            child: ListTile(
              title: TextField(
                controller: commentController,
                decoration: InputDecoration(
                    hintText: 'Comment',
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                        icon : Icon(Icons.send,color: textColor1,),
                        onPressed: (){
                          setState(() {
                            handleComment();
                          });
                        }
                    )
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}


class Comment extends StatelessWidget {
  final String postId;
  Timestamp createdAt;
  String comment;
  String photoURL;
  String displayName;

  Comment({
    required this.postId,
    required this.comment,
    required this.createdAt,
    required this.photoURL,
    required this.displayName
  });

  factory Comment.fromDocument(DocumentSnapshot doc){
    return Comment(
        postId: doc['postId'],
        comment: doc['comment'],
        createdAt: doc['createdAt'],
        photoURL: doc['photoURL'],
        displayName: doc['displayName']
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return ProfileScreen(profileId: FirebaseAuth.instance.currentUser!.uid,);
              }));
            },
            child: CircleAvatar(
              backgroundColor: containerColor,
              backgroundImage: CachedNetworkImageProvider(photoURL),
            ),
          ),
          title: Text(comment),
          subtitle: Text(timeago.format(createdAt.toDate())),
        ),
        Divider()
      ],
    );
  }
}
