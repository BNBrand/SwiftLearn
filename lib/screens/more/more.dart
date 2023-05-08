import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/screens/more/profile/profile_screen.dart';
import '../../services/auth_methods.dart';
import 'package:swift_learn/screens/authenticate/login_screen.dart';
import '../../utils/color.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {

  int selectedIndex = 0;
  void _showImageDialog(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
              backgroundColor: CClass.bGColorTheme(),
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text('Do you want to logout?'),
              ),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                        onTap: () async{
                          AuthMethods().signOut();
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                            return LoginScreen();
                          }));
                        },
                        child: Text('Yes',style: TextStyle(color: CClass.textColorTheme()),)),
                    SizedBox(),
                    InkWell(
                        onTap: ()=> Navigator.pop(context),
                        child: Text('No',style: TextStyle(color: CClass.textColorTheme()),))
                  ],
                ),
              )
          );
        }
    );
  }

  List<Widget> pages = [
    ProfileScreen(profileId: FirebaseAuth.instance.currentUser!.uid,),
    const Text('Logout')
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
              if(index == 1){
                _showImageDialog();
              }else{
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                  return pages[index];
                }));
              }
            },
            child: Card(
              color: CClass.containerColor,
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
