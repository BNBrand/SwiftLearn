import 'package:cloud_firestore/cloud_firestore.dart';

class Users{
  String displayName;
  String photoURL;
  String email;
  String uid;
  String bio;
  String createdAt;
  int totalStars;

  Users({
    required this.photoURL,
    required this.email,
    required this.displayName,
    required this.uid,
    required this.bio,
    required this.createdAt,
    required this.totalStars
});

  factory  Users.fromDocument(DocumentSnapshot doc){
    return Users(
      uid: doc['uid'],
      displayName: doc['displayName'],
      photoURL: doc['photoURL'],
      email: doc['email'],
      bio: doc['bio'],
      createdAt: doc['createdAt'],
      totalStars: doc['totalStars'],
    );
  }

}
