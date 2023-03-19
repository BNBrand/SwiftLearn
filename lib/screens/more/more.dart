import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/screens/more/logout.dart';
import 'package:swift_learn/screens/more/profile/profile_screen.dart';

import '../../services/auth_methods.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {

  int selectedIndex = 0;

  List<Widget> pages = [
    const LogoutScreen(),
    ProfileScreen(profileId: FirebaseAuth.instance.currentUser!.uid,),
  ];
  List<String> title = ['Logout', 'Profile'];
  List<IconData> icons = [Icons.logout, Icons.account_box];

  @override
  Widget build(BuildContext context) {
    return  ListView.builder(
      itemCount: pages.length,
        itemBuilder: (BuildContext context, int index){
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: (){
              setState(() {
                selectedIndex = index;
              });
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                return pages[index];
              }));
            },
            child: Card(
              color: containerColor,
              child: ListTile(
                leading: Icon(icons[index]),
                title: Text(title[index]),
              ),
            ),
          ),
        );
        }
    );
  }
}