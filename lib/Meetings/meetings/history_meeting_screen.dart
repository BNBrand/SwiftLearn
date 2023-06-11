import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils/color.dart';
import '../../widgets/loading.dart';
import '../jitsi_history.dart';

class HistoryMeetingScreen extends StatefulWidget {
  const HistoryMeetingScreen({Key? key}) : super(key: key);

  @override
  State<HistoryMeetingScreen> createState() => _HistoryMeetingScreenState();
}

class _HistoryMeetingScreenState extends State<HistoryMeetingScreen> {
  _clearMeetingHistory(){
    FirebaseFirestore.instance.collection('history')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .delete();
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('history')
          .doc(FirebaseAuth.instance.currentUser!.uid).collection('meetings').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Loading()
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('History'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: CClass.backgroundColor2,
            actions: [
              TextButton(
                  onPressed: _clearMeetingHistory,
                  child: Text('Clear History',style: TextStyle(color: CClass.textColor1),)
              )
            ],
          ),
          body: snapshot.data!.docs.isNotEmpty ? ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              String createdAT = snapshot.data!.docs[index]['createdAt'];
              String room = snapshot.data!.docs[index]['meetingName'];
              return ListTile(
                title: Text(
                  'Room Name: $room',
                ),
                subtitle: Text('Joined on: $createdAT',overflow: TextOverflow.ellipsis,),
              );
            }):
              const Center(
                child: Text('History is empty'),
              )
        );
      },
    );
  }
}
