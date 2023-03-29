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
              title: const Text('Do you want to logout'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                      onPressed: () async{
                        AuthMethods().signOut();
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                          return const LoginScreen();
                        }));
                      },
                      icon: Icon(Icons.check, color: Colors.green,),
                      label: Text('Yes',style: TextStyle(color: textColor1),)
                  ),
                  TextButton.icon(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.clear,color: Colors.red,),
                      label: Text('No',style: TextStyle(color: textColor1),)
                  ),
                ],
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
