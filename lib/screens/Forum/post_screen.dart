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
  int postCount = 0;
  int starCount = 0;
  List<Post> post = [];

  postsContent() async{
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      post = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }
  buildpostsContent(){
    if(isLoading) {
      return const Center(child: CircularProgressIndicator(color: buttonColor2,));
    }
    return Column(children: post,);
  }

  @override
  void initState() {
    postsContent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor2,
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            icon: Icon(Icons.upload,color: buttonColor2,size: 25,),
            label: Text('Upload',style: TextStyle(color: buttonColor2,fontSize: 18),),
            onPressed: (){
              Navigator.pushNamed(context, '/uploadForm');
            },
          )
        ],
      ),
      body: ListView(
        children: [
          Column(
            children: post,
          )
        ],
      ),
    );
  }
}
