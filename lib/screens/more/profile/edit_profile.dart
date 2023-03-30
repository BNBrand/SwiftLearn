import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fstorage;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_learn/screens/more/profile/profile_screen.dart';
import 'package:swift_learn/utils/colors.dart';
import 'package:swift_learn/utils/utils.dart';
import 'package:swift_learn/widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  String? displayName;
  String? photoURL;
  String? bio;
  String? email;
  String? uid;
  EditProfileScreen({
    this.email,
    this.displayName,
    this.photoURL,
    this.bio,
    this.uid
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  File? imageFile;
  String? imageUrl;
  bool _nameValue = true;
  bool _bioValue = true;

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
      setState((){
        imageFile = File(croppedImage.path);
        _updatePhotoURL();
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

  void _updatePhotoURL() async{
    String imageName = DateTime.now().microsecondsSinceEpoch.toString();
    fstorage.Reference reference = fstorage.FirebaseStorage.instance.ref().child('userimages').child(imageName);
    fstorage.UploadTask uploadTask = reference.putFile(File(imageFile!.path));
    fstorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    await taskSnapshot.ref.getDownloadURL().then((url) async{
      imageUrl = url;
    });

    await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
      'photoURL' : imageUrl
    });
  }

  updateProfile(){
    setState(() {
      nameController.text.trim().length < 3 || nameController.text.trim().isEmpty ? _nameValue = false : _nameValue = true;
      bioController.text.trim().length > 100 ? _bioValue = false : _bioValue = true;

      try{
        if(_nameValue && _bioValue){
          FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
            'displayName': nameController.text,
            'bio': bioController.text
          });
          if(imageFile != null){
            FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
              'photoURL': imageUrl,
            });
          }
        }
      }catch(e){
        showSnackBar(context, e.toString());
      }
    });
  }

   @override
  void initState() {
     nameController = TextEditingController(text: widget.displayName);
     bioController = TextEditingController(text: widget.bio);
    super.initState();
  }
   @override
   void dispose() {
     super.dispose();
     bioController.dispose();
     nameController.dispose();
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                  return ProfileScreen(profileId: FirebaseAuth.instance.currentUser!.uid,);
                }));
              },
              icon: const Icon(Icons.check, color: buttonColor2,))
        ],
        elevation: 0.0,
        backgroundColor: backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
            children: [
        Container(
        height: MediaQuery.of(context).size.height * 0.5,
        color: backgroundColor,
        child: LayoutBuilder(builder: (context, constraints){
          double innerHeight = constraints.maxHeight;
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Container(height: 70,),
                    Container(
                      height: innerHeight * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: secondaryBackgroundColor,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: CircleAvatar(
                          backgroundColor: containerColor,
                          radius: 65,
                          backgroundImage: imageFile == null ? CachedNetworkImageProvider(widget.photoURL!):
                          Image.file(imageFile!).image,
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 25,
                                  child: IconButton(
                                    icon: const Icon(Icons.edit,size: 25,),
                                    onPressed: _showImageDialog,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(widget.displayName!,
                              style: const TextStyle(fontSize: 30),
                            ),
                            Text(widget.email!,style: const TextStyle(color: textColor2),),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25,),
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: backgroundColor2,
                        child: Text(widget.bio!,),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        }),
    ),
          const SizedBox(height: 20.0,),
          Container(
            height: MediaQuery.of(context).size.height * 0.57,
            decoration: const BoxDecoration(
                color: secondaryBackgroundColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(50),
                    topLeft: Radius.circular(50)
                )
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('Edit Profile Details',
                    style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const Divider(
                    thickness: 2,
                    color: containerColor,
                  ),
                  TextField(
                    controller: nameController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      errorText: _nameValue ? null : 'Name is too short or empty',
                      errorStyle: TextStyle(color: Colors.red),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: nameController.clear,
                      ),
                      hintText:'Enter Name',
                      labelText: 'User Name',
                    ),
                  ),
                  const SizedBox(height: 20,),
                   TextField(
                     controller: bioController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      errorText: _bioValue ? null : 'Bio must be less than 100 characters',
                      errorStyle: TextStyle(color: Colors.red),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: bioController.clear,
                      ),
                      hintText:'Enter Bio',
                      labelText: 'User Bio',
                    ),
                  ),
                  const SizedBox(height: 20,),
                  CustomButton(
                      text: 'Update',
                      onPressed: updateProfile,
                      color: buttonColor,
                      icon: Icons.update,
                      textColor: textColor1
                  )
                ],
              ),
            ),
          )
    ]
    ),
      )
    );
  }
}
