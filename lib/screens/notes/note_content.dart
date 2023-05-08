import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swift_learn/services/shared_pref_method.dart';
import 'package:swift_learn/utils/color.dart';

class NoteContent extends StatefulWidget {
  String topicId;
  String titleId;
  String topicTitle;

  NoteContent({required this.topicId, required this.titleId,required this.topicTitle});

  @override
  State<NoteContent> createState() => _NoteContentState();
}

class _NoteContentState extends State<NoteContent> {

  TextEditingController noteController = TextEditingController();
  bool isEdit = true;
  String content = '';
  bool isDark = true;
  late final _focusNode = FocusNode(onKey: _handlePressKey);

  KeyEventResult _handlePressKey(FocusNode focusNode,RawKeyEvent event){
    if(event.isKeyPressed(LogicalKeyboardKey.enter)){
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  themeMode(theme) async{
    if(isDark){
      setState((){
        isDark = false;
      });
      await SharePrefClass.saveThemeNote(isDark);
    }else{
      setState((){
        isDark = true;
      });
      await SharePrefClass.saveThemeNote(isDark);
    }
  }
  handleEditNote()async{
    await FirebaseFirestore.instance.collection('notes').doc(FirebaseAuth.instance.currentUser!.uid).collection('course').doc(widget.titleId).collection('topic').doc(widget.topicId)
        .update({
          'content': noteController.text.trim(),
        });
    _getData();
  }
  editNote(){
    isEdit = true;
    noteController = TextEditingController(text: content);
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
      child: TextField(
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        autofocus: true,
        autocorrect: true,
        focusNode: _focusNode,
        controller: noteController,
        decoration: null,
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(
          color: isDark ? CClass.textColor1 : Colors.black,
            fontSize: 16,
            height: 1.5),
      ),
    );
  }
  displayNote(){
    isEdit = false;
    return GestureDetector(
      onDoubleTap: (){
        setState(() {
          setState(() {
            isEdit = true;
            noteController = TextEditingController(text: content);
          });
        });
      },
      child: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
        child: Text(content,
          style: TextStyle(
              color: isDark ? CClass.textColor1 : Colors.black,
              fontSize: 16,
              height: 1.5),
        ),
        ),
    );
  }
  Future _getData() async{
    FirebaseFirestore.instance.collection('notes').doc(FirebaseAuth.instance.currentUser!.uid).collection('course').doc(widget.titleId).collection('topic').doc(widget.topicId)
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
    setState(() {
      content == '' ? isEdit = true : isEdit = false;
    });
    isDark = SharePrefClass.getThemeNote()!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? CClass.backgroundColor : Colors.white70,
      appBar: AppBar(
        backgroundColor: CClass.backgroundColor2,
        elevation: 0.0,
        title: Text(widget.topicTitle),
        centerTitle: true,
        actions: [
          isEdit ? IconButton(
              onPressed: (){
                setState(() {
                  handleEditNote();
                  isEdit = false;
                });
              },
              icon: Icon(Icons.save,color: CClass.textColor1,)
          ): SizedBox(),
          Switch(
            activeColor: Colors.black87,
            activeTrackColor: Colors.white70,
              inactiveTrackColor: Colors.black87,
              value: isDark,
              onChanged: themeMode
          )
        ],
      ),
      body: isEdit ? editNote() : displayNote(),
    );
  }
}
