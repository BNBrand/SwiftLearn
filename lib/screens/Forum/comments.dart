import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/screens/Forum/reply_screen.dart';
import 'package:swift_learn/screens/more/profile/profile_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../utils/color.dart';

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
  bool? isOwner;
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
          'uid' : FirebaseAuth.instance.currentUser!.uid,
          'commentStars': 0,
          'commentId': commentId
        });
    await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update(
        {
          'comments': FieldValue.increment(1)
        });
    await handleCommentFeed();
    commentId = const Uuid().v4();
    commentController.clear();
  }
  handleDeleteComment() async{
    await FirebaseFirestore.instance.collection('comments').doc(widget.postId)
        .collection('commentData').doc(commentId).delete();
    await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update(
        {
          'comments': FieldValue.increment(-1)
        });
  }
  handleEditComment() async{
    await FirebaseFirestore.instance.collection('comments').doc(widget.postId)
        .collection('commentData').doc(commentId).update(
        {
          'comment': commentController.text.trim()
        });
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
            return Center(child: CircularProgressIndicator(color: CClass.bTColor2Theme(),));
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
        backgroundColor: CClass.bGColor2Theme(),
        title: Text('Comments'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: postComment()),
          Divider(),
          Container(
            color: CClass.containerColor,
            child: ListTile(
              title: TextField(
                controller: commentController,
                decoration: InputDecoration(
                    hintText: 'Comment',
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                        icon : Icon(Icons.send,color: CClass.textColorTheme(),),
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


class Comment extends StatefulWidget {
  final String postId;
  Timestamp createdAt;
  String comment;
  String photoURL;
  String displayName;
  String uid;
  int commentStars;
  String commentId;
  Map <String, dynamic> data;

  Comment({
    required this.postId,
    required this.comment,
    required this.createdAt,
    required this.photoURL,
    required this.displayName,
    required this.uid,
    required this.commentStars,
    required this.commentId,
    required this.data,
  });

  factory Comment.fromDocument(DocumentSnapshot doc){
    return Comment(
      postId: doc['postId'],
      comment: doc['comment'],
      createdAt: doc['createdAt'],
      photoURL: doc['photoURL'],
      displayName: doc['displayName'],
      uid: doc['uid'],
      commentStars: doc['commentStars'],
      commentId: doc['commentId'],
      data: {},
    );
  }

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {

bool boolValue = false;
  handleStar() async{
    await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('commentStars').doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then((value) => {
      if(value.data() != null){
        if(value.data()!.keys.contains(widget.commentId)){
          FirebaseFirestore.instance.runTransaction((Transaction tx) async{
            DocumentSnapshot postSnapshot = await tx.get(FirebaseFirestore.instance.collection('comments').doc(widget.postId)
                .collection('commentData').doc(widget.commentId));
            if(postSnapshot.exists){
              await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('commentStars').doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({widget.commentId: false});

              FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('commentStars').doc(FirebaseAuth.instance.currentUser!.uid)
                  .get().then((value) => widget.data = value.data()!);

              tx.update(FirebaseFirestore.instance.collection('comments').doc(widget.postId)
                  .collection('commentData').doc(widget.commentId), <String, dynamic>{
                'commentStars': FieldValue.increment(-1)
              });
              tx.update(FirebaseFirestore.instance.collection('users').doc(widget.uid), <String, dynamic>{
                'totalStars': FieldValue.increment(-1)
              });
              // handleUnStarCommentFeed();
            }
          }),
        }else{
          FirebaseFirestore.instance.runTransaction((tx) async{
            DocumentSnapshot postSnapshot = await tx.get(FirebaseFirestore.instance.collection('comments').doc(widget.postId)
                .collection('commentData').doc(widget.commentId));
            if(postSnapshot.exists){
              await  FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('commentStars').doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({widget.commentId: true});
              setState((){
                FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('commentStars').doc(FirebaseAuth.instance.currentUser!.uid)
                    .get().then((value) => widget.data = value.data()!);
              });

              tx.update(FirebaseFirestore.instance.collection('comments').doc(widget.postId)
                  .collection('commentData').doc(widget.commentId), <String, dynamic>{
                'commentStars': FieldValue.increment(1)

              });
              tx.update(FirebaseFirestore.instance.collection('users').doc(widget.uid), <String, dynamic>{
                'totalStars': FieldValue.increment(1)
              });
              // handleStarCommentFeed();
            }
          }),
        }
      }else{
        FirebaseFirestore.instance.runTransaction((tx) async{
          DocumentSnapshot postSnapshot = await tx.get(FirebaseFirestore.instance.collection('comments').doc(widget.postId)
              .collection('commentData').doc(widget.commentId));
          if(postSnapshot.exists){
            await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('commentStars').doc(FirebaseAuth.instance.currentUser!.uid)
                .set({widget.commentId: true});

            FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('commentStars').doc(FirebaseAuth.instance.currentUser!.uid).get()
                .then((value) => widget.data = value.data()!);

            tx.update(FirebaseFirestore.instance.collection('comments').doc(widget.postId)
                .collection('commentData').doc(widget.commentId), <String, dynamic>{
              'commentStars': FieldValue.increment(1)

            });
            tx.update(FirebaseFirestore.instance.collection('users').doc(widget.uid), <String, dynamic>{
              'totalStars': FieldValue.increment(1)
            });
            // handleStarCommentFeed();
          }
        }),
      }
    });
  }
  Future _getData() async{
    await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('commentStars').doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then((snapshot) async{
      if(snapshot.exists){
        setState(() {
          boolValue = snapshot.data()![widget.commentId];
        });
      }
    });
  }

void initState() {
    _getData();
  FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('commentStars').doc(FirebaseAuth.instance.currentUser!.uid);
  super.initState();
}

  @override
  Widget build(BuildContext context) {
    _getData();
    return Column(
      children: [
        ListTile(
          leading: GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return ProfileScreen(profileId: widget.uid,);
              }));
            },
            child: CircleAvatar(
              backgroundColor: CClass.containerColor,
              backgroundImage: CachedNetworkImageProvider(widget.photoURL),
            ),
          ),
          title: Text(widget.comment),
          subtitle: Text(timeago.format(widget.createdAt.toDate())),
          trailing: widget.uid == FirebaseAuth.instance.currentUser!.uid ? IconButton(
            onPressed: (){},
            icon: Icon(Icons.more_vert),
          ):
          null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
                onPressed: (){
                  setState(() {
                    handleStar();
                  });
                },
              icon : Icon(Icons.star,color: boolValue ? CClass.starColor : CClass.textColor2,),
              label: Text(widget.commentStars.toString(),style: TextStyle(color: CClass.textColorTheme()),),
            ),
            TextButton.icon(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return ReplyScreen(
                      createdAt: widget.createdAt,
                      comments: widget.comment,
                      commenterdisplayName: widget.displayName,
                      commenterphotoURL: widget.photoURL,
                      commenterUid: widget.uid,
                      commentStars: widget.commentStars,
                      postId: widget.postId,
                      commentId: widget.commentId,
                  );
                }));
              },
              icon : Icon(Icons.reply,color: CClass.textColorTheme(),),
              label: Text('Reply',style: TextStyle(color: CClass.textColorTheme()),),
              )
          ],
        ),
         Divider(color: CClass.containerColor,)
      ],
    );
  }
}