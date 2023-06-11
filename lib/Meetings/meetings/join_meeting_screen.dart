import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet/feature_flag/feature_flag.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:swift_learn/utils/color.dart';
import 'package:uuid/uuid.dart';
import '../../widgets/custom_button.dart';
import 'package:intl/intl.dart';

class JoinMeetingScreen extends StatefulWidget {
  const JoinMeetingScreen({Key? key}) : super(key: key);

  @override
  State<JoinMeetingScreen> createState() => _JoinMeetingScreenState();
}

class _JoinMeetingScreenState extends State<JoinMeetingScreen> {
  late TextEditingController meetingIdController;
  bool isAudioMuted = true;
  bool isVideoMuted = true;
  Map<FeatureFlag, Object> featureFlags = {};
  String displayName = '';
  String historyId = const Uuid().v4();
  String photoURL = '';
  String email = '';

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

  @override
  void initState() {
    _getData();
    meetingIdController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    meetingIdController.dispose();
    // JitsiMeet.removeAllListeners();
  }


  _joinMeeting() {
    createMeeting(
      roomName: meetingIdController.text,
      isAudioMuted: isAudioMuted,
      isVideoMuted: isVideoMuted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CClass.backgroundColor2,
        title: const Text(
          'Join a Meeting',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(height: 10.0,),
          TextField(
              controller: meetingIdController,
              maxLines: 1,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                fillColor: CClass.backgroundColor2,
                filled: true,
                hintText: 'Room ID',
                contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 0),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CClass.containerColor, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CClass.buttonColor2, width: 2.0),
                ),
              ),
            ),
          Container(
            padding: EdgeInsets.all(10),
            color: CClass.secondaryBackgroundColor,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0,vertical: 20.0),
                      child: Text('Mute Audio',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Switch.adaptive(
                      value: isAudioMuted,
                      onChanged: onAudioMuted,
                      activeColor: CClass.buttonColor2,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0,vertical: 20.0),
                      child: Text('Turn Off My Video',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Switch.adaptive(
                      value: isVideoMuted,
                      onChanged: onVideoMuted,
                      activeColor: CClass.buttonColor2,
                    ),
                  ],
                ),
              ],
            ),
          ),
          CustomButton(
            text: 'JOIN',
            onPressed: _joinMeeting,
            color: CClass.buttonColor,
            icon: Icons.video_call_outlined,
            textColor: CClass.textColor1,
          )
        ],
      ),
    );
  }

  onAudioMuted(bool val) {
    setState(() {
      isAudioMuted = val;
    });
  }

  onVideoMuted(bool val) {
    setState(() {
      isVideoMuted = val;
    });
  }
}
