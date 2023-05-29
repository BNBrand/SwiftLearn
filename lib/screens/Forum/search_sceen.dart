import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  String displayNameUser = '';
  String photoURLUser = '';

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
            Future _getData() async{
              await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
                  .get().then((snapshot) async{
                if(snapshot.exists){
                  setState(() {
                    displayNameUser = snapshot.data()!['displayName'];
                    photoURLUser = snapshot.data()!['photoURL'];
                  });
                }
              });
            }
            handleFollow() async{
              await FirebaseFirestore.instance.collection('followers').doc(user.uid)
                  .collection('userFollowers').doc(FirebaseAuth.instance.currentUser!.uid)
                  .set({
                'ownerId': FirebaseAuth.instance.currentUser!.uid,
                'followedAt': DateFormat.yMMMMd().add_jms().format(DateTime.now()),
              });
              await FirebaseFirestore.instance.collection('following').doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('userFollowing').doc(user.uid)
                  .set({
                'ownerId': user.uid,
                'followedAt': DateFormat.yMMMMd().add_jms().format(DateTime.now()),
              });
              await FirebaseFirestore.instance.collection('feed').doc(user.uid)
                  .collection('feedItems').doc(FirebaseAuth.instance.currentUser!.uid)
                  .set({
                'type':'follow',
                'uid':FirebaseAuth.instance.currentUser!.uid,
                'ownerId': user.uid,
                'displayName': displayNameUser,
                'photoURL': photoURLUser,
                'followedAt': Timestamp.now(),
              });
              _getData();
            }
            handleUnfollow() async{
              await FirebaseFirestore.instance.collection('followers').doc(user.uid)
                  .collection('userFollowers').doc(FirebaseAuth.instance.currentUser!.uid)
                  .delete();
              await FirebaseFirestore.instance.collection('following').doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('userFollowing').doc(user.uid)
                  .delete();
              await FirebaseFirestore.instance.collection('feed').doc(user.uid)
                  .collection('feedItems').doc(FirebaseAuth.instance.currentUser!.uid)
                  .delete();
              _getData();
            }
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
                    trailing: user.uid != FirebaseAuth.instance.currentUser!.uid ?
                     StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('followers').doc(user.uid)
                          .collection('userFollowers').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
                      builder: (context, snapshot) {
                        if(!snapshot.hasData){
                          return TextButton.icon(
                            label: Text('Follow',style: TextStyle(color: CClass.buttonColor2),),
                            icon: Icon(Icons.add,color: CClass.buttonColor2,),
                            onPressed: handleUnfollow,
                          );
                        }
                        return snapshot.data!.exists ?
                        TextButton.icon(
                          label: Text('UnFollow',style: TextStyle(color: CClass.buttonColor),),
                          icon: Icon(Icons.close,color: CClass.buttonColor,),
                          onPressed: handleUnfollow,
                        ):
                        TextButton.icon(
                          label: Text('Follow',style: TextStyle(color: CClass.buttonColor2),),
                          icon: Icon(Icons.add,color: CClass.buttonColor2,),
                          onPressed: handleFollow,
                        );
                      }
                    ): null,
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
