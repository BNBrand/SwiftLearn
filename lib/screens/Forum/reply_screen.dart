import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../utils/color.dart';
import '../more/profile/profile_screen.dart';

class ReplyScreen extends StatefulWidget {
  final String comments;
  final String commenterUid;
  final String commenterphotoURL;
  final String commenterdisplayName;
  final Timestamp createdAt;
  final int commentStars;
  final String postId;
  final String commentId;

  ReplyScreen({
    required this.createdAt,
    required this.comments,
    required this.commenterdisplayName,
    required this.commenterphotoURL,
    required this.commenterUid,
    required this.commentStars,
    required this.postId,
    required this.commentId,
});

  @override
  State<ReplyScreen> createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {

  TextEditingController replyController = TextEditingController();
  String replyId = const Uuid().v4();
  String displayNameUser = '';
  String photoURLUser = '';

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

  handleReply() async{
    await FirebaseFirestore.instance.collection('comments').doc(widget.postId)
        .collection('commentData').doc(widget.commentId).collection('repies').doc(replyId).set(
        {
          'reply' : replyController.text.trim(),
          'displayName' : displayNameUser,
          'photoURL' : photoURLUser,
          'repliedAt' : Timestamp.now(),
          'postId' : widget.postId,
          'uid' : FirebaseAuth.instance.currentUser!.uid,
          'replyStars': 0
        });
    await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update(
        {
          'comments': FieldValue.increment(1)
        });
    // await handleReplyFeed();
    replyId = const Uuid().v4();
    replyController.clear();
  }
  handleDeleteReply() async{
    await FirebaseFirestore.instance.collection('comments').doc(widget.postId)
        .collection('commentData').doc(widget.commentId)
        .collection('repies').doc(replyId).delete();
    await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update(
        {
          'comments': FieldValue.increment(-1)
        });
  }
  handleEditReply() async{
    await FirebaseFirestore.instance.collection('comments').doc(widget.postId)
        .collection('commentData').doc(widget.commentId)
        .collection('repies').doc(replyId).update(
        {
          'reply': replyController.text.trim()
        });
  }
  // handleReplyFeed() async{
  //   await FirebaseFirestore.instance.collection('feed').doc(widget.ownerId)
  //       .collection('feedData').doc(widget.postId)
  //       .set({
  //     'type': 'comment',
  //     'commentData': replyController.text.trim(),
  //     'displayName': displayNameUser,
  //     'photoURL': photoURLUser,
  //     'uid': FirebaseAuth.instance.currentUser!.uid,
  //     'postId': widget.postId,
  //     'createdAt': Timestamp.now(),
  //   });
  // }

  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Replies'),
        backgroundColor: CClass.bGColor2Theme(),
      ),
      body: Column(
        children: [
          Column(
            children: [
              ListTile(
                leading: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return ProfileScreen(profileId: widget.commenterUid,);
                    }));
                  },
                  child: CircleAvatar(
                    backgroundColor: CClass.containerColor,
                    backgroundImage: CachedNetworkImageProvider(widget.commenterphotoURL),
                  ),
                ),
                title: Text(widget.comments),
                subtitle: Text(timeago.format(widget.createdAt.toDate())),
                trailing: widget.commenterUid == FirebaseAuth.instance.currentUser!.uid ? IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.more_vert),
                ):
                null,
              ),
              TextButton.icon(
                onPressed: (){},
                icon : Icon(Icons.star,color: CClass.textColor2,),
                label: Text(widget.commentStars.toString(),style: TextStyle(color: CClass.textColorTheme()),),
              ),
               Divider(color: CClass.containerColor,thickness: 5,)
            ],
          ),
          Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('comments').doc(widget.postId)
                      .collection('commentData').doc(widget.commentId).collection('repies').orderBy('repliedAt', descending: false).snapshots(),
                builder: (context, snapshot) {
                    if(!snapshot.hasData){
                      return  Center(child: CircularProgressIndicator(color: CClass.bTColor2Theme(),));
                    }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, int index){
                     String reply = snapshot.data!.docs[index]['reply'];
                     Timestamp repliedAt = snapshot.data!.docs[index]['repliedAt'];
                     int replyStars = snapshot.data!.docs[index]['replyStars'];
                     String uid = snapshot.data!.docs[index]['uid'];
                     String photoURL = snapshot.data!.docs[index]['photoURL'];
                      return Column(
                        children: [
                          ListTile(
                            leading: GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context){
                                  return ProfileScreen(profileId: uid,);
                                }));
                              },
                              child: CircleAvatar(
                                backgroundColor: CClass.containerColor,
                                backgroundImage: CachedNetworkImageProvider(photoURL),
                              ),
                            ),
                            title: Text(reply),
                            subtitle: Text(timeago.format(repliedAt.toDate())),
                            trailing: uid == FirebaseAuth.instance.currentUser!.uid ? IconButton(
                              onPressed: (){},
                              icon: Icon(Icons.more_vert),
                            ):
                            null,
                          ),
                          TextButton.icon(
                              onPressed: (){},
                            icon : Icon(Icons.star,color: CClass.textColor2,),
                            label: Text(replyStars.toString(),style: TextStyle(color: CClass.textColorTheme()),),
                          ),
                          Divider(color: CClass.containerColor,)
                        ],
                      );
                    },
                  );
                }
              )
          ),
          Container(
            color: CClass.containerColor,
            child: ListTile(
              title: TextField(
                controller: replyController,
                decoration: InputDecoration(
                    hintText: 'Reply',
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                        icon : Icon(Icons.send,color: CClass.textColorTheme(),),
                        onPressed: (){
                          setState(() {
                            handleReply();
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
