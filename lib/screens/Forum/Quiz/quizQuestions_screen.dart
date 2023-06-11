import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/screens/Forum/Quiz/answerQuiz_screen.dart';
import 'package:swift_learn/widgets/custom_button.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../utils/color.dart';
import '../../../utils/utils.dart';

class QuizQuestions extends StatefulWidget {
  String quizId;

  QuizQuestions({required this.quizId});

  @override
  State<QuizQuestions> createState() => _QuizQuestionsState();
}

class _QuizQuestionsState extends State<QuizQuestions> {
  TextEditingController questionController = TextEditingController();
  TextEditingController option1Controller = TextEditingController();
  TextEditingController option2Controller = TextEditingController();
  TextEditingController option3Controller = TextEditingController();
  TextEditingController option4Controller = TextEditingController();
  TextEditingController answerController = TextEditingController();

 String questionId = const Uuid().v4();
 String occupation = 'Student';
  var items = ['A', 'B', 'C', 'D'];
  Future _getData() async{
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then((snapshot) async{
      if(snapshot.exists){
        setState(() {
          occupation = snapshot.data()!['occupation'];
        });
      }
    });
  }
  _handleQuizTitle()async{
    if(option1Controller.text.isNotEmpty && option2Controller.text.isNotEmpty && option3Controller.text.isNotEmpty && option4Controller.text.isNotEmpty && questionController.text.isNotEmpty){
      await FirebaseFirestore.instance.collection('quiz').doc(widget.quizId).collection('questions').doc(questionId).set(
          {
            'question': questionController.text.trim(),
            'questionId': questionId,
            'ownerId': FirebaseAuth.instance.currentUser!.uid,
            'answer': 5,
            'option1': option1Controller.text.trim(),
            'option2': option2Controller.text.trim(),
            'option3': option3Controller.text.trim(),
            'option4': option4Controller.text.trim(),
            'createdAt': DateFormat.yMMMMd().add_jms().format(DateTime.now())
          });
      questionId = const Uuid().v4();
    }else{
      showSnackBar(context, "You must enter a question and four options");
    }
  }
  showQuizSheet(BuildContext context){
    return showModalBottomSheet(
        backgroundColor: CClass.backgroundColor,
        context: context,
        builder: (BuildContext context){
          return SingleChildScrollView(
            child: Column(
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
                    // DropdownButton(
                    //     value: '',
                    //     dropdownColor: CClass.containerColor,
                    //     items: items.map((String items){
                    //       return DropdownMenuItem(
                    //         value: items,
                    //         child: Text(items),
                    //       );
                    //     }).toList(),
                    //     onChanged: (value){
                    //       // setState(() {
                    //       //   items[index] = value!;
                    //       // });
                    //     }
                    // ),
                    const Divider(),
                    TextField(
                      autocorrect: true,
                      controller: option1Controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Enter option A:',
                        labelStyle: TextStyle(color: CClass.backgroundColor2),
                        filled: true,
                        fillColor: CClass.textColor1,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          height: 1.5),
                    ),
                    const Divider(),
                    TextField(
                      autocorrect: true,
                      controller: option2Controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Enter option B:',
                        labelStyle: TextStyle(color: CClass.backgroundColor2),
                        filled: true,
                        fillColor: CClass.textColor1,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          height: 1.5),
                    ),
                    const Divider(),
                    TextField(
                      autocorrect: true,
                      controller: option3Controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Enter option C:',
                        labelStyle: TextStyle(color: CClass.backgroundColor2),
                        filled: true,
                        fillColor: CClass.textColor1,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          height: 1.5),
                    ),
                    const Divider(),
                    TextField(
                      autocorrect: true,
                      controller: option4Controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Enter option D:',
                        labelStyle: TextStyle(color: CClass.backgroundColor2),
                        filled: true,
                        fillColor: CClass.textColor1,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          height: 1.5),
                    ),
                    CustomButton(
                        text: 'Done',
                        onPressed: (){
                          setState(() {
                            _handleQuizTitle();
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
            ),
          );
        }
    );
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
        centerTitle: true,
        title: Text('Quiz Question'),
        backgroundColor: CClass.backgroundColor2,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showQuizSheet(context);
        },
        child: Icon(Icons.quiz_outlined,color: CClass.textColor1,),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('quiz').doc(widget.quizId).collection('questions').orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if(!snapshot.hasData){
              return Center(child: CircularProgressIndicator(color: CClass.bTColor2Theme(),));
            }
            return snapshot.data!.docs.isNotEmpty ? ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, int index){
                  String question = snapshot.data!.docs[index]['question'];
                  String createdAt = snapshot.data!.docs[index]['createdAt'];
                  String questionID = snapshot.data!.docs[index]['questionId'];
                  String ownerID = snapshot.data!.docs[index]['ownerId'];
                  deleteQuiz() async{
                    await FirebaseFirestore.instance.collection('quiz').doc(widget.quizId).collection('questions').doc(questionID).delete();
                  }
                  updateQuestion() async{
                    await FirebaseFirestore.instance.collection('quiz').doc(widget.quizId).collection('questions').doc(questionID).update(
                        {
                          'question': questionController.text.trim().toUpperCase(),
                        });
                  }
                  showDialogBoxUpdate(){
                    setState(() {
                      questionController = TextEditingController(text: question);
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
                                  controller: questionController,
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
                                        questionController.clear();
                                      },
                                      child: const Text('Cancel'),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: CClass.bTColorTheme()
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async{
                                        setState(() {
                                          updateQuestion();
                                        });
                                        Navigator.pop(context);
                                        questionController.clear();
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
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context){
                          return AnswerQuiz(
                              quizId: widget.quizId,
                              questionId: questionID);
                        })),
                        child:GestureDetector(
                          onLongPress: showDialogBoxUpdate,
                          child: Card(
                            color: CClass.containerColor,
                            shadowColor: CClass.buttonColor2,
                            child: ListTile(
                              title: Text(question,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text('Created on $createdAt'),
                              trailing: ownerID == FirebaseAuth.instance.currentUser!.uid ? IconButton(
                                onPressed: deleteQuiz,
                                icon: const Icon(Icons.delete,color: Colors.red,),
                              ):const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                      Divider(color: CClass.containerColor,)
                    ],
                  );
                }
            ):
            const Center(child: Text('Add a question'));
          }
      ),
    );
  }
}
