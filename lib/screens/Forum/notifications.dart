import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../utils/color.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

  getNotification() async{
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('feed').doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('feedData').orderBy('createdAt', descending: true).limit(50).get();
    snapshot.docs.forEach((doc) {

    });
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: Text('Notifications'),
        backgroundColor: CClass.bGColor2Theme(),
      ),
      body: Container(
        child: FutureBuilder(
          future: null,
          builder: (context, snapshot) {
            if(!snapshot.hasData){
              return Center(child: CircularProgressIndicator(color: CClass.bTColor2Theme(),));
            }
            return Text(' ');
          }
        ),
      ),
    );
  }
}
