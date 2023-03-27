import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/models/user_model.dart';
import 'package:swift_learn/screens/more/profile/edit_profile.dart';

import '../../../utils/colors.dart';

class ProfileScreen extends StatefulWidget {

  final String profileId;

  ProfileScreen({required this.profileId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  buildProfileButton(){
    return const Text('Profile button');
  }

  buildCountColumn(String label, int count){
    return Column(
      children: [
        Text(count.toString(),
        style: const TextStyle(fontSize: 20,
        fontWeight: FontWeight.w600
        ),
        ),
        Container(
          child: Text(label),
        )
      ],
    );
  }

  profileHeader(){
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('users').doc(widget.profileId).get(),
        builder: (context, snapshot) {
        if(!snapshot.hasData){
          return const Center(child: CircularProgressIndicator(color: buttonColor,));
        }
        Users user = Users.fromDocument(snapshot.data!);
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
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
                              height: innerHeight * 0.8,
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
                                            const Text('0 Stars',style: TextStyle(color: textColor1),),
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
                                  buildCountColumn('Post', 0),
                                  Container(
                                    height: 50,
                                    width: 5,
                                    color: containerColor,
                                  ),
                                  buildCountColumn('Followers', 0),
                                  Container(
                                    height: 50,
                                    width: 5,
                                    color: containerColor,
                                  ),
                                  buildCountColumn('Following', 0),
                                ],
                              ),
                               SizedBox(height: 25,),
                               Container(
                                 padding: EdgeInsets.all(12),
                                color: backgroundColor2,
                                child: Text(user.bio,),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                }),
              ),
              const SizedBox(height: 20.0,),
              Container(
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  color: secondaryBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(50),
                    topLeft: Radius.circular(50)
                  )
                ),
              )
            ],
          ),
        );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0.0,
      ),
      body: profileHeader()
    );
  }
}
