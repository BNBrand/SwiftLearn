import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../models/user_model.dart';
import '../../../utils/color.dart';
import '../../../widgets/custom_button.dart';
import 'answer_screen.dart';

class QAScreen extends StatefulWidget {
  const QAScreen({Key? key}) : super(key: key);

  @override
  State<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;

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
                TextEditingController questionController = TextEditingController(text: question);
                deleteQuestion() async{
                  await FirebaseFirestore.instance.collection('questions').doc(questionID).delete();
                }
                updateQuestion() async{
                  if(questionController.text.isNotEmpty){
                    await FirebaseFirestore.instance.collection('questions').doc(questionID).update(
                        {
                          'question': questionController.text.trim(),
                        });
                    questionController.clear();
                    Navigator.of(context).pop();
                  }
                }
                showQuestionSheet(BuildContext context){
                  return showModalBottomSheet(
                      backgroundColor: CClass.backgroundColor,
                      context: context,
                      builder: (BuildContext context){
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: TextField(
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline,
                                    autofocus: true,
                                    autocorrect: true,
                                    controller: questionController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      labelText: 'Enter Question',
                                      labelStyle: TextStyle(color: CClass.backgroundColor2),
                                      filled: true,
                                      fillColor: CClass.textColor1,
                                    ),
                                    maxLines: 5,
                                    textCapitalization: TextCapitalization.sentences,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        height: 1.5),
                                  ),
                                ),
                                CustomButton(
                                    text: 'Done',
                                    onPressed: (){
                                      setState(() {
                                        updateQuestion();
                                        Navigator.pop(context);
                                      });
                                    },
                                    color: Colors.green,
                                    icon: Icons.check,
                                    textColor: CClass.textColor1
                                )
                              ],
                            ),
                          ],
                        );
                      }
                  );
                }
                showOptionDialog(){
                  showDialog(
                      context: context,
                      builder: (context){
                        return AlertDialog(
                          backgroundColor: CClass.bGColorTheme(),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton.icon(
                                  onPressed: (){
                                    Navigator.pop(context);
                                    showQuestionSheet(context);
                                  },
                                  icon: Icon(Icons.edit,color: Colors.green,),
                                  label: Text('Edit Question',style: TextStyle(color: CClass.textColor1),)
                              ),
                              const SizedBox(height: 10.0,),
                              TextButton.icon(
                                onPressed: (){
                                  deleteQuestion();
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
                    StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('users').doc(ownerId).snapshots(),
                        builder: (context, snapshot) {

                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator(color: CClass.bTColorTheme(),));
                          }
                          Users user = Users.fromDocument(snapshot.data!);
                          return GestureDetector(
                            onLongPress: uid != ownerId ? null : (){
                              showOptionDialog();
                            },
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context){
                              return AnswerScreen(
                                question: question,
                                questionId: questionID,
                                createdAt: createdAt,
                                ownerId: ownerId,
                                ownerPhoto: user.photoURL,
                                ownerName: user.displayName,
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
                                          backgroundImage: CachedNetworkImageProvider(user.photoURL),
                                          backgroundColor: CClass.containerColor,
                                        ),
                                        title: Text(question,
                                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                        subtitle: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context).size.width * 0.5,
                                              child: Text('By ${user.displayName}   - ${timeago.format(createdAt.toDate())} -',
                                              overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            TextButton.icon(
                                                onPressed: (){},
                                                icon: Icon(Icons.question_answer_outlined,color: Colors.green),
                                                label: Text(answers.toString(),style: TextStyle(color: CClass.textColor1),)
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
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