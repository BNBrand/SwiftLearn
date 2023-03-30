import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_learn/screens/home/home_screen.dart';
import 'package:swift_learn/utils/colors.dart';

import '../../services/auth_methods.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final AuthMethods _authMethods = AuthMethods();
  bool firstpage = true;
  String? imageUrl;
  File? imageFile;

  void _getImageFromCamera() async{
    Navigator.pop(context);
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    _croppedImage(pickedFile!.path);
  }

  void _getImageFromGallery() async{
    Navigator.pop(context);
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    _croppedImage(pickedFile!.path);
  }

  void _croppedImage(filePath) async{
    CroppedFile? croppedImage = await ImageCropper().cropImage(sourcePath: filePath,
        maxHeight: 1080, maxWidth: 1080
    );
    if(croppedImage != null){
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void _showImageDialog(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            backgroundColor: backgroundColor,
            title: const Text('Please choose an option'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: (){
                    _getImageFromCamera();
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.camera, color: textColor1,),
                      ),
                      Text('Camera')
                    ],
                  ),
                ),
                const SizedBox(height: 10.0,),
                InkWell(
                  onTap: (){
                    _getImageFromGallery();
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.image),
                      ),
                      Text('Gallery')
                    ],
                  ),
                )
              ],
            ),
          );
        }
    );
  }


  Padding _buidLoginPage(){
    firstpage = true;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20,),
          const SizedBox(height: 10.0,),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
                hintText: 'Enter Email',
                filled: true,
                fillColor: backgroundColor2,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: secondaryBackgroundColor)
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: buttonColor2
                    )
                )
            ),
          ),
          const SizedBox(height: 10.0,),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
                hintText: 'Enter Password',
                filled: true,
                fillColor: backgroundColor2,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: secondaryBackgroundColor)
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: buttonColor2
                    )
                )
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              TextButton(
                  onPressed: (){},
                  child: const Text('Forgot Password',
                    style: TextStyle(color: buttonColor2),
                  )
              )
            ],
          ),
          CustomButton2(
            text: 'Login with Email',
            onPressed: () async {
              bool res = await _authMethods.signInWithEmailAndPass(context,
                  emailController.text.trim(),
                  passwordController.text.trim()
              );
              if(res){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                  return HomeScreen();
                }));
              }
            },
            color: buttonColor,
            image: 'assets/images/email.png',
            borderColor: backgroundColor2,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account ?"),
              TextButton(
                  onPressed: (){
                    setState(() {
                      firstpage = false;
                    });
                  },
                  child: Text('Sign Up',
                  style: TextStyle(
                    fontSize: 18,
                    color: buttonColor2
                  ),
                  )
              )
            ],
          )
        ],
      ),
    );
  }
  Padding _buidSignUpPage(){
    firstpage = false;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _showImageDialog,
            child: CircleAvatar(
              backgroundColor: backgroundColor2,
              radius: 60,
              backgroundImage: imageFile == null ? const AssetImage('assets/images/user.jpg')
              :
              Image.file(imageFile!).image,
              child: imageFile == null ? Icon(Icons.camera_alt,color: backgroundColor2,size: 60,)
                  :
                  SizedBox()
            ),
          ),
          SizedBox(height: 10,),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Enter Name',
              filled: true,
              fillColor: backgroundColor2,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: secondaryBackgroundColor)
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: buttonColor2
                )
              )
            ),
          ),
          const SizedBox(height: 10.0,),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
                hintText: 'Enter Email',
                filled: true,
                fillColor: backgroundColor2,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: secondaryBackgroundColor)
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: buttonColor2
                    )
                )
            ),
          ),
          const SizedBox(height: 10.0,),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
                hintText: 'Enter Password',
                filled: true,
                fillColor: backgroundColor2,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: secondaryBackgroundColor)
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: buttonColor2
                    )
                )
            ),
          ),
          CustomButton2(
            text: 'Signup with Email',
            onPressed: () async {
              if(nameController.text.isNotEmpty && emailController.text.isNotEmpty && imageFile != null){
                bool res = await _authMethods.createUserWithEmailAndPass(context,
                    emailController.text.trim(),
                    passwordController.text.trim(),
                    nameController.text.trim()
                );
                try{
                  if (res) {
                    final ref = FirebaseStorage.instance.ref().child('userimages').child(DateTime.now().microsecondsSinceEpoch.toString());
                    await ref.putFile(imageFile!);
                    imageUrl = await ref.getDownloadURL();

                    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({
                      'displayName': nameController.text,
                      'email' : emailController.text,
                      'uid': FirebaseAuth.instance.currentUser!.uid,
                      'photoURL': imageUrl,
                      'createdAt': DateTime.now(),
                      'bio': ''
                    }).then((value) => {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                        return HomeScreen();
                      }))
                    });
                  }
                }catch(e){
                  showSnackBar(context, e.toString());
                }
              }else{
                showSnackBar(context, "You must enter a name,email,password and profile photo");
              }
            },
            color: buttonColor,
            image: 'assets/images/email.png',
            borderColor: backgroundColor2,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account ?'),
              TextButton(
                  onPressed: (){
                    setState(() {
                      firstpage = true;
                    });
                  },
                  child: const Text('Login',
                  style: TextStyle(
                    fontSize: 18,
                    color: buttonColor2
                  ),
                  )
              )
            ],
          )
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              firstpage == true ? _buidLoginPage() : _buidSignUpPage(),
              Divider(
                color: containerColor,
                thickness: 3,
              ),
              CustomButton2(
                text: 'Continue with Google',
                onPressed: () async {
                  bool res = await _authMethods.signInWithGoogle(context);
                  if (res) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                      return HomeScreen();
                    }));
                  }
                }, color: textColor1,
                image: 'assets/images/google.png',
                borderColor: buttonColor2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
