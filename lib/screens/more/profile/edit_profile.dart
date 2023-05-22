import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fstorage;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_learn/screens/more/profile/profile_screen.dart';
import 'package:swift_learn/utils/color.dart';
import 'package:swift_learn/utils/utils.dart';
import 'package:swift_learn/widgets/custom_button.dart';

import '../../../widgets/custum_textField.dart';
import '../../../widgets/loading_image.dart';

class EditProfileScreen extends StatefulWidget {
  String? displayName;
  String? photoURL;
  String? bio;
  String? email;
  String? uid;
  String? occupation;
  String? school;
  String? level;
  String? department;
  String? degree;
  EditProfileScreen({
    this.email,
    this.displayName,
    this.photoURL,
    this.bio,
    this.uid,
    this.degree,
    this.occupation,
    this.department,
    this.level,
    this.school,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController schoolController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController levelController = TextEditingController();
  TextEditingController degreeController = TextEditingController();

  File? imageFile;
  String? imageUrl;
  bool _nameValue = true;
  bool _bioValue = true;
  bool _schoolValue = true;
  bool _degreeValue = true;
  bool _levelValue = true;
  bool _departmentValue = true;
  bool isStudent = true;
  var items = ['Student', 'Teacher'];

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

  void _updatePhotoURL() async{
    String imageName = DateTime.now().microsecondsSinceEpoch.toString();
    fstorage.Reference reference = fstorage.FirebaseStorage.instance.ref().child('userImages').child(imageName);
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
      valideField();
      try{
        if(_nameValue && _bioValue && _levelValue && _schoolValue && _departmentValue && _degreeValue){
          FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
            'displayName': nameController.text,
            'bio': bioController.text,
            'occupation': isStudent ? 'Student': 'Teacher',
            'level': levelController.text.trim(),
            'school': schoolController.text.trim(),
            'department': departmentController.text.trim(),
            'degree' : degreeController.text.trim(),
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

  studentDetail(){
    isStudent = true;
    return Column(
      children: [
        SizedBox(height: 10.0,),
        CustumTextField(
          controller: levelController,
          errorText: _levelValue ? null : 'Educational level must be less than 50 characters',
          labelText: 'Educational Level',
        ),
        CustumTextField(
          controller: schoolController,
          errorText: _schoolValue ? null : 'School must be less than 50 characters',
          labelText: 'School',
        ),
        CustumTextField(
          controller: departmentController,
          errorText: _departmentValue ? null : 'Department must be less than 50 characters',
          labelText: 'Department',
        ),
        CustumTextField(
          controller: degreeController,
          errorText: _degreeValue ? null : 'Degree program must be less than 50 characters',
          labelText: 'Degree Program',
        ),
        CustumTextField(
            controller: bioController,
            errorText: _bioValue ? null : 'Bio must be less than 100 characters',
            labelText: 'Interests /About Yourself'
        ),
      ],
    );
  }
  teacherDetail(){
    isStudent = false;
    return Column(
      children: [
        SizedBox(height: 10.0,),
        CustumTextField(
          controller: levelController,
          errorText: _levelValue ? null : 'Educational level must be less than 50 characters',
          labelText: 'Level Taught',
        ),
        CustumTextField(
          controller: schoolController,
          errorText: _schoolValue ? null : 'School must be less than 50 characters',
          labelText: 'School',
        ),
        CustumTextField(
          controller: departmentController,
          errorText: _departmentValue ? null : 'Department must be less than 50 characters',
          labelText: 'Department',
        ),
        CustumTextField(
            controller: bioController,
            errorText: _bioValue ? null : 'Bio must be less than 100 characters',
            labelText: 'Interests /About Yourself'
        ),
      ],
    );
  }
  valideField(){
    setState(() {
      nameController.text.trim().length < 3 || nameController.text.trim().isEmpty ? _nameValue = false : _nameValue = true;
      bioController.text.trim().length > 100 ? _bioValue = false : _bioValue = true;
      schoolController.text.trim().length > 50 ? _schoolValue = false : _schoolValue = true;
      levelController.text.trim().length > 50 ? _levelValue = false : _levelValue = true;
      departmentController.text.trim().length > 50 ? _departmentValue = false :_departmentValue = true;
      degreeController.text.trim().length > 50 ? _degreeValue = false : _degreeValue = true;
    });
  }

   @override
  void initState() {
     nameController = TextEditingController(text: widget.displayName);
     bioController = TextEditingController(text: widget.bio);
     schoolController = TextEditingController(text: widget.school);
     levelController = TextEditingController(text: widget.level);
     departmentController = TextEditingController(text: widget.department);
     degreeController = TextEditingController(text: widget.degree);
    super.initState();
  }
   @override
   void dispose() {
     super.dispose();
     bioController.dispose();
     nameController.dispose();
     schoolController.dispose();
     levelController.dispose();
     degreeController.dispose();
     departmentController.dispose();
   }

   textField(){
    return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 12),
       child: Column(
         children: [
           const Padding(
             padding: EdgeInsets.all(12.0),
             child: Text('Edit Profile Details',
               style: TextStyle(fontSize: 20),
             ),
           ),
           Divider(thickness: 4, color: CClass.containerColor,),
           DropdownButton(
             value: widget.occupation,
               dropdownColor: CClass.containerColor,
               items: items.map((String items){
                 return DropdownMenuItem(
                   value: items,
                     child: Text(items),
                 );
               }).toList(),
               onChanged: (value){
               setState(() {
                 widget.occupation = value;
               });
               }
           ),
           Divider(),
           TextField(
             controller: nameController,
             textAlign: TextAlign.center,
             decoration: InputDecoration(
               border: InputBorder.none,
               errorText: _nameValue ? null : 'Name is too short or empty',
               errorStyle: TextStyle(color: Colors.red),
               suffixIcon: IconButton(
                 icon: Icon(Icons.clear,color: CClass.textColor2,),
                 onPressed: nameController.clear,
               ),
               labelText: 'User Name',
               labelStyle: TextStyle(color: CClass.textColor2)
             ),
           ),
           Divider(color: CClass.containerColor, thickness: 2,),
           isStudent ? studentDetail() : teacherDetail(),
           CustomButton(
               text: 'Update',
               onPressed: ()async{
                 await updateProfile();
                 await valideField();
                 if(_nameValue && _bioValue && _levelValue && _schoolValue && _departmentValue && _degreeValue){
                   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                     return ProfileScreen(profileId: FirebaseAuth.instance.currentUser!.uid,);
                   }));
                 }
               },
               color: CClass.bTColorTheme(),
               icon: Icons.update,
               textColor: CClass.textColorTheme()
           )
         ],
       ),
     );
   }

