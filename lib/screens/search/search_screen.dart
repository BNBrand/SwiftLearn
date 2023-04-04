import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/screens/more/profile/profile_screen.dart';
import 'package:swift_learn/utils/colors.dart';

import '../../models/user_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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
            return const Center(child: CircularProgressIndicator(color: buttonColor2,));
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
                     backgroundColor: secondaryBackgroundColor,
                     backgroundImage: CachedNetworkImageProvider(user.photoURL),
                   ),
                   title: Text(user.displayName),
                   subtitle: Text(user.email),
                   trailing: user.uid != FirebaseAuth.instance.currentUser!.uid ? TextButton.icon(
                     label: Text('Follow',style: TextStyle(color: buttonColor2),),
                     icon: Icon(Icons.add,color: buttonColor2,),
                     onPressed: (){},
                   )
                   :
                   null,
                 ),
               ),
             ),
           );
          });
        return ListView(
          children: searchResults
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: backgroundColor2,
        title: TextField(
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
            fillColor: backgroundColor2,
            border: InputBorder.none,
            hintText: 'Search',
            prefixIcon: const Icon(Icons.search, color: textColor1,),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: textColor1,),
              onPressed: (){
                setState(() {
                  searchController.clear();
                });
              },
            )
          ),
        ),
      ),
      body:  searchController.text.isEmpty ?
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: containerColor,),
            Text('Search users')
          ],
        ),
      ):
      buildSearchResults(),
    );
  }
}
