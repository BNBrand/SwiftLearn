import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/screens/more/profile/profile_screen.dart';
import 'package:swift_learn/utils/color.dart';
import '../../../models/user_model.dart';

class FollowersScreen extends StatefulWidget {
  String profileId;

  FollowersScreen({required this.profileId});
  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Followers'),
        centerTitle: true,
        backgroundColor: CClass.backgroundColor2,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('followers').doc(widget.profileId)
          .collection('userFollowers').snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return Center(child: CircularProgressIndicator(color: CClass.buttonColor2,));
          }
          return snapshot.data!.docs.isNotEmpty ? ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index){
              String ownerId = snapshot.data!.docs[index]['ownerId'];
              String followedAt = snapshot.data!.docs[index]['followedAt'];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('users').doc(ownerId).snapshots(),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: Center(child: CircularProgressIndicator(color: CClass.bTColorTheme(),)),
                        );
                      }
                      Users user = Users.fromDocument(snapshot.data!);
                    return ListTile(
                          leading: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                                return ProfileScreen(
                                  profileId: ownerId,
                                );
                              }));
                            },
                            child: CircleAvatar(
                              backgroundColor: CClass.containerColor,
                              backgroundImage: CachedNetworkImageProvider(user.photoURL),
                            ),
                          ),
                          title: Text(user.displayName),
                      subtitle: Text('From $followedAt'),
                      trailing: Text(user.occupation),
                        );
                  }
                ),
              );
            },
          ):
          const Center(child: Text('No followers'));
        }
      ),
    );
  }
}
