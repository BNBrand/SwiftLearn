import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/screens/authenticate/login_screen.dart';
import 'package:swift_learn/screens/home/home_screen.dart';
import 'package:swift_learn/screens/more/profile/profile_screen.dart';
import 'package:swift_learn/services/auth_methods.dart';
import 'package:swift_learn/services/shared_pref_method.dart';
import 'package:swift_learn/utils/color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharePrefClass.init();
  FirebaseFirestore.instance.settings;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SwiftLearn',
      theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: CClass.bGColorTheme()),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/profileScreen': (context) => ProfileScreen(profileId: FirebaseAuth.instance.currentUser!.uid),
      },
      home: StreamBuilder(
        stream: AuthMethods().authChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
