import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../utils/color.dart';
import 'note_content.dart';

class NoteCourse extends StatefulWidget {
  String title;
  String titleId;
  NoteCourse({required this.title,required this.titleId});

  @override
  State<NoteCourse> createState() => _NoteCourseState();
}

class _NoteCourseState extends State<NoteCourse> {
  TextEditingController topicController = TextEditingController();
  String topicId = const Uuid().v4();
  String content = '';

  showDialogBox(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            backgroundColor: CClass.bGColorTheme(),
            title: Column(
              children: [
                const Text('Enter Topic Title'),
                const SizedBox(height: 30,),
                TextField(
                  controller: topicController,
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
                        topicController.clear();
                      },
                      child: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: CClass.bTColorTheme()
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async{
                        setState(() {
                          handleNoteTopic();
                        });
                        Navigator.pop(context);
                        topicController.clear();
                      },
                      child: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: CClass.bTColorTheme()
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        }
    );
  }
  handleNoteTopic()async{
    await FirebaseFirestore.instance.collection('notes').doc(FirebaseAuth.instance.currentUser!.uid).collection('course').doc(widget.titleId).collection('topic').doc(topicId).set(
        {
          'topicTitle': topicController.text.trim().toUpperCase(),
          'topicId': topicId,
          'createdAt': DateFormat.yMMMMd().add_jms().format(DateTime.now()),
          'content': '',
        });
    topicId = const Uuid().v4();
  }
  Future _getData() async{
    FirebaseFirestore.instance.collection('notes').doc(FirebaseAuth.instance.currentUser!.uid).collection('course').doc(widget.titleId).collection('topic').doc(topicId)
        .get().then((snapshot){
      if(snapshot.exists){
        setState(() {
          content = snapshot.data()!['content'];
        });
      }
    });
  }
  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: showDialogBox,
        child: Icon(Icons.note_add,color: CClass.textColorTheme(),),
        backgroundColor: CClass.bTColorTheme(),
      ),
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: CClass.bGColor2Theme(),
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('notes').doc(FirebaseAuth.instance.currentUser!.uid).collection('course').doc(widget.titleId).collection('topic').orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if(!snapshot.hasData){
              return Center(child: CircularProgressIndicator(color: CClass.bTColor2Theme(),));
            }
            return snapshot.data!.docs.isNotEmpty ? GridView.builder(
              itemCount: snapshot.data!.docs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, int index){
                  String topicTitle = snapshot.data!.docs[index]['topicTitle'];
                  String content = snapshot.data!.docs[index]['content'];
                  String topicID = snapshot.data!.docs[index]['topicId'];
                  _deleteNote() async{
                    await FirebaseFirestore.instance.collection('notes')
                        .doc(FirebaseAuth.instance.currentUser!.uid).collection('course')
                        .doc(widget.titleId).collection('topic').doc(topicID).delete();
                  }
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context){
                    return NoteContent(
                      topicId: topicID,
                      titleId: widget.titleId,
                      topicTitle: topicTitle,
                    );
                  })),
                  child: Card(
                    color: CClass.containerColor,
                    shadowColor: CClass.buttonColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: ListTile(
                      title: Text(topicTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(content,overflow: TextOverflow.ellipsis,),
                      trailing: IconButton(
                        onPressed: _deleteNote,
                        icon: Icon(Icons.delete),
                      ),
                    ),
                  ),
                );
                }
            ):
            const Center(child: Text('Add a Topic'));
          }
        ),
      ),
    );
  }
}
