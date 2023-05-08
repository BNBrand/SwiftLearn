import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../utils/color.dart';
import '../more/profile/profile_screen.dart';

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
      return Center(child: CircularProgressIndicator(color: CClass.bTColor2Theme(),));
    }
    return Column(children: post,);
  }
  qAContent(){
    return Text('Q&A');
  }
  searchContent(){
    return Column(
      children: [
        TextField(
          controller: searchController,
          onChanged: (val) {
            setState(() {
              searchController.text.isEmpty ? null :
              handleSearch(val);
            });
          },
          onSubmitted: handleSearch,
          decoration: InputDecoration(
              filled: true,
              fillColor: CClass.bGColor2Theme(),
              border: InputBorder.none,
              hintText: 'Search',
              prefixIcon: Icon(Icons.search, color: CClass.textColorTheme(),),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: CClass.textColorTheme(),),
                onPressed: (){
                  setState(() {
                    searchController.clear();
                  });
                },
              )
          ),
        ),
        searchController.text.isEmpty ?
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 80, color: CClass.containerColor,),
              Text('Search users')
            ],
          ),
        ):
        SingleChildScrollView(child: buildSearchResults(),)
      ],
    );
  }
  quizContent(){
    return Text('Quiz');
  }
  TextEditingController searchController = TextEditingController();

  Future<QuerySnapshot>? searchResultFuture;

  handleSearch(String query){
    Future<QuerySnapshot> users = FirebaseFirestore.instance.collection('users')
        .where('displayName', isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResultFuture = users;
    });
  }
  buildSearchResults(){
    return FutureBuilder(
        future: searchResultFuture,
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: CClass.bTColor2Theme(),));
          }
          List<Padding> searchResults = [];
          snapshot.data!.docs.forEach((doc) {
            Users user = Users.fromDocument(doc);
            searchResults.add(
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return ProfileScreen(profileId: user.uid);
                    }));
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: CClass.secondaryBGColorTheme(),
                      backgroundImage: CachedNetworkImageProvider(user.photoURL),
                    ),
                    title: Text(user.displayName, overflow: TextOverflow.ellipsis,),
                    subtitle: Text(user.email, overflow: TextOverflow.ellipsis),
                    trailing: user.uid != FirebaseAuth.instance.currentUser!.uid ? TextButton.icon(
                      label: Text('Follow',style: TextStyle(color: CClass.bTColor2Theme()),),
                      icon: Icon(Icons.add,color: CClass.bTColor2Theme(),),
                      onPressed: (){},
                    )
                        :
                    null,
                  ),
                ),
              ),
            );
          });
          return Column(
              children: searchResults
          );
        }
    );
  }

  @override
  void initState() {
    postsContent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isPost ? FloatingActionButton(
        onPressed: (){
          Navigator.pushNamed(context, '/uploadForm');
        },
        child: Icon(Icons.upload,color: CClass.textColorTheme(),),
        backgroundColor: CClass.bTColorTheme(),
      ) : null,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: CClass.bGColor2Theme(),
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
                    color: isPost ? CClass.bTColor2Theme() : CClass.bTColorTheme(),
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
                    color: isQA ? CClass.bTColor2Theme() : CClass.bTColorTheme(),
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
                    color: isQuiz ? CClass.bTColor2Theme() : CClass.bTColorTheme(),
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
                    color: isSearch ? CClass.bTColor2Theme() : CClass.bTColorTheme(),
                    fontSize: isSearch ? 18 : 16
                ),)
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          isQA ? qAContent() : isSearch ? searchContent() : isQuiz ? quizContent() :
          Column(
            children: post,
          ),
        ],
      ),
    );
  }
}
