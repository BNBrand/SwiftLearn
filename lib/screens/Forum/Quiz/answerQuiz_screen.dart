import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/utils/color.dart';

class AnswerQuiz extends StatefulWidget {
  String quizId;
  String? questionId;

  AnswerQuiz({required this.quizId, this.questionId});

  @override
  State<AnswerQuiz> createState() => _AnswerQuizState();
}

class _AnswerQuizState extends State<AnswerQuiz> {
  final PageController _pageController = PageController();

  String uid = FirebaseAuth.instance.currentUser!.uid;
  int currentPage = 0;
  int selectedAnswer = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Quiz'),
        backgroundColor: CClass.backgroundColor2,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('quiz').doc(widget.quizId).collection('questions').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: CClass.bTColor2Theme(),));
          }
          return PageView.builder(
            controller: _pageController,
            onPageChanged: (index){
              setState(() {
                selectedAnswer = 5;
                currentPage = index;
              });
            },
            itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index){
                String option1 = snapshot.data!.docs[index]['option1'];
                String option2 = snapshot.data!.docs[index]['option2'];
                String option3 = snapshot.data!.docs[index]['option3'];
                String option4 = snapshot.data!.docs[index]['option4'];
                int answer = snapshot.data!.docs[index]['answer'];
                String question = snapshot.data!.docs[index]['question'];
                List<String> options = [
                  option1,
                  option2,
                  option3,
                  option4
                ];
                List<String> letters = ['A', 'B', 'C', 'D'];
                handleChoice() async{
                  await FirebaseFirestore.instance.collection('quiz').doc(widget.quizId).collection('questions')
                      .doc(uid).collection('correct').doc(widget.questionId).
                  set({
                    'correct': selectedAnswer == answer ? true : false,
                    'ownerId': uid
                  });
                }
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(question),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                      itemBuilder: (context, index){
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: (){
                              setState(() {
                                selectedAnswer = index;
                              });
                              handleChoice();
                            },
                            child: Card(
                              color: selectedAnswer == index ? CClass.buttonColor : CClass.containerColor,
                              elevation: 10,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: selectedAnswer == index ? CClass.backgroundColor2 : CClass.secondaryBackgroundColor,
                                    child: Text(letters[index])),
                                title: Text(options[index]),
                              ),
                            ),
                          ),
                        );
                      }
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       IconButton(
                          onPressed: currentPage > 0 ? (){
                            _pageController.previousPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeInOut
                            );
                          } : null,
                          icon: Icon(Icons.navigate_before),
                         color: CClass.textColor1,
                         iconSize: 50,
                      ),
                      Text('${currentPage+1}/${snapshot.data!.docs.length}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      IconButton(
                          onPressed: currentPage < snapshot.data!.docs.length - 1 ? (){
                            _pageController.nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeInOut
                            );
                          } : null,
                          icon: Icon(Icons.navigate_next),
                        color: CClass.textColor1,
                        iconSize: 50,
                      ),
                    ],
                  )
                ],
              );
              }
          );
        }
      ),
    );
  }
}
