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
          onPressed: () async{
          AuthMethods().signOut();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
            return const LoginScreen();
    }));
    },
          color: buttonColor, icon: Icons.logout,
          textColor: textColor1,
        ),
      ),
    );
  }
}
