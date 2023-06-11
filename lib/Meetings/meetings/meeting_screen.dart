import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet/feature_flag/feature_flag.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:swift_learn/Meetings/meetings/history_meeting_screen.dart';
import 'package:swift_learn/Meetings/meetings/join_meeting_screen.dart';
import 'package:swift_learn/utils/color.dart';
import 'package:swift_learn/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class MeetingScreen extends StatefulWidget {
  MeetingScreen({Key? key}) : super(key: key);

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  Map<FeatureFlag, Object> featureFlags = {};
  String displayName = '';
  String photoURL = '';
  String email = '';
  String historyId = const Uuid().v4();

  Future _getData() async{
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then((snapshot) async{
      if(snapshot.exists){
        setState(() {
          displayName = snapshot.data()!['displayName'];
          photoURL = snapshot.data()!['photoURL'];
          email = snapshot.data()!['email'];
        });
      }
    });
  }
  void addToMeetingHistory(String meetingName) async {
    try {
      await FirebaseFirestore.instance.collection('history')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('meetings').doc(historyId)
          .set({
        'meetingName': meetingName,
        'createdAt': DateFormat.yMMMMd().add_jms().format(DateTime.now()),
      });
      historyId = const Uuid().v4();
    } catch (e) {
      print(e);
    }
  }
  void createMeeting({
    required String roomName,
    required bool isAudioMuted,
    required bool isVideoMuted,
  }) async {
    try {
      FeatureFlag featureFlag = FeatureFlag();
      featureFlag.welcomePageEnabled = false;
      featureFlag.resolution = FeatureFlagVideoResolution.MD_RESOLUTION;

      var options = JitsiMeetingOptions(room: roomName)
        ..userDisplayName = displayName
        ..userEmail = email
        ..userAvatarURL = photoURL
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted;

      addToMeetingHistory(roomName);
      await JitsiMeet.joinMeeting(options);
    } catch (error) {
      print("error: $error");
    }
  }

  createNewMeeting() async {
    var random = Random();
    String roomName = (random.nextInt(10000000) + 10000000).toString();
   createMeeting(
        roomName: roomName, isAudioMuted: true, isVideoMuted: true);
  }

  joinMeeting(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return const JoinMeetingScreen();
    }));
  }
  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CClass.backgroundColor2,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
            builder: (context, snapshot) {
              if(!snapshot.hasData){
                return const Loading();
              }
              String name = snapshot.data!['displayName'];
              String image = snapshot.data!['photoURL'];
              return Column(
                children: [
                   Text('Start Meetings with SwiftLearn',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,),
                  ),
                  SizedBox(height: 20,),
                  CircleAvatar(
                    backgroundColor: CClass.containerColor,
                    backgroundImage: CachedNetworkImageProvider(image),
                    radius: 50,
                  ),
                  Text(name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,),
                  ),
                ],
              );
            }
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: createNewMeeting,
                      child: Container(
                        height: 110,
                        width: MediaQuery.of(context).size.width * 0.45,
                        decoration: BoxDecoration(
                          color: CClass.containerColor,
                          borderRadius: const BorderRadius.all(
                              Radius.circular(30.0)
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.videocam,color: CClass.buttonColor2,size: 50,),
                            Text('CREATE',style: TextStyle(color: CClass.buttonColor2),)
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => joinMeeting(context),
                      child: Container(
                        height: 110,
                        width: MediaQuery.of(context).size.width * 0.45,
                        decoration: BoxDecoration(
                          color: CClass.containerColor,
                          borderRadius: const BorderRadius.all(
                              Radius.circular(30.0)
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_call_outlined,color: Colors.green, size: 50,),
                            Text('JOIN',style: TextStyle(color: Colors.green),)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30,),
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return const HistoryMeetingScreen();
                    }));
                  },
                  child: Container(
                    height: 80,
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: CClass.containerColor,
                      borderRadius: const BorderRadius.all(
                          Radius.circular(50.0)
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history,color: CClass.textColor1,),
                        SizedBox(width: 10,),
                        Text('HISTORY',style: TextStyle(color: CClass.textColor1),)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
