import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/models/user_model.dart';

import '../../../utils/color.dart';
import '../../../widgets/loading.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CClass.backgroundColor2,
        title: Text('Quiz Result'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Loading();
            }
            Users users = Users.fromDocument(snapshot.data!);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Congratulations ', style: TextStyle(fontSize: 25),),
                Text(users.displayName, style: TextStyle(fontSize: 25),),
                SizedBox(height: 50,),
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(users.photoURL,),
                radius: 50,
                ),
                SizedBox(height: 30,),
                Text('You passed in 7 out of 10 questions',style: TextStyle(fontSize: 20),)
              ],
            );
          }
        ),
      ),
    );
  }
}
