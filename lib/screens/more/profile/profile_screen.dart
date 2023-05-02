import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/models/post_model.dart';
import 'package:swift_learn/screens/more/profile/edit_profile.dart';
import 'package:swift_learn/widgets/post_tile.dart';

import '../../../models/user_model.dart';
import '../../../utils/colors.dart';

class ProfileScreen extends StatefulWidget {

  final String profileId;

  ProfileScreen({required this.profileId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  bool seclectGrid = true;
  bool isLoading = false;
  int postCount = 0;
  int starCount = 0;
  List<Post> posts = [];

  gridViewPost(){
    seclectGrid = true;
    if(isLoading){
      return const Center(child: CircularProgressIndicator(color: buttonColor2,));
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
                seclectGrid = true;
              });
            },
            icon: Icon(Icons.grid_on,
            size: seclectGrid ? 25 : 18,
            color: seclectGrid ? textColor1 : textColor2,
            )
        ),
        IconButton(
            onPressed: (){
              setState(() {
                seclectGrid = false;
              });
            },
            icon: Icon(Icons.list,
            size: seclectGrid ? 18 : 25,
            color: seclectGrid ? textColor2 : textColor1,
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

  profileHeader(){
return FutureBuilder(
    future: FirebaseFirestore.instance.collection('users').doc(widget.profileId).get(),
    builder: (context, snapshot) {

      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator(color: buttonColor2,));
      }
      Users user = Users.fromDocument(snapshot.data!);
  return SingleChildScrollView(
    child: Column(
      children: [
        Container(
          height: 550,
          color: backgroundColor,
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
                        height: innerHeight * 0.85,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: secondaryBackgroundColor,
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
                                      Icon(Icons.star,color: starColor,),
                                      Text('${user.totalStars.toString()} Stars',style: TextStyle(color: textColor1),),
                                    ],
                                  ),
                                ],
                              ),
                              CircleAvatar(
                                backgroundColor: containerColor,
                                radius: 65,
                                backgroundImage: CachedNetworkImageProvider(user.photoURL),
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
                                      children: const [
                                        Icon(Icons.edit,color: buttonColor2,),
                                        Text('Edit Profile',style: TextStyle(color: buttonColor2),)
                                      ],
                                    ),
                                  ],
                                ),
                              )
                                  :
                              GestureDetector(
                                  onTap: (){},
                                  child: Column(
                                    children: [
                                      Container(height: 70,),
                                      Row(
                                        children: const [
                                          Icon(Icons.add,color: buttonColor2,),
                                          Text('Follow',style: TextStyle(color: buttonColor2),)
                                        ],
                                      ),
                                    ],
                                  ),
                              )
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
                              Text(user.email,style: TextStyle(color: textColor2),),
                            ],
                          ),
                        ),
                        const Divider(
                          thickness: 2,
                          color: containerColor,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            countColumn('Post', postCount),
                            Container(
                              height: 50,
                              width: 5,
                              color: containerColor,
                            ),
                            countColumn('Followers', 0),
                            Container(
                              height: 50,
                              width: 5,
                              color: containerColor,
                            ),
                            countColumn('Following', 0),
                          ],
                        ),
                         SizedBox(height: 20,),
                         Padding(
                           padding: const EdgeInsets.symmetric(vertical: 5.0),
                           child: Container(
                             padding: const EdgeInsets.all(12),
                            color: backgroundColor2,
                            child: user.occupation != '' ?
                            Text('${user.occupation} at ${user.school}')
                                :
                             Text(user.occupation),
                        ),
                         ),
                        user.level != '' ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            color: backgroundColor2,
                            child: Text(user.level),
                          ),
                        ) : const SizedBox(),
                        user.degree != '' || user.degree != null ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            color: backgroundColor2,
                            child: Text('Aiming for ${user.degree} in the department of ${user.department}'),
                          ),
                        ) : const SizedBox(),
                        user.bio != '' ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            color: backgroundColor2,
                            child: Text('Interests : ${user.bio}'),
                          ),
                        ) : const SizedBox(),
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
    seclectGrid = false;
      if(isLoading) {
        return const Center(child: CircularProgressIndicator(color: buttonColor2,));
      }
      return Column(children: posts,);
  }

  @override
  void initState() {
    profileContent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0.0,
          ),
          body: ListView(
            children: [
              profileHeader(),
              const SizedBox(height: 20.0,),
              Container(
                decoration: const BoxDecoration(
                    color: secondaryBackgroundColor,
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
                    seclectGrid ? gridViewPost() : listViewPost()
                  ],
                ),
              )
            ],
          )
        );
  }
}
