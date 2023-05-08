import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_learn/screens/home/home_screen.dart';

import '../../services/auth_methods.dart';
import '../../utils/color.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_button.dart';
import 'landing_screen.dart';

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
  bool showPass = false;

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
            backgroundColor: CClass.bGColorTheme(),
            title: const Text('Please choose an option'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: (){
                    _getImageFromCamera();
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.camera, color: CClass.textColorTheme(),),
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
            decoration: InputDecoration(
                hintText: 'Enter Email',
                filled: true,
                fillColor: CClass.bGColor2Theme(),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: CClass.secondaryBGColorTheme())
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: CClass.bTColor2Theme()
                    )
                )
            ),
          ),
          const SizedBox(height: 10.0,),
          TextFormField(
            controller: passwordController,
            obscureText: showPass ? false : true,
            decoration: InputDecoration(
                hintText: 'Enter Password',
                filled: true,
                suffixIcon: IconButton(
                    onPressed: (){
                      if(showPass){
                        setState(() {
                          showPass = false;
                        });
                      }else{
                        setState(() {
                          showPass = true;
                        });
                      }
                    },
                    icon: Icon(Icons.remove_red_eye,
                      color: showPass ? CClass.bTColor2Theme() : CClass.textColor2,)
                ),
                fillColor: CClass.bGColor2Theme(),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: CClass.secondaryBGColorTheme())
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: CClass.bTColor2Theme()
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
                  child: Text('Forgot Password',
                    style: TextStyle(color: CClass.bTColor2Theme()),
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
            color: CClass.bTColorTheme(),
            image: 'assets/images/email.png',
            borderColor: CClass.bGColor2Theme(),
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
                    color: CClass.bTColor2Theme()
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
              backgroundColor: CClass.bGColor2Theme(),
              radius: 60,
              backgroundImage: imageFile == null ? const AssetImage('assets/images/user.jpg')
              :
              Image.file(imageFile!).image,
              child: imageFile == null ? Icon(Icons.camera_alt,color: CClass.bGColor2Theme(),size: 60,)
                  :
                  SizedBox()
            ),
          ),
          SizedBox(height: 10,),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter Name',
              filled: true,
              fillColor: CClass.bGColor2Theme(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: CClass.secondaryBGColorTheme())
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: CClass.bTColor2Theme()
                )
              )
            ),
          ),
          const SizedBox(height: 10.0,),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
                hintText: 'Enter Email',
                filled: true,
                fillColor: CClass.bGColor2Theme(),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: CClass.secondaryBGColorTheme())
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: CClass.bTColor2Theme()
                    )
                )
            ),
          ),
          const SizedBox(height: 10.0,),
          TextFormField(
            controller: passwordController,
            obscureText: showPass ? false : true,
            decoration: InputDecoration(
                hintText: 'Enter Password',
                filled: true,
                suffixIcon: IconButton(
                  onPressed: (){
                    if(showPass){
                      setState(() {
                        showPass = false;
                      });
                    }else{
                      setState(() {
                        showPass = true;
                      });
                    }
                  },
                  icon: Icon(Icons.remove_red_eye,
                    color: showPass ? CClass.bTColor2Theme() : CClass.textColor2,)
                ),
                fillColor: CClass.bGColor2Theme(),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: CClass.secondaryBGColorTheme())
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: CClass.bTColor2Theme()
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
                    final ref = FirebaseStorage.instance.ref().child('userImages').child(DateTime.now().microsecondsSinceEpoch.toString());
                    await ref.putFile(imageFile!);
                    imageUrl = await ref.getDownloadURL();

                    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({
                      'displayName': nameController.text.trim(),
                      'email' : emailController.text.trim().toLowerCase(),
                      'uid': FirebaseAuth.instance.currentUser!.uid,
                      'photoURL': imageUrl,
                      'createdAt': DateTime.now().toString(),
                      'totalStars': 0,
                      'occupation': 'Student',
                      'level': '',
                      'school': '',
                      'department': '',
                      'degree' : '',
                      'bio': ''
                    }).then((value) => {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                        return const LandingScreen();
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
            color: CClass.bTColorTheme(),
            image: 'assets/images/email.png',
            borderColor: CClass.bGColor2Theme(),
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
                  child: Text('Login',
                  style: TextStyle(
                    fontSize: 18,
                    color: CClass.bTColor2Theme()
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
              SizedBox(height: 20,),
              firstpage == true ? _buidLoginPage() : _buidSignUpPage(),
              Divider(
                color: CClass.containerColor,
                thickness: 3,
              ),
              CustomButton2(
                text: 'Continue with Google',
                onPressed: () async {
                   await _authMethods.signInWithGoogle(context);
                }, color: CClass.textColorTheme(),
                image: 'assets/images/google.png',
                borderColor: CClass.bTColor2Theme(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
