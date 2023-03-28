import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/screens/more/logout.dart';
import 'package:swift_learn/screens/more/profile/profile_screen.dart';

import '../../utils/colors.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {

  int selectedIndex = 0;

  List<Widget> pages = [
    ProfileScreen(profileId: FirebaseAuth.instance.currentUser!.uid,),
    const LogoutScreen(),
  ];
  List<String> title = ['Profile', 'Logout'];
  List<IconData> icons = [Icons.account_box, Icons.logout];

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
