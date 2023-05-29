import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/models/post_model.dart';
import 'package:swift_learn/screens/more/profile/edit_profile.dart';
import 'package:swift_learn/widgets/post_tile.dart';
import 'package:intl/intl.dart';
import '../../../models/user_model.dart';
import '../../../utils/color.dart';
import '../../../widgets/loading_image.dart';
import 'followers.dart';
import 'following.dart';

class ProfileScreen extends StatefulWidget {

  final String profileId;

  ProfileScreen({required this.profileId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  bool selectedGrid = true;
  bool isFollowing = false;
  bool isLoading = false;
  int postCount = 0;
  int starCount = 0;
  bool isDetails = false;
  String displayNameUser = '';
  String photoURLUser = '';
  String displayName = '';
  String photoURL = '';
  List<Post> posts = [];

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
    await FirebaseFirestore.instance.collection('users').doc(widget.profileId)
        .get().then((snapshot) async{
      if(snapshot.exists){
        setState(() {
          displayName = snapshot.data()!['displayName'];
          photoURL = snapshot.data()!['photoURL'];
        });
      }
    });
    await FirebaseFirestore.instance.collection('followers').doc(widget.profileId)
        .collection('userFollowers').doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then((snapshot) {
      if(snapshot.exists){
        setState(() {
          isFollowing = snapshot.exists;
        });
      }
    });
  }
  gridViewPost(){
    selectedGrid = true;
    if(isLoading){
      return Center(child: CircularProgressIndicator(color: CClass.bTColor2Theme(),));
    }
    List<GridTile> gridTiles = [];
    posts.forEach((post) {
      gridTiles.add(GridTile(
          child: PostTile(post: post,)
      ));
    });
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.0,
      mainAxisSpacing: 1.5,
      crossAxisSpacing: 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: gridTiles,
    );
  }
  selectedView(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
            onPressed: (){
              setState(() {
                selectedGrid = true;
              });
            },
            icon: Icon(Icons.grid_on,
            size: selectedGrid ? 25 : 18,
            color: selectedGrid ? CClass.textColorTheme() : CClass.textColor2,
            )
        ),
        IconButton(
            onPressed: (){
              setState(() {
                selectedGrid = false;
              });
            },
            icon: Icon(Icons.list,
            size: selectedGrid ? 18 : 25,
            color: selectedGrid ? CClass.textColor2 : CClass.textColorTheme(),
            )
        )
      ],
    );
  }
  countColumn(String label, int count){
    return Column(
      children: [
        Text(count.toString(),
        style: const TextStyle(fontSize: 20,
        fontWeight: FontWeight.w600
        ),
        ),
        Text(label)
      ],
    );
  }
  profileContent() async{
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('posts').where('ownerId', isEqualTo: widget.profileId).orderBy('createdAt', descending: true).get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }
  listViewPost(){
    selectedGrid = false;
      if(isLoading) {
        return Center(child: CircularProgressIndicator(color: CClass.bTColor2Theme(),));
      }
      return Column(children: posts,);
  }
  _handleFollow() async{
    setState(() {
      isFollowing = true;
    });
    await FirebaseFirestore.instance.collection('followers').doc(widget.profileId)
        .collection('userFollowers').doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
          'ownerId': FirebaseAuth.instance.currentUser!.uid,
          'followedAt': DateFormat.yMMMMd().add_jms().format(DateTime.now()),
    });
    await FirebaseFirestore.instance.collection('following').doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('userFollowing').doc(widget.profileId)
        .set({
          'ownerId': widget.profileId,
          'followedAt': DateFormat.yMMMMd().add_jms().format(DateTime.now()),
    });
    await FirebaseFirestore.instance.collection('feed').doc(widget.profileId)
        .collection('feedItems').doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
          'type':'follow',
          'uid':FirebaseAuth.instance.currentUser!.uid,
          'ownerId': widget.profileId,
          'displayName': displayNameUser,
          'photoURL': photoURLUser,
          'followedAt': Timestamp.now(),
        });
    _getData();
  }
  _handleUnfollow() async{
    setState(() {
      isFollowing = false;
    });
    await FirebaseFirestore.instance.collection('followers').doc(widget.profileId)
        .collection('userFollowers').doc(FirebaseAuth.instance.currentUser!.uid)
        .delete();
    await FirebaseFirestore.instance.collection('following').doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('userFollowing').doc(widget.profileId)
        .delete();
    await FirebaseFirestore.instance.collection('feed').doc(widget.profileId)
        .collection('feedItems').doc(FirebaseAuth.instance.currentUser!.uid)
        .delete();
    _getData();
  }
  profileHeader() {
    return FutureBuilder(
        future: FirebaseFirestore.instance.collection('users').doc(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
                height: 400,
                child: Center(child: CircularProgressIndicator(color: CClass.buttonColor2,)));
          }
          Users user = Users.fromDocument(snapshot.data!);
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: isDetails ? 700 : 450,
                  color: CClass.backgroundColor,
                  child: LayoutBuilder(builder: (context, constraints){
                    double innerHeight = constraints.maxHeight;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              Container(height: 70,),
                              Container(
                                height: isDetails ? innerHeight * 0.9 : innerHeight * 0.85,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: CClass.secondaryBGColorTheme(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Container(height: 70,),
                                          Row(
                                            children: [
                                              Icon(Icons.star,color: CClass.starColor,),
                                              Text('${user.totalStars.toString()} Stars',style: TextStyle(color: CClass.textColorTheme()),),
                                            ],
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: (){
                                          showDialog(
                                              context: context,
                                              builder: (context){
                                                return AlertDialog(
                                                  content: cachedNetworkImage(user.photoURL),
                                                  scrollable: true,
                                                  contentPadding: EdgeInsets.zero,
                                                );
                                              }
                                          );
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: CClass.containerColor,
                                          radius: 65,
                                          backgroundImage: CachedNetworkImageProvider(user.photoURL),
                                        ),
                                      ),
                                      widget.profileId == FirebaseAuth.instance.currentUser!.uid ?
                                      GestureDetector(
                                        onTap: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                                            return EditProfileScreen(
                                              photoURL: user.photoURL,
                                              displayName: user.displayName,
                                              email: user.email,
                                              bio: user.bio,
                                              uid: user.uid,
                                              degree: user.degree,
                                              occupation: user.occupation,
                                              department: user.department,
                                              level: user.level,
                                              school: user.school,
                                            );
                                          }));
                                        },
                                        child: Column(
                                          children: [
                                            Container(height: 70,),
                                            Row(
                                              children: [
                                                Icon(Icons.edit,color: CClass.bTColor2Theme(),),
                                                Text('Edit Profile',style: TextStyle(color: CClass.bTColor2Theme()),)
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                          : !isFollowing ?
                                      GestureDetector(
                                        onTap: _handleFollow,
                                        child: Column(
                                          children: [
                                            Container(height: 70,),
                                            Row(
                                              children: [
                                                Icon(Icons.add,color: CClass.bTColor2Theme(),),
                                                Text('Follow',style: TextStyle(color: CClass.bTColor2Theme()),)
                                              ],
                                            ),
                                          ],
                                        ),
                                      ): isFollowing ?
                                      GestureDetector(
                                        onTap: _handleUnfollow,
                                        child: Column(
                                          children: [
                                            Container(height: 70,),
                                            Row(
                                              children: [
                                                Icon(Icons.clear,color: CClass.buttonColor2,),
                                                Text('Unfollow',style: TextStyle(color: CClass.buttonColor2),)
                                              ],
                                            ),
                                          ],
                                        ),
                                      ): SizedBox()
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(user.displayName,
                                        style: const TextStyle(fontSize: 30),
                                      ),
                                      Text(user.email,style: TextStyle(color: CClass.textColor2,),)
                                    ],
                                  ),
                                ),
                                Divider(thickness: 2, color: CClass.containerColor,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    countColumn('Post', postCount),
                                    Container(
                                      height: 50,
                                      width: 5,
                                      color: CClass.containerColor,
                                    ),
                                    InkWell(
                                      onTap: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context){
                                          return FollowersScreen(
                                            profileId: widget.profileId,
                                          );
                                        }));
                                      },
                                      child: StreamBuilder(
                                        stream: FirebaseFirestore.instance.collection('followers').doc(widget.profileId)
                                            .collection('userFollowers').snapshots(),
                                        builder: (context, snapshot) {
                                          if(!snapshot.hasData){
                                            return countColumn('Followers', 0);
                                          }
                                          if(snapshot.data!.docs.isEmpty){
                                            return countColumn('Followers', 0);
                                          }
                                          int followerCount = snapshot.data!.docs.length;
                                          return countColumn('Followers', followerCount);
                                        }
                                      ),
                                    ),

                                    Container(
                                      height: 50,
                                      width: 5,
                                      color: CClass.containerColor,
                                    ),
                                    InkWell(
                                      onTap: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context){
                                          return FollowingScreen(
                                            profileId: widget.profileId,
                                          );
                                        }));
                                      },
                                      child: StreamBuilder(
                                          stream: FirebaseFirestore.instance.collection('following').doc(widget.profileId)
                                              .collection('userFollowing').snapshots(),
                                          builder: (context, snapshot) {
                                            if(!snapshot.hasData){
                                              return countColumn('Following', 0);
                                            }
                                            if(snapshot.data!.docs.isEmpty){
                                              return countColumn('Following', 0);
                                            }
                                            int followingCount = snapshot.data!.docs.length;
                                          return countColumn('Following', followingCount);
                                        }
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(color: CClass.containerColor,),
                                SizedBox(height: 20,),
                                isDetails == false ? TextButton.icon(
                                    onPressed: (){
                                      setState(() {
                                        isDetails = true;
                                      });
                                    },
                                    icon: Icon(Icons.arrow_drop_down_circle_outlined,color: CClass.buttonColor2,),
                                    label: Text('Tab to see more about ${user.displayName}',
                                      style: TextStyle(fontSize: 16,color: CClass.buttonColor2),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                ):
                                Column(
                                  children: [
                                    ListTile(
                                      title: user.school != '' ? Text('Occupation/School : ') : Text('Ocupation : '),
                                      subtitle: Container(
                                        padding: const EdgeInsets.all(12),
                                        color: CClass.bGColor2Theme(),
                                        child: user.school != '' ?
                                        Text('${user.occupation} at ${user.school}')
                                            :
                                        Text(user.occupation),
                                      ),
                                    ),
                                    Divider(color: CClass.containerColor,),
                                    ListTile(
                                      title: Text('Level : '),
                                      subtitle: Container(
                                        padding: const EdgeInsets.all(12),
                                        color: CClass.bGColor2Theme(),
                                        child: Text(user.level),
                                      ),
                                    ),
                                    Divider(color: CClass.containerColor,),
                                    ListTile(
                                      title: Text('Degree/Department : '),
                                      subtitle: Container(
                                        padding: const EdgeInsets.all(12),
                                        color: CClass.bGColor2Theme(),
                                        child:user.degree != '' && user.department != ''? Text('Aiming for ${user.degree} in the department of ${user.department}')
                                            :user.degree != '' && user.department == ''? Text('Aiming for ${user.degree}')
                                            :user.degree == '' && user.department != ''? Text('Department of ${user.department}') : SizedBox(),
                                      ),
                                    ),
                                    Divider(color: CClass.containerColor,),
                                    ListTile(
                                      title: Text('Interests/Bio : '),
                                      subtitle: Container(
                                        padding: const EdgeInsets.all(12),
                                        color: CClass.bGColor2Theme(),
                                        child: Text('${user.bio}'),
                                      ),
                                    ),
                                    Divider(color: CClass.containerColor,),
                                    TextButton.icon(
                                        onPressed: (){
                                          setState(() {
                                            isDetails = false;
                                          });
                                        },
                                        icon: Icon(Icons.arrow_circle_up_outlined,color: CClass.buttonColor2,),
                                        label: Text('Tap to close details',
                                          style: TextStyle(fontSize: 16,color: CClass.buttonColor2),
                                          overflow: TextOverflow.ellipsis,
                                        )
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  }),
                ),
              ],
            ),
          );
        }
    );
  }

  @override
  void initState() {
    _getData();
    profileContent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            backgroundColor: CClass.bGColorTheme(),
            elevation: 0.0,
          ),
          body: ListView(
            children: [
              profileHeader(),
              const SizedBox(height: 20.0,),
              Container(
                decoration: BoxDecoration(
                    color: CClass.secondaryBGColorTheme(),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(50),
                        topLeft: Radius.circular(50)
                    )
                ),
                child: posts.isEmpty ? Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: const Center(child: Text('No post available')),
                ) :
                Column(
                  children: [
                    selectedView(),
                    const Divider(),
                    selectedGrid ? gridViewPost() : listViewPost()
                  ],
                ),
              )
            ],
          )
        );
  }
}
