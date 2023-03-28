import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:swift_learn/models/user_model.dart';
import '../utils/utils.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Users? currentUser;

  Stream<User?> get authChanges => _auth.authStateChanges();
  User get user => _auth.currentUser!;

  Future<bool> signInWithGoogle(BuildContext context) async {
    bool res = false;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      User? user = userCredential.user;
      DocumentSnapshot doc = await _firestore.collection('users').doc(user!.uid).get();

      if (user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          await _firestore.collection('users').doc(user.uid).set({
            'displayName': user.displayName,
            'email' : user.email,
            'uid': user.uid,
            'photoURL': user.photoURL,
            'createdAt': DateTime.now(),
            'bio': ''
          });
           doc = await _firestore.collection('users').doc(user.uid).get();
        }
       currentUser = Users.fromDocument(doc);
        res = true;
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
      res = false;
    }
    return res;
  }
  //Sign in with email and password
  Future<bool> signInWithEmailAndPass(BuildContext context,String email,String password) async{
    bool res = false;
    try{
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      User? user = userCredential.user;

      if (user != null) {
        res = true;
      }
    }on FirebaseAuthException catch (e) {
      showSnackBar(context, e.toString());
      res = false;
    }
    return res;
  }

  //create User With Email and Password
  Future<bool> createUserWithEmailAndPass(BuildContext context,String email,String password,String name) async{
    bool res = false;
    try{
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      User? user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          await _firestore.collection('users').doc(user.uid).set({
            'displayName': user.displayName,
            'email' : user.email,
            'uid': user.uid,
            'photoURL': user.photoURL,
            'createdAt': DateTime.now(),
            'bio': ''
          });
        }
        res = true;
      }
    }on FirebaseAuthException catch (e) {
      showSnackBar(context, e.toString());
      res = false;
    }
    return res;
  }

  //signOut
  void signOut() async {
    try {
      _auth.signOut();
    } catch (e) {
      print(e);
    }
  }
}
