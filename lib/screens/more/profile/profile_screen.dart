import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/models/user_model.dart';

import '../../../utils/colors.dart';

class ProfileScreen extends StatefulWidget {

  final String profileId;

  ProfileScreen({required this.profileId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  buildProfileButton(){
    return Text('Profile button');
  }

  buildCountColumn(String label, int count){
    return Column(
      children: [
        Text(count.toString()),
        Container(
          child: Text(label,
          ),
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
        return Column(
          children: [
            Stack(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              fit: StackFit.loose,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 150.0,
                  decoration: const BoxDecoration(
                      color: secondaryBackgroundColor,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(100),
                          bottomLeft: Radius.circular(100)
                      )
                  ),
                ),
              Positioned(
                bottom: 10.0,
                child: Column(
                  children: [
                    Text(user.displayName),
                    CircleAvatar(
                      radius: 40.0,
                      backgroundImage: CachedNetworkImageProvider(user.photoURL),
                    ),
                    Text(user.email)
                  ],
                ),
              ),
              ]
            ),
            Container(
              clipBehavior: Clip.hardEdge,
              height: 70,
              decoration: const BoxDecoration(
                  color: backgroundColor,
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                    color: secondaryBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100),
                    topRight: Radius.circular(100)
                  )
                ),
              ),
            )
          ],
        );
        // return Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Column(
        //     children: [
        //       Row(
        //         children: [
        //           CircleAvatar(
        //             radius: 40.0,
        //             backgroundImage: CachedNetworkImageProvider(user.photoURL),
        //           ),
        //           Expanded(
        //             flex: 1,
        //               child: Column(
        //                 children: [
        //                   Row(
        //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //                     mainAxisSize: MainAxisSize.max,
        //                     children: [
        //                       buildCountColumn('Post', 0),
        //                       buildCountColumn('Followers', 0),
        //                       buildCountColumn('Following', 0),
        //                     ],
        //                   ),
        //                   Row(
        //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //                     children: [
        //                       buildProfileButton(),
        //                     ],
        //                   )
        //                 ],
        //               )
        //           )
        //         ],
        //       ),
        //       Container(
        //         alignment: Alignment.centerLeft,
        //         padding: EdgeInsets.only(top: 12.0),
        //         child: Text(user.displayName),
        //       )
        //     ],
        //   ),
        // );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryBackgroundColor,
        elevation: 0.0,
      ),
      body: profileHeader()
    );
  }
}
