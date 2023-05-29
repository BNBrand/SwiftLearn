import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:swift_learn/screens/Forum/social_media/comments.dart';
import 'package:swift_learn/screens/more/profile/profile_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../models/user_model.dart';
import '../../../utils/color.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {

  showComments(BuildContext context, { required String postId, required String ownerId, required String postImage}){
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return Comments(
          postId: postId,
          postImage: postImage,
          ownerId: ownerId
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.4,),
                Center(child: CircularProgressIndicator(color: CClass.bTColor2Theme(),)),
              ],
            );
          }
          return snapshot.data!.docs.isNotEmpty ? ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, int index){
                Timestamp createdAt = snapshot.data!.docs[index]['createdAt'];
                String postID = snapshot.data!.docs[index]['postId'];
                int stars = snapshot.data!.docs[index]['stars'];
                int comments = snapshot.data!.docs[index]['comments'];
                String ownerID = snapshot.data!.docs[index]['ownerId'];
                String caption = snapshot.data!.docs[index]['caption'];
                String postImage = snapshot.data!.docs[index]['postImage'];
                deletePost() async{
                  try{
                    await FirebaseFirestore.instance.collection('posts').doc(postID).delete();
                    await FirebaseStorage.instance.ref().child('postImages').child('post_$postID.jpg').delete();
                    DocumentSnapshot postSnapshot = await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('postStars').doc(postID).get();
                    if(postSnapshot.exists){
                      await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('postStars').doc(postID)
                          .update({postID: FieldValue.delete()});
                    }

                    await FirebaseFirestore.instance.collection('users').doc(ownerID)
                        .update({'totalStars': FieldValue.increment(-stars)});
                  }catch(e){
                    print(e.toString());
                  }
                }
                handleStar() async{
                  await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('postStars').doc(postID).set({});
                  FirebaseFirestore.instance.collection('posts').doc(postID)
                      .update({'stars': FieldValue.increment(1)});
                  await FirebaseFirestore.instance.collection('users').doc(ownerID)
                      .update({'totalStars': FieldValue.increment(1)});
                }
                handleDeleteStar() async{
                  DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('postStars').doc(postID).get();
                  if(snapshot.exists){
                    await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('postStars').doc(postID).delete();
                    await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('postStars').doc(postID).delete();
                    FirebaseFirestore.instance.collection('posts').doc(postID)
                        .update({'stars': FieldValue.increment(-1)});
                    await FirebaseFirestore.instance.collection('users').doc(ownerID)
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
                              child: const Text('Delete post?',textAlign: TextAlign.center,),
                            ),
                            content: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                      onTap: (){
                                        setState(() {
                                          deletePost();
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
                        StreamBuilder(
                            stream: FirebaseFirestore.instance.collection('users').doc(ownerID).snapshots(),
                            builder: (context, snapshot) {

                              if (!snapshot.hasData) {
                                return Center(child: CircularProgressIndicator(color: CClass.bTColorTheme(),));
                              }
                              Users user = Users.fromDocument(snapshot.data!);
                              return ListTile(
                                leading: GestureDetector(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context){
                                      return ProfileScreen(profileId: ownerID,);
                                    }));
                                  },
                                  child: CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(user.photoURL),
                                  ),
                                ),
                                title: Text(user.displayName,overflow: TextOverflow.ellipsis,),
                                subtitle: Text(timeago.format(createdAt.toDate())),
                                trailing: FirebaseAuth.instance.currentUser!.uid != ownerID ? null
                                    : IconButton(
                                  icon: Icon(Icons.delete,color: CClass.buttonColor2,),
                                  onPressed: showDeleteDialog,
                                ),
                              );
                            }
                        ),
                        Text(caption),
                      ],
                    ),

                    const SizedBox(height: 5.0,),
                    InkWell(
                      onTap: (){
                        showDialog(
                            context: context,
                            builder: (context){
                              return PhotoView(
                                imageProvider: CachedNetworkImageProvider(postImage),
                              );
                            }
                        );
                      },
                      child: Container(
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
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 3.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('$stars Stars'),
                                Text('$comments Comments')
                              ],
                            ),
                          ),
                          SizedBox(height: 5.0,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              StreamBuilder(
                                  stream: FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                                      .collection('postStars').doc(postID).snapshots(),
                                  builder: (context, snapshot) {
                                    if(!snapshot.hasData){
                                      return IconButton(
                                        onPressed: (){},
                                        icon : Icon(Icons.star,color: CClass.textColor2,),
                                      );
                                    }
                                    return snapshot.data!.exists ? IconButton(
                                        onPressed: (){
                                          setState(() {
                                            handleDeleteStar();
                                          });
                                        },
                                        icon : Icon(Icons.star,color: CClass.starColor,)
                                    ):
                                    IconButton(
                                        onPressed: (){
                                          setState(() {
                                            handleStar();
                                          });
                                        },
                                        icon : Icon(Icons.star,color: CClass.textColor2,)
                                    );
                                  }
                              ),
                              IconButton(
                                  onPressed: ()=> showComments(
                                      context,
                                      postId: postID,
                                      postImage: postImage,
                                      ownerId: ownerID
                                  ),

                                  icon: Icon(Icons.comment,color: CClass.buttonColor2,)
                              )
                            ],
                          ),
                          Divider(
                            thickness: 5,
                          )
                        ],
                      ),
                    )
                  ],
                );
              }
          ):
          const Center(child: Text('No post yet, Add a post'));
        }
    );
  }
}