import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/screens/Forum/Quiz/quizQuestions_screen.dart';
import 'package:swift_learn/screens/notes/notes_course.dart';

import '../../../utils/color.dart';

class QuizScreen extends StatefulWidget {


  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  TextEditingController titleController = TextEditingController();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
          stream: FirebaseFirestore.instance.collection('quiz').orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if(!snapshot.hasData){
              return Center(child: CircularProgressIndicator(color: CClass.bTColor2Theme(),));
            }
            return snapshot.data!.docs.isNotEmpty ? ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, int index){
                  String quizTitle = snapshot.data!.docs[index]['quizTitle'];
                  String createdAt = snapshot.data!.docs[index]['createdAt'];
                  String displayName = snapshot.data!.docs[index]['displayName'];
                  String ownerID = snapshot.data!.docs[index]['ownerId'];
                  String quizID = snapshot.data!.docs[index]['quizId'];
                  deleteQuiz() async{
                    await FirebaseFirestore.instance.collection('quiz').doc(quizID).delete();
                  }
                  updateNoteTitle() async{
                    await FirebaseFirestore.instance.collection('quiz').doc(FirebaseAuth.instance.currentUser!.uid).collection('course').doc(quizID).update(
                        {
                          'quizTitle': titleController.text.trim().toUpperCase(),
                        });
                  }
                  showDialogBoxUpdate(context){
                    setState(() {
                      titleController = TextEditingController(text: quizTitle);
                    });
                    showDialog(
                        context: context,
                        builder: (context){
                          return AlertDialog(
                            backgroundColor: CClass.bGColorTheme(),
                            title: Column(
                              children: [
                                const Text('Enter Course Title'),
                                const SizedBox(height: 30,),
                                TextField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                      hintText: 'Enter Title',
                                      filled: true,
                                      fillColor: CClass.containerColor,
                                      border: InputBorder.none
                                  ),
                                ),
                                const SizedBox(height: 20,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: (){
                                        Navigator.pop(context);
                                        titleController.clear();
                                      },
                                      child: const Text('Cancel'),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: CClass.bTColorTheme()
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async{
                                        setState(() {
                                          updateNoteTitle();
                                        });
                                        Navigator.pop(context);
                                        titleController.clear();
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: CClass.bTColorTheme()
                                      ),
                                      child: const Text('Update'),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                    );
                  }
                  showOptionDialog(){
                    showDialog(
                        context: context,
                        builder: (context){
                          return AlertDialog(
                            backgroundColor: CClass.backgroundColor,
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton.icon(
                                    onPressed: (){
                                      Navigator.pop(context);
                                      showDialogBoxUpdate(context);
                                    },
                                    icon: Icon(Icons.edit,color: Colors.green,),
                                    label: Text('Edit Question',style: TextStyle(color: CClass.textColor1),)
                                ),
                                const SizedBox(height: 10.0,),
                                TextButton.icon(
                                    onPressed: (){
                                      deleteQuiz();
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(Icons.delete,color: Colors.red,),
                                    label: Text('Delete Question',style: TextStyle(color: CClass.textColor1),)
                                )
                              ],
                            ),
                          );
                        }
                    );
                  }
                  return Column(
                    children: [
                      GestureDetector(
                        onLongPress: (){
                          ownerID == uid ? showOptionDialog() : null;
                        },
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context){
                          return QuizQuestions(quizId: quizID);
                        })),
                        child: Card(
                          color: CClass.containerColor,
                          shadowColor: CClass.buttonColor2,
                          child: ListTile(
                            title: Text(quizTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text('Created by $displayName on $createdAt'),
                          ),
                        ),
                      ),
                      Divider(color: CClass.containerColor,)
                    ],
                  );
                }
            ):
            const Center(child: Text('Add a Quiz Course'));
          }
      );
  }
}
