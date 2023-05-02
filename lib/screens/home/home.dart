import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/utils/colors.dart';

import '../../models/user_model.dart';
import '../../utils/utils.dart';
import '../../widgets/loading.dart';
import '../authenticate/landing_screen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return showSnackBar(context, 'There is an error');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loading();
          }
          Users user = Users.fromDocument(snapshot.data!);
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
                      backgroundImage: CachedNetworkImageProvider(user.photoURL),
                    ),
                  ),
                  accountName: Text(user.displayName),
                  accountEmail: Text(user.email),
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
                  Text(user.displayName),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return LandingScreen();
                      }));
                    },
                    child: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(user.photoURL),
                      radius: 50
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(user.email),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
