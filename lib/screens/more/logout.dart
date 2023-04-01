import 'package:flutter/material.dart';
import 'package:swift_learn/screens/authenticate/login_screen.dart';

import '../../services/auth_methods.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({Key? key}) : super(key: key);

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {

  void _showImageDialog(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
              backgroundColor: backgroundColor,
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
                        child: Text('Yes',style: TextStyle(color: textColor1),)),
                     SizedBox(),
                     InkWell(
                       onTap: ()=> Navigator.pop(context),
                         child: Text('No',style: TextStyle(color: textColor1),))
                  ],
                ),
              )
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0.0,
      ),
      body: Center(
        child: CustomButton(
          text: 'Log Out',
          onPressed: _showImageDialog,
          color: buttonColor, icon: Icons.logout,
          textColor: textColor1,
        ),
      ),
    );
  }
}
