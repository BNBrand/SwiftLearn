import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/screens/Forum/Quiz/result_screen.dart';
import 'package:swift_learn/utils/color.dart';

import '../../models/user_model.dart';
import '../../widgets/loading.dart';
import '../authenticate/landing_screen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Loading();
          }
          Users user = Users.fromDocument(snapshot.data!);
        return Scaffold(
          backgroundColor: CClass.backgroundColor,
          appBar: AppBar(
            centerTitle: true,
            title: Text('Welcome to SwiftLearn', style: TextStyle(fontSize: 25),),
            backgroundColor: CClass.backgroundColor,
            elevation: 0.0,
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: CClass.buttonColor,
            child: Icon(Icons.notifications,color: CClass.textColor1,),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return const ResultScreen();
              }));
            },
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(user.displayName,style: TextStyle(color: CClass.textColor1)),
                      const SizedBox(height: 10,),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return const LandingScreen();
                          }));
                        },
                        child: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(user.photoURL),
                            radius: 50
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Text(user.email,style: TextStyle(color: CClass.textColor1)),
                    ],
                  ),
                  Text('Learning Never Ends...', style: TextStyle(fontSize: 20),),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ListTile(
                        leading:  Icon(Icons.videocam,color: CClass.buttonColor2,),
                          title: Text('Start Video Meetings', style: TextStyle(color: CClass.buttonColor2),)),
                      const ListTile(
                          leading: Icon(Icons.question_answer_outlined, color: Colors.greenAccent),
                          title: Text('Engage in the Q&A platform', style: TextStyle(color: Colors.greenAccent),),
                      ),
                      const ListTile(
                          leading: Icon(Icons.upload, color: Colors.redAccent),
                          title: Text('Upload and Post Images', style: TextStyle(color: Colors.redAccent),)),
                      const ListTile(
                          leading: Icon(Icons.quiz,color: Colors.blue),
                          title: Text('Create and Answer Quizzes', style: TextStyle(color: Colors.blue),)),
                      const ListTile(
                          leading: Icon(Icons.videocam, color: Colors.yellowAccent),
                          title: Text('Store and Manage Notes', style: TextStyle(color: Colors.yellowAccent),)),const ListTile(
                          leading: Icon(Icons.dehaze),
                          title: Text('And more...')),

                    ],
                  )
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
