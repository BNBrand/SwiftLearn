import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/utils/colors.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String? displayName = '';
  String? email = '';
  String? photoURL = '';

  Future _getData() async{
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then((snapshot) async{
      if(snapshot.exists){
        setState(() {
          displayName = snapshot.data()!['displayName'];
          photoURL = snapshot.data()!['photoURL'];
          email = snapshot.data()!['email'];
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
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0.0,
      ),
      drawer: Drawer(
        backgroundColor: backgroundColor,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: secondaryBackgroundColor
              ),
              currentAccountPicture: GestureDetector(
                onTap: (){
                  Navigator.pushNamed(context, '/profileScreen');
                },
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(photoURL!),
                ),
              ),
              accountName: Text(displayName!),
              accountEmail: Text(email!),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(displayName!),
              const SizedBox(height: 10),
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(photoURL!),
                radius: 50
              ),
              const SizedBox(height: 10),
              Text(email!),
            ],
          ),
        ),
      ),
    );
  }
}
