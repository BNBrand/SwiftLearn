import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/screens/notes/notes_course.dart';
import 'package:uuid/uuid.dart';

import '../../utils/color.dart';

class NoteScreen extends StatefulWidget {


  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  TextEditingController titleController = TextEditingController();
  String titleId = const Uuid().v4();

  showDialogBox(){
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
                          handleNote();
                          });
                          Navigator.pop(context);
                          titleController.clear();
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
  handleNote()async{
    await FirebaseFirestore.instance.collection('notes').doc(FirebaseAuth.instance.currentUser!.uid).collection('course').doc(titleId).set(
        {
          'courseTitle': titleController.text.trim().toUpperCase(),
          'titleId': titleId,
          'createdAt': DateTime.now().toString()
        });
    titleId = const Uuid().v4();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: showDialogBox,
        child: Icon(Icons.add,color: CClass.textColorTheme(),),
        backgroundColor: CClass.bTColorTheme(),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.0,
        centerTitle: true,
        title: Text('Notes'),
        backgroundColor: CClass.bGColor2Theme(),
      ),
   body: StreamBuilder(
     stream: FirebaseFirestore.instance.collection('notes').doc(FirebaseAuth.instance.currentUser!.uid).collection('course').orderBy('createdAt', descending: true).snapshots(),
     builder: (context, snapshot) {
       if(!snapshot.hasData){
         return Center(child: CircularProgressIndicator(color: CClass.bTColor2Theme(),));
       }
       return snapshot.data!.docs.isNotEmpty ? ListView.builder(
         itemCount: snapshot.data!.docs.length,
           itemBuilder: (context, int index){
           String title = snapshot.data!.docs[index]['courseTitle'];
           String createdAt = snapshot.data!.docs[index]['createdAt'];
           String titleID = snapshot.data!.docs[index]['titleId'];
           return Column(
             children: [
               GestureDetector(
                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context){
                   return NoteCourse(title: title,
                     titleId: titleID,);
                 })),
                 child: ListTile(
                   title: Text(title,
                     style: TextStyle(
                       fontWeight: FontWeight.bold,
                       fontSize: 20,
                     ),
                     overflow: TextOverflow.ellipsis,
                   ),
                   subtitle: Text(createdAt),
                 ),
               ),
               Divider(color: CClass.containerColor,)
             ],
           );
           }
       ):
       const Center(child: Text('Add a Course'));
     }
   ),
    );
  }
}
