import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../utils/color.dart';
import '../../more/profile/profile_screen.dart';

class ReplyScreen extends StatefulWidget {
  final String comments;
  final String commenterUid;
  final String commenterPhotoURL;
  final String commenterDisplayName;
  final Timestamp createdAt;
  final int commentStars;
  final String postId;
  final String commentId;

  ReplyScreen({
    required this.createdAt,
    required this.comments,
    required this.commenterDisplayName,
    required this.commenterPhotoURL,
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
        .collection('commentData').doc(widget.commentId).collection('replies').doc(replyId).set(
        {
          'reply' : replyController.text.trim(),
          'displayName' : displayNameUser,
          'photoURL' : photoURLUser,
          'repliedAt' : Timestamp.now(),
          'postId' : widget.postId,
          'replyId' : replyId,
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
  _handleStar() async{
    await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('commentStars').doc(widget.commentId).set({});
    await FirebaseFirestore.instance.collection('comments').doc(widget.postId).collection('commentData').doc(widget.commentId)
        .update({'commentStars': FieldValue.increment(1)});
    await FirebaseFirestore.instance.collection('users').doc(widget.commenterUid)
        .update({'totalStars': FieldValue.increment(1)});
  }
  _handleDeleteStar() async{
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('commentStars').doc(widget.commentId).get();
    if(snapshot.exists){
      await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('commentStars').doc(widget.commentId).delete();
      await FirebaseFirestore.instance.collection('comments').doc(widget.postId).collection('commentData').doc(widget.commentId)
          .update({'commentStars': FieldValue.increment(-1)});
      await FirebaseFirestore.instance.collection('users').doc(widget.commenterUid)
          .update({'totalStars': FieldValue.increment(-1)});
    }
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
          Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('comments').doc(widget.postId)
                      .collection('commentData').doc(widget.commentId).collection('replies').orderBy('repliedAt', descending: false).snapshots(),
                builder: (context, snapshot) {
                    if(!snapshot.hasData){
                      return  Column(
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
                                    backgroundImage: CachedNetworkImageProvider(widget.commenterPhotoURL),
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
                              StreamBuilder(
                                  stream: FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                                      .collection('commentStars').doc(widget.commentId).snapshots(),
                                  builder: (context, snapshot) {
                                    if(!snapshot.hasData){
                                      return TextButton.icon(
                                        onPressed: (){},
                                        icon : Icon(Icons.star,color: CClass.textColor2,),
                                        label: Text(widget.commentStars.toString(),style: TextStyle(color: CClass.textColorTheme()),),
                                      );
                                    }
                                    return snapshot.data!.exists ? TextButton.icon(
                                      onPressed: (){
                                        setState(() {
                                          _handleDeleteStar();
                                        });
                                      },
                                      icon : Icon(Icons.star,color: CClass.starColor,),
                                      label: Text(widget.commentStars.toString(),style: TextStyle(color: CClass.textColorTheme()),),
                                    ):
                                    TextButton.icon(
                                      onPressed: (){
                                        setState(() {
                                          _handleStar();
                                        });
                                      },
                                      icon : Icon(Icons.star,color: CClass.textColor2,),
                                      label: Text(widget.commentStars.toString(),style: TextStyle(color: CClass.textColorTheme()),),
                                    );
                                  }
                              ),
                              Divider(color: CClass.containerColor,thickness: 5,)
                            ],
                          ),
                          Expanded(child: Center(child: CircularProgressIndicator(color: CClass.bTColor2Theme(),))),
                        ],
                      );
                    }
                  return snapshot.data!.docs.isNotEmpty ? ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, int index){
                     String reply = snapshot.data!.docs[index]['reply'];
                     Timestamp repliedAt = snapshot.data!.docs[index]['repliedAt'];
                     int replyStars = snapshot.data!.docs[index]['replyStars'];
                     String uid = snapshot.data!.docs[index]['uid'];
                     String photoURL = snapshot.data!.docs[index]['photoURL'];
                     String replyID = snapshot.data!.docs[index]['replyId'];
                     deleteReply() async{
                       await FirebaseFirestore.instance.collection('comments').doc(widget.postId)
                           .collection('commentData').doc(widget.commentId).collection('replies')
                       .doc(replyID).delete();
                       await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update(
                           {
                             'comments': FieldValue.increment(-1)
                           });
                       await FirebaseFirestore.instance.collection('users').doc(uid)
                           .update({'totalStars': FieldValue.increment(-replyStars)});
                     }
                     handleStar() async{
                       await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                           .collection('replyStars').doc(replyID).set({});
                       await FirebaseFirestore.instance.collection('comments').doc(widget.postId).collection('commentData').doc(widget.commentId)
                       .collection('replies').doc(replyID)
                           .update({'replyStars': FieldValue.increment(1)});
                       await FirebaseFirestore.instance.collection('users').doc(uid)
                           .update({'totalStars': FieldValue.increment(1)});
                     }
                     handleDeleteStar() async{
                       DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                           .collection('replyStars').doc(replyID).get();
                       if(snapshot.exists){
                         await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                             .collection('replyStars').doc(replyID).delete();
                         await FirebaseFirestore.instance.collection('comments').doc(widget.postId).collection('commentData').doc(widget.commentId)
                             .collection('replies').doc(replyID)
                             .update({'replyStars': FieldValue.increment(-1)});
                         await FirebaseFirestore.instance.collection('users').doc(uid)
                             .update({'totalStars': FieldValue.increment(-1)});
                       }
                     }
                     void showDeleteDialog(){
                       showDialog(
                           context: context,
                           builder: (context){
                             return AlertDialog(
                                 backgroundColor: CClass.bGColorTheme(),
                                 title: Padding(
                                   padding: const EdgeInsets.all(8.0),
                                   child: const Text('Delete reply?',textAlign: TextAlign.center,),
                                 ),
                                 content: Padding(
                                   padding: const EdgeInsets.all(8.0),
                                   child: Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                     children: [
                                       InkWell(
                                           onTap: (){
                                             setState(() {
                                               deleteReply();
                                             });
                                             Navigator.pop(context);
                                           },
                                           child: Text('Yes',style: TextStyle(color: CClass.textColorTheme()),)),
                                       SizedBox(),
                                       InkWell(
                                           onTap: ()=> Navigator.pop(context),
                                           child: Text('No',style: TextStyle(color: CClass.textColorTheme()),))
                                     ],
                                   ),
                                 )
                             );
                           }
                       );
                     }
                      return Column(
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
                                    backgroundImage: CachedNetworkImageProvider(widget.commenterPhotoURL),
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
                              StreamBuilder(
                                  stream: FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                                      .collection('commentStars').doc(widget.commentId).snapshots(),
                                  builder: (context, snapshot) {
                                    if(!snapshot.hasData){
                                      return TextButton.icon(
                                        onPressed: (){},
                                        icon : Icon(Icons.star,color: CClass.textColor2,),
                                        label: Text(widget.commentStars.toString(),style: TextStyle(color: CClass.textColorTheme()),),
                                      );
                                    }
                                    return snapshot.data!.exists ? TextButton.icon(
                                      onPressed: (){
                                        setState(() {
                                          _handleDeleteStar();
                                        });
                                      },
                                      icon : Icon(Icons.star,color: CClass.starColor,),
                                      label: Text(widget.commentStars.toString(),style: TextStyle(color: CClass.textColorTheme()),),
                                    ):
                                    TextButton.icon(
                                      onPressed: (){
                                        setState(() {
                                          _handleStar();
                                        });
                                      },
                                      icon : Icon(Icons.star,color: CClass.textColor2,),
                                      label: Text(widget.commentStars.toString(),style: TextStyle(color: CClass.textColorTheme()),),
                                    );
                                  }
                              ),
                              Divider(color: CClass.containerColor,thickness: 5,)
                            ],
                          ),
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
                              onPressed: (){ showDeleteDialog(); },
                              icon: Icon(Icons.more_vert),
                            ):
                            null,
                          ),
                          StreamBuilder(
                              stream: FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('replyStars').doc(replyID).snapshots(),
                              builder: (context, snapshot) {
                                if(!snapshot.hasData){
                                  return TextButton.icon(
                                    onPressed: (){},
                                    icon : Icon(Icons.star,color: CClass.textColor2,),
                                    label: Text(replyStars.toString(),style: TextStyle(color: CClass.textColorTheme()),),
                                  );
                                }
                                return snapshot.data!.exists ? TextButton.icon(
                                  onPressed: (){
                                    setState(() {
                                      handleDeleteStar();
                                    });
                                  },
                                  icon : Icon(Icons.star,color: CClass.starColor,),
                                  label: Text(replyStars.toString(),style: TextStyle(color: CClass.textColorTheme()),),
                                ):
                                TextButton.icon(
                                  onPressed: (){
                                    setState(() {
                                      handleStar();
                                    });
                                  },
                                  icon : Icon(Icons.star,color: CClass.textColor2,),
                                  label: Text(replyStars.toString(),style: TextStyle(color: CClass.textColorTheme()),),
                                );
                              }
                          ),
                          Divider(color: CClass.containerColor,)
                        ],
                      );
                    },
                  ):
                  Column(
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
                                backgroundImage: CachedNetworkImageProvider(widget.commenterPhotoURL),
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
                          StreamBuilder(
                              stream: FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('commentStars').doc(widget.commentId).snapshots(),
                              builder: (context, snapshot) {
                                if(!snapshot.hasData){
                                  return TextButton.icon(
                                    onPressed: (){},
                                    icon : Icon(Icons.star,color: CClass.textColor2,),
                                    label: Text(widget.commentStars.toString(),style: TextStyle(color: CClass.textColorTheme()),),
                                  );
                                }
                                return snapshot.data!.exists ? TextButton.icon(
                                  onPressed: (){
                                    setState(() {
                                      _handleDeleteStar();
                                    });
                                  },
                                  icon : Icon(Icons.star,color: CClass.starColor,),
                                  label: Text(widget.commentStars.toString(),style: TextStyle(color: CClass.textColorTheme()),),
                                ):
                                TextButton.icon(
                                  onPressed: (){
                                    setState(() {
                                      _handleStar();
                                    });
                                  },
                                  icon : Icon(Icons.star,color: CClass.textColor2,),
                                  label: Text(widget.commentStars.toString(),style: TextStyle(color: CClass.textColorTheme()),),
                                );
                              }
                          ),
                          Divider(color: CClass.containerColor,thickness: 5,)
                        ],
                      ),
                      Expanded(child: Center(child: Text('No replies yet'))),
                    ],
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
