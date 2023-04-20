import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/post_model.dart';
import '../../utils/colors.dart';

class PostScreen extends StatefulWidget {

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {

  bool isLoading = false;
  bool isPost = true;
  bool isSearch = false;
  bool isQuiz = false;
  bool isQA = false;
  List<Post> post = [];

  postsContent() async{
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).get();
    setState(() {
      isLoading = false;
      post = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }
  buildpostsContent(){
    if(isLoading) {
      return const Center(child: CircularProgressIndicator(color: buttonColor2,));
    }
    return Column(children: post,);
  }
  qAContent(){
    return Text('Q&A');
  }
  searchContent(){
    return Text('Search to be transferred here');
  }
  quizContent(){
    return Text('quiz');
  }

  @override
  void initState() {
    postsContent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pushNamed(context, '/uploadForm');
        },
        child: Icon(Icons.upload,color: textColor1,),
        backgroundColor: buttonColor,
      ),
      appBar: AppBar(
        backgroundColor: backgroundColor2,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
                onPressed: (){
                  setState(() {
                    isPost = true;
                    isQA = false;
                    isSearch = false;
                    isQuiz = false;
                  });
                },
                child: Text('Post',style: TextStyle(
                    color: isPost ? buttonColor2 : buttonColor,
                    fontSize: isPost ? 18 : 16
                ),)
            ),
            TextButton(
                onPressed: (){
                  setState(() {
                    isPost = false;
                    isQA = true;
                    isSearch = false;
                    isQuiz = false;
                  });
                },
                child: Text('Q&A',style: TextStyle(
                    color: isQA ? buttonColor2 : buttonColor,
                    fontSize: isQA ? 18 : 16
                ),)
            ),
            TextButton(
                onPressed: (){
                  setState(() {
                    isPost = false;
                    isQA = false;
                    isSearch = false;
                    isQuiz = true;
                  });
                },
                child: Text('Quiz',style: TextStyle(
                    color: isQuiz ? buttonColor2 : buttonColor,
                    fontSize: isQuiz ? 18 : 16
                ),)
            ),
            TextButton(
                onPressed: (){
                  setState(() {
                    isPost = false;
                    isQA = false;
                    isSearch = true;
                    isQuiz = false;
                  });
                },
                child: Text('Search',style: TextStyle(
                    color: isSearch ? buttonColor2 : buttonColor,
                    fontSize: isSearch ? 18 : 16
                ),)
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          isQA ? qAContent() : isSearch ? searchContent() :
          Column(
            children: post,
          ),
        ],
      ),
    );
  }
}
