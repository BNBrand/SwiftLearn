import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_learn/utils/colors.dart';
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
                SizedBox(height: 10.0,),
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
                Navigator.pop(context);
              },
              icon: Icon(Icons.check, color: buttonColor2,))
        ],
        elevation: 0.0,
        backgroundColor: backgroundColor,
      ),
      body: Column(
          children: [
      Container(
      height: MediaQuery.of(context).size.height * 0.33,
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
              child: Container(
                height: innerHeight * 0.7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: secondaryBackgroundColor,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 70,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(widget.displayName!,
                            style: const TextStyle(fontSize: 30),
                          ),
                          Text(widget.email!)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: containerColor,
                      radius: 70,
                      backgroundImage: CachedNetworkImageProvider(widget.photoURL!),
                    ),
                    Positioned(
                      bottom: 0.0,
                      right: 0.0,
                      child: CircleAvatar(
                        radius: 25,
                        child: IconButton(
                          icon: Icon(Icons.edit,color: buttonColor2,),
                          onPressed: _showImageDialog,
                        )
                      ),
                    )
                  ],
                ),
              ),
            ),
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
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('Edit Profile Details',
                  style: TextStyle(fontSize: 20),
                  ),
                ),
                Divider(
                  thickness: 2,
                  color: containerColor,
                ),
                TextField(
                  controller: nameController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
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
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: bioController.clear,
                    ),
                    hintText:'Enter Bio',
                    labelText: 'User Bio',
                  ),
                ),
                SizedBox(height: 20,),
                CustomButton(
                    text: 'Update',
                    onPressed: (){},
                    color: buttonColor,
                    icon: Icons.update,
                    textColor: textColor1
                )
              ],
            ),
          ),
        )
    ]
    )
    );
  }
}
