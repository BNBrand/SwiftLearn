import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_learn/utils/colors.dart';
import 'package:swift_learn/utils/utils.dart';
import 'package:swift_learn/widgets/custom_button.dart';
import 'package:uuid/uuid.dart';

class UploadForm extends StatefulWidget {
  const UploadForm({Key? key}) : super(key: key);

  @override
  State<UploadForm> createState() => _UploadFormState();
}

class _UploadFormState extends State<UploadForm> {

  TextEditingController captionController = TextEditingController();

  File? imageFile;
  String? imageUrl;
  bool isUploading = false;
  String postId = Uuid().v4();

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

  handleSubmit() async{
    setState(() {
      isUploading = true;
    });
    uploadImage();
  }

  uploadImage() async{
    try{
      final ref = await FirebaseStorage.instance.ref().child('postimages').child('post_$postId.jpg');
      await ref.putFile(imageFile!);
      imageUrl = await ref.getDownloadURL();
      
      FirebaseFirestore.instance.collection('post').doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('userpost').doc(postId).set({
        'postId': postId,
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'displayName': FirebaseAuth.instance.currentUser!.displayName,
        'photoURL': FirebaseAuth.instance.currentUser!.photoURL,
        'email': FirebaseAuth.instance.currentUser!.email,
        'image': imageUrl,
        'caption': captionController.text.trim(),
        'createdAt': DateTime.now(),
        'stars': {},
      });
      setState(() {
        imageFile = null;
        isUploading = false;
        postId = Uuid().v4();
      });
      
    }catch(e){
      showSnackBar(context, e.toString());
    }
  }

  
   Scaffold withImage(){
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Container(
              height: 250.0,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(imageFile!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10,),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(FirebaseAuth.instance.currentUser!.photoURL!),
              ),
              title: Container(
                width: 250.0,
                child: TextField(
                  controller: captionController,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: captionController.clear,
                        icon: const Icon(Icons.clear, color: textColor2,)
                    ),
                    border: InputBorder.none,
                    hintText: 'Write a caption...',
                    filled: true,
                    fillColor: backgroundColor2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            CustomButton(
                text: 'Post',
                onPressed: isUploading ? null : handleSubmit,
                color: buttonColor,
              icon: Icons.upload,
              textColor: textColor1,
            ),
            isUploading ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(color: buttonColor,),
                SizedBox(width: 5.0,),
                Text('uploading...'),
              ],
            ) : SizedBox()
          ],
        ),
      ),
    );
  }

  Scaffold withoutImage(){
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: captionController,
                maxLines: 5,
                decoration:  InputDecoration(
                  suffixIcon: IconButton(
                      onPressed: captionController.clear,
                      icon: Icon(Icons.clear, color: textColor2,)
                  ),
                  border: InputBorder.none,
                  hintText: 'Write a caption',
                  filled: true,
                  fillColor: backgroundColor2,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: buttonColor
                      )
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton.icon(
                onPressed: _showImageDialog,
                icon: const Icon(Icons.image,color: textColor1,),
                label: const Text('Add Image',style: TextStyle(color: textColor1),),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return imageFile == null ? withoutImage() : withImage();
  }
}