  @override
  Widget build(BuildContext context) {
    if(isStudent != null){
      if(widget.occupation == 'Student'){
        setState(() {
          isStudent = true;
        });
      }else{
        setState(() {
          isStudent = false;
        });
      }
    }
    return Scaffold(
      backgroundColor: CClass.bGColorTheme(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                  return ProfileScreen(profileId: FirebaseAuth.instance.currentUser!.uid,);
                }));
              },
              icon: Icon(Icons.check, color: CClass.bTColor2Theme(),))
        ],
        elevation: 0.0,
        backgroundColor: CClass.bGColorTheme(),
      ),
      body: SingleChildScrollView(
        child: Container(
        height: MediaQuery.of(context).size.height * 1.2,
        color: CClass.bGColorTheme(),
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
                      height: innerHeight * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50)
                        ),
                        color: CClass.secondaryBGColorTheme(),
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
                        child: GestureDetector(
                          onTap: (){
                            showDialog(
                                context: context,
                                builder: (context){
                                  return AlertDialog(
                                    content: cachedNetworkImage(widget.photoURL),
                                    scrollable: true,
                                    contentPadding: EdgeInsets.zero,
                                  );
                                }
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: CClass.containerColor,
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
                      ),
                     SizedBox(height: 50,),
                     Divider(color: CClass.containerColor,),
                      textField()
                    ],
                  ),
                ),
              )
            ],
          );
        }),
    ),
      )
    );
  }
}
