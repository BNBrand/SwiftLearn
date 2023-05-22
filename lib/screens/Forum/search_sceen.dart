import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../utils/color.dart';
import '../more/profile/profile_screen.dart';

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
            return Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.4,),
                Center(child: CircularProgressIndicator(color: CClass.bTColor2Theme(),)),
              ],
            );
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
                      backgroundColor: CClass.secondaryBackgroundColor,
                      backgroundImage: CachedNetworkImageProvider(user.photoURL),
                    ),
                    title: Text(user.displayName, overflow: TextOverflow.ellipsis,),
                    subtitle: Text(user.email, overflow: TextOverflow.ellipsis),
                    trailing: user.uid != FirebaseAuth.instance.currentUser!.uid ? TextButton.icon(
                      label: Text('Follow',style: TextStyle(color: CClass.buttonColor2),),
                      icon: Icon(Icons.add,color: CClass.buttonColor2,),
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.38,),
              Icon(Icons.search, size: 80, color: CClass.containerColor,),
              Text('Search users')
            ],
          ),
        ):
        SingleChildScrollView(child: buildSearchResults(),)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return searchContent();
  }
}
