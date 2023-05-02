
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/models/user_model.dart';
import 'package:swift_learn/screens/Forum/comments.dart';
import 'package:swift_learn/screens/Forum/image_view.dart';
import 'package:swift_learn/screens/more/profile/profile_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../utils/colors.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String caption;
  final String email;
  final String photoURL;
  final String displayName;
  final String postImage;
  final Timestamp createdAt;
  final int stars;
  final int comments;

  Post({
    required this.postImage,
    required this.ownerId,
    required this.email,
    required this.photoURL,
    required this.postId,
    required this.caption,
    required this.stars,
    required this.displayName,
    required this.comments,
    required this.createdAt
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
      comments: doc['comments'],
      createdAt: doc['createdAt'],
    );
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
    data: {},
    comments: comments,
    createdAt: createdAt,
  );
}

class _PostState extends State<Post> {

  final String postId;
  final Timestamp createdAt;
  final String ownerId;
  final String caption;
  final String email;
  final String photoURL;
  final String displayName;
  final String postImage;
  final int stars;
  final int comments;
  Map <String, dynamic> data;
  String? displayNameUser;
  String? photoURLUser;
  int currentStars = 0;
  int currentComments = 0;

  _PostState({
    required this.createdAt,
    required this.postImage,
    required this.ownerId,
    required this.email,
    required this.photoURL,
    required this.postId,
    required this.caption,
    required this.data,
    required this.displayName,
    required this.stars,
    required this.comments
  });

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
    await FirebaseFirestore.instance.collection('posts').doc(postId)
        .get().then((snapshot) async{
      if(snapshot.exists){
        setState(() {
          currentStars = snapshot.data()!['stars'];
          currentComments = snapshot.data()!['comments'];
        });
      }
    });
  }
  handleStarFeed() async{
    await FirebaseFirestore.instance.collection('feed').doc(ownerId)
        .collection('feedData').doc(postId)
        .set({
      'type': 'star',
      'displayName': displayNameUser,
      'photoURL': photoURLUser,
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'postId': postId,
      'createdAt': Timestamp.now(),
      'postImage': postImage
    });
  }
  handleUnStarFeed() async {
    await FirebaseFirestore.instance.collection('feed').doc(ownerId)
        .collection('feedData').doc(postId).delete();
  }
  handleStar() async{
   await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
    .get().then((value) => {
      if(value.data() != null){
        if(value.data()!.keys.contains(postId)){
          FirebaseFirestore.instance.runTransaction((Transaction tx) async{
            DocumentSnapshot postSnapshot = await tx.get(FirebaseFirestore.instance.collection('posts').doc(postId));
            if(postSnapshot.exists){
              await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({postId: FieldValue.delete()});

            FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid).get()
                .then((value) => data = value.data()!);

                tx.update(FirebaseFirestore.instance.collection('posts').doc(postId), <String, dynamic>{
                  'stars': FieldValue.increment(-1)
              });
              tx.update(FirebaseFirestore.instance.collection('users').doc(ownerId), <String, dynamic>{
                'totalStars': FieldValue.increment(-1)
              });
              handleUnStarFeed();
            }
          }),
        }else{
          FirebaseFirestore.instance.runTransaction((tx) async{
            DocumentSnapshot postSnapshot = await tx.get(FirebaseFirestore.instance.collection('posts').doc(postId));
            if(postSnapshot.exists){
             await  FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({postId: true});
            setState((){
            FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid).get()
                .then((value) => data = value.data()!);
            });

                 tx.update(FirebaseFirestore.instance.collection('posts').doc(postId), <String, dynamic>{
                   'stars': FieldValue.increment(1)

               });
             tx.update(FirebaseFirestore.instance.collection('users').doc(ownerId), <String, dynamic>{
               'totalStars': FieldValue.increment(1)
             });
             handleStarFeed();
            }
          }),
        }
      }else{
        FirebaseFirestore.instance.runTransaction((tx) async{
          DocumentSnapshot postSnapshot = await tx.get(FirebaseFirestore.instance.collection('posts').doc(postId));
          if(postSnapshot.exists){
            await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                .set({postId: true});

          FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid).get()
              .then((value) => data = value.data()!);

               tx.update(FirebaseFirestore.instance.collection('posts').doc(postId), <String, dynamic>{
                 'stars': FieldValue.increment(1)

             });
            tx.update(FirebaseFirestore.instance.collection('users').doc(ownerId), <String, dynamic>{
              'totalStars': FieldValue.increment(1)
            });
            handleStarFeed();
          }
        }),
      }
    });
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
              subtitle: Text(timeago.format(createdAt.toDate())),
              trailing: IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: (){},
              ),
            );
          }
        );
  }
  buildCaption(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(caption),
        SizedBox(height: 5.0,)
      ],
    );
  }
  buildPostImage(){
    return InkWell(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return ImageView(buildPostFooter: buildPostFooter, postImage: postImage);
            }));
          },
          onDoubleTap: (){
              setState(() {
                handleStar();
              });
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
                Text('$currentStars Stars'),
                Text('$currentComments Comments')
              ],
            ),
          ),
          SizedBox(height: 5.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: (){
                    setState(() {
                      handleStar();
                    });
                  },
                  icon:
                  Icon(Icons.star,
                  color: data.containsKey(postId)? starColor : textColor1,
                  )
              ),
              IconButton(
                  onPressed: ()=> showComments(
                      context,
                      postId: postId,
                      postImage: postImage,
                      ownerId: ownerId
                    ),

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
  void initState() {
    _getData();
     FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid);
     FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid).get()
         .then((value) => data = value.data()!);
    super.initState();
  }

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
