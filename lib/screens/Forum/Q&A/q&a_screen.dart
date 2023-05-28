import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../utils/color.dart';
import 'answer_screen.dart';

class QAScreen extends StatefulWidget {
  const QAScreen({Key? key}) : super(key: key);

  @override
  State<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen> {
  String? uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
          stream: FirebaseFirestore.instance.collection('questions').orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if(!snapshot.hasData){
              return Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.4,),
                  Center(child: CircularProgressIndicator(color: CClass.bTColor2Theme(),)),
                ],
              );
            }
            return snapshot.data!.docs.isNotEmpty ? ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, int index){
                  String question = snapshot.data!.docs[index]['question'];
                  Timestamp createdAt = snapshot.data!.docs[index]['createdAt'];
                  String questionID = snapshot.data!.docs[index]['questionId'];
                  int answers = snapshot.data!.docs[index]['answers'];
                  String ownerId = snapshot.data!.docs[index]['ownerId'];
                  String displayName = snapshot.data!.docs[index]['displayName'];
                  String photoURL = snapshot.data!.docs[index]['photoURL'];
                  String displayNameUser = '';
                  String photoURLUser = '';
                  updateUserInfo()async{
                    await FirebaseFirestore.instance.collection('users').doc(ownerId)
                        .get().then((snapshot) async{
                      if(snapshot.exists){
                        setState(() {
                          displayNameUser = snapshot.data()!['displayName'];
                          photoURLUser = snapshot.data()!['photoURL'];
                        });
                      }
                    });
                    await FirebaseFirestore.instance.collection('questions').doc(questionID).update(
                        {
                          'displayName': displayNameUser,
                          'photoURL': photoURLUser,
                        });
                  }
                  updateUserInfo();
                  deleteQuestion() async{
                    await FirebaseFirestore.instance.collection('questions').doc(questionID).delete();
                  }
                  return Column(
                    children: [
                      InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context){
                              return AnswerScreen(
                                  question: question,
                                  questionId: questionID,
                                  createdAt: createdAt,
                                  ownerId: ownerId,
                                  ownerPhoto: photoURL,
                                  ownerName: displayName,
                                  answers: answers,
                              );
                            })),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Card(
                                elevation: 10,
                                color: CClass.containerColor,
                                shadowColor: CClass.backgroundColor2,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: CachedNetworkImageProvider(photoURL),
                                          backgroundColor: CClass.containerColor,
                                        ),
                                        title: Text(question,
                                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                        subtitle: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('By ${displayName}   - ${timeago.format(createdAt.toDate())} -'),
                                            TextButton.icon(
                                                onPressed: (){},
                                                icon: Icon(Icons.question_answer_outlined,color: Colors.green),
                                                label: Text(answers.toString(),style: TextStyle(color: CClass.textColor1),)
                                            )
                                          ],
                                        ),
                                        trailing: uid != ownerId ? null : IconButton(
                                          onPressed: deleteQuestion,
                                          icon: Icon(Icons.delete,color: CClass.buttonColor2,),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      Divider(color: CClass.containerColor,)
                    ],
                  );
                }
            ):
            Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.4,),
                const Center(child: Text('No questions yet. Ask a question')),
              ],
            );
          }
      );
  }
}
