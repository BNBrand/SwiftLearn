import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/utils/color.dart';

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
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return showSnackBar(context, 'There is an error');
          }

          if (!snapshot.hasData) {
            return const Loading();
          }
          Users user = Users.fromDocument(snapshot.data!);
        return Scaffold(
          backgroundColor: CClass.bGColorTheme(),
          appBar: AppBar(
            backgroundColor: CClass.bGColorTheme(),
            elevation: 0.0,
          ),
          drawer: Drawer(
            backgroundColor: CClass.bGColorTheme(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: CClass.secondaryBGColorTheme()
                  ),
                  currentAccountPicture: GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(context, '/profileScreen');
                    },
                    child: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(user.photoURL),
                    ),
                  ),
                  accountName: Text(user.displayName,style: TextStyle(color: CClass.textColorTheme()),),
                  accountEmail: Text(user.email,style: TextStyle(color: CClass.textColorTheme())),
                ),
                GestureDetector(
                  onTap: (){
                    showAboutDialog(
                        context: context,
                      applicationName: 'SwiftLearn',
                      applicationVersion: '1.0.0',
                      applicationLegalese: 'BNBrand Copyright @ 2023'
                    );
                  },
                    child: Text('About')
                )
              ],
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(user.displayName,style: TextStyle(color: CClass.textColor1)),
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
                  Text(user.email,style: TextStyle(color: CClass.textColor1)),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
