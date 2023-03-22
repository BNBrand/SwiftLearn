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
                height: MediaQuery.of(context).size.height * 0.33,
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
                        child: Container(
                          height: innerHeight * 0.7,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: secondaryBackgroundColor,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment : MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('   0 Stars',style: TextStyle(color: textColor1),),
                                    widget.profileId == FirebaseAuth.instance.currentUser!.uid ? TextButton.icon(
                                        onPressed: (){
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
                                        icon: const Icon(Icons.edit,color: buttonColor2,),
                                        label: const Text('Edit Profile',style: TextStyle(color: buttonColor2),)
                                    )
                                    :
                                    TextButton.icon(
                                        onPressed: (){},
                                        icon: const Icon(Icons.add,color: buttonColor2,),
                                        label: const Text('Follow',style: TextStyle(color: buttonColor2),)
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20,),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(user.displayName,
                                    style: const TextStyle(fontSize: 30),
                                    ),
                                    Text(user.email),
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
                              )
                            ],
                          ),

                        ),
                      ),
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: CircleAvatar(
                            backgroundColor: containerColor,
                            radius: 70,
                            backgroundImage: CachedNetworkImageProvider(user.photoURL),
                          ),
                        ),
                      )
                    ],
                  );
                }),
              ),
              const SizedBox(height: 20.0,),
              Container(
                height: MediaQuery.of(context).size.height * 0.57,
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
