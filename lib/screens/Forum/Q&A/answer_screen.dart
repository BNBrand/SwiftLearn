import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';
import '../../../utils/color.dart';
import '../../more/profile/profile_screen.dart';

class AnswerScreen extends StatefulWidget {
  String questionId;
  String question;
  int answers;
  Timestamp createdAt;
  String ownerId;
  String ownerPhoto;
  String ownerName;
  AnswerScreen({
   required this.answers,
   required this.question,
   required this.questionId,
   required this.createdAt,
   required this.ownerId,
   required this.ownerPhoto,
   required this.ownerName,
});

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  TextEditingController answerController = TextEditingController();
  String photoURLUser = '';
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String answerId = const Uuid().v4();

  Future _getData() async{
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then((snapshot) async{
      if(snapshot.exists){
        setState(() {
          photoURLUser = snapshot.data()!['photoURL'];
        });
      }
    });
  }
  _handleAnswer()async{
    if(answerController.text.isNotEmpty){
      await FirebaseFirestore.instance.collection('questions').doc(widget.questionId).collection('answers').doc(answerId).set(
          {
            'answer': answerController.text.trim(),
            'answerId': answerId,
            'ownerId': uid,
            'answeredAt': Timestamp.now(),
            'answerStars': 0,
            'photoURL': photoURLUser,
          });
      await FirebaseFirestore.instance.collection('questions').doc(widget.questionId)
          .update({'answers' : FieldValue.increment(1)});
      answerController.clear();
      answerId = const Uuid().v4();
    }
  }
  @override
  void initState() {
   _getData();
   FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
       .collection('answerStars');
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        title: Text('Answers'),
        backgroundColor: CClass.bGColor2Theme(),
      ),
      body: Column(
        children: [
          Column(
            children: [
              ListTile(
                leading: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return ProfileScreen(profileId: widget.ownerId,);
                    }));
                  },
                  child: CircleAvatar(
                    backgroundColor: CClass.containerColor,
                    backgroundImage: CachedNetworkImageProvider(widget.ownerPhoto),
                  ),
                ),
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 10,right: 60),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.ownerName,overflow: TextOverflow.ellipsis,),
                      Text(timeago.format(widget.createdAt.toDate()),
                      style: TextStyle(fontSize: 14,color: CClass.textColor2),)
                    ],
                  ),
                ),
                subtitle: Text(widget.question,
                style: TextStyle(fontSize: 25,color: CClass.textColor1,fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 50,),
              TextButton.icon(
                onPressed: (){},
                icon : Icon(Icons.question_answer_outlined,color: Colors.green,),
                label: Text(widget.answers.toString(),style: TextStyle(color: CClass.textColor1),),
              ),
              Divider(color: CClass.containerColor,thickness: 5,)
            ],
          ),
          Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('questions').doc(widget.questionId)
                      .collection('answers').orderBy('answeredAt', descending: false).snapshots(),
                  builder: (context, snapshot) {
                    if(!snapshot.hasData){
                      return  Center(child: CircularProgressIndicator(color: CClass.buttonColor2,));
                    }
                    return snapshot.data!.docs.isNotEmpty ? ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, int index){
                        String answer = snapshot.data!.docs[index]['answer'];
                        Timestamp answeredAt = snapshot.data!.docs[index]['answeredAt'];
                        int answerStars = snapshot.data!.docs[index]['answerStars'];
                        String answerID = snapshot.data!.docs[index]['answerId'];
                        String ownerID = snapshot.data!.docs[index]['ownerId'];
                        String photoURL = snapshot.data!.docs[index]['photoURL'];
                        String displayNameUser = '';
                        String photoURLUser = '';
                        Future getData() async{
                          await FirebaseFirestore.instance.collection('users').doc(ownerID)
                              .get().then((snapshot) async{
                            if(snapshot.exists){
                              setState(() {
                                displayNameUser = snapshot.data()!['displayName'];
                                photoURLUser = snapshot.data()!['photoURL'];
                              });
                            }
                          });
                        }
                        updateUserInfo()async{
                          await FirebaseFirestore.instance.collection('questions').doc(widget.questionId)
                              .collection('answers').doc(answerID).update(
                              {
                                'displayName': displayNameUser,
                                'photoURL': photoURLUser,
                              });
                        }
                        getData();
                        updateUserInfo();
                        deleteAnswer() async{
                          await FirebaseFirestore.instance.collection('questions').doc(widget.questionId).collection('answers').doc(answerID).delete();
                          await FirebaseFirestore.instance.collection('questions').doc(widget.questionId)
                              .update({'answers' : FieldValue.increment(-1)});
                          await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('answerStars').doc(answerID).delete();
                          await FirebaseFirestore.instance.collection('users').doc(widget.ownerId)
                              .update({'totalStars': FieldValue.increment(-answerStars)});
                        }
                        handleStar() async{
                          await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('answerStars').doc(answerID).set({});
                          await FirebaseFirestore.instance.collection('questions').doc(widget.questionId).collection('answers').doc(answerID)
                              .update({'answerStars': FieldValue.increment(1)});
                          await FirebaseFirestore.instance.collection('users').doc(widget.ownerId)
                              .update({'totalStars': FieldValue.increment(1)});
                        }
                        handleDeleteStar() async{
                          DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('answerStars').doc(answerID).get();
                          if(snapshot.exists){
                            await FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('answerStars').doc(answerID).delete();
                            await FirebaseFirestore.instance.collection('questions').doc(widget.questionId).collection('answers').doc(answerID)
                                .update({'answerStars': FieldValue.increment(-1)});
                            await FirebaseFirestore.instance.collection('users').doc(widget.ownerId)
                                .update({'totalStars': FieldValue.increment(-1)});
                          }
                        }
                        return Column(
                          children: [
                            ListTile(
                              leading: GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context){
                                    return ProfileScreen(profileId: ownerID,);
                                  }));
                                },
                                child: CircleAvatar(
                                  backgroundColor: CClass.containerColor,
                                  backgroundImage: CachedNetworkImageProvider(photoURL),
                                ),
                              ),
                              title: Text(answer),
                              subtitle: Text(timeago.format(answeredAt.toDate())),
                              trailing: ownerID == uid ? IconButton(
                                onPressed: deleteAnswer,
                                icon: Icon(Icons.delete,color: CClass.buttonColor2,),
                              ):
                              null,
                            ),
                            StreamBuilder(
                              stream: FirebaseFirestore.instance.collection('stars').doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('answerStars').doc(answerID).snapshots(),
                              builder: (context, snapshot) {
                                if(!snapshot.hasData){
                                  return TextButton.icon(
                                    onPressed: (){},
                                    icon : Icon(Icons.star,color: CClass.textColor2,),
                                    label: Text(answerStars.toString(),style: TextStyle(color: CClass.textColorTheme()),),
                                  );
                                }
                                return snapshot.data!.exists ? TextButton.icon(
                                  onPressed: (){
                                    setState(() {
                                      handleDeleteStar();
                                    });
                                  },
                                  icon : Icon(Icons.star,color: CClass.starColor,),
                                  label: Text(answerStars.toString(),style: TextStyle(color: CClass.textColorTheme()),),
                                ):
                                TextButton.icon(
                                  onPressed: (){
                                    setState(() {
                                      handleStar();
                                    });
                                  },
                                  icon : Icon(Icons.star,color: CClass.textColor2,),
                                  label: Text(answerStars.toString(),style: TextStyle(color: CClass.textColorTheme()),),
                                );
                              }
                            ),
                            Divider(color: CClass.containerColor,)
                          ],
                        );
                      },
                    ):
                    const Center(child: Text('No answers yet. Be the first to answer'));
                  }
              )
          ),
          Container(
            color: CClass.containerColor,
            child: ListTile(
              title: TextField(
                controller: answerController,
                decoration: InputDecoration(
                    hintText: 'Answer',
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                        icon : Icon(Icons.send,color: CClass.textColorTheme(),),
                        onPressed: (){
                          setState(() {
                            _handleAnswer();
                          });
                        }
                    )
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
