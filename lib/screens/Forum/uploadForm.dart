import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_learn/screens/Forum/forum_screen.dart';
import 'package:swift_learn/utils/colors.dart';
import 'package:swift_learn/utils/utils.dart';
import 'package:swift_learn/widgets/custom_button.dart';
import 'package:uuid/uuid.dart';

class UploadForm extends StatefulWidget {

  @override
  State<UploadForm> createState() => _UploadFormState();
}

class _UploadFormState extends State<UploadForm> {

  TextEditingController captionController = TextEditingController();

  File? imageFile;
  String? imageUrl;
  bool isUploading = false;
  String postId = const Uuid().v4();
  String? displayName = '';
  String? email = '';
  String? photoURL = '';

  Future _getData() async{
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then((snapshot) async{
      if(snapshot.exists){
        setState(() {
          displayName = snapshot.data()!['displayName'];
          photoURL = snapshot.data()!['photoURL'];
          email = snapshot.data()!['email'];
        });
      }
    });
  }

  @override
  void initState() {
    _getData();
    super.initState();
  }

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

  handleSubmit() async{
    setState(() {
      isUploading = true;
    });
    uploadImage();
  }

  uploadImage() async{
    try{
      final ref = FirebaseStorage.instance.ref().child('postImages').child('post_$postId.jpg');
      await ref.putFile(imageFile!);
      imageUrl = await ref.getDownloadURL();

      FirebaseFirestore.instance.collection('posts')
          .doc(postId).set({
        'postId': postId,
        'ownerId': FirebaseAuth.instance.currentUser!.uid,
        'displayName': displayName,
        'photoURL': photoURL,
        'email': email,
        'postImage': imageUrl,
        'caption': captionController.text.trim(),
        'createdAt': Timestamp.now(),
        'stars': 0,
        'comments': 0
      });
      setState(() {
        imageFile = null;
        isUploading = false;
        postId = const Uuid().v4();
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
                backgroundImage: CachedNetworkImageProvider(photoURL!),
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
            ) : TextButton.icon(
              onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                  return PostScreen();
                }));
              },
              icon: const Icon(Icons.cancel,color: textColor1,),
              label: const Text('Cancel',style: TextStyle(color: textColor1),),
            ),
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
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: captionController,
                maxLines: 5,
                decoration:  InputDecoration(
                  suffixIcon: IconButton(
                      onPressed: captionController.clear,
                      icon: const Icon(Icons.clear, color: textColor2,)
                  ),
                  border: InputBorder.none,
                  hintText: 'Write a caption',
                  filled: true,
                  fillColor: backgroundColor2,
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                          color: buttonColor
                      )
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextButton.icon(
                    onPressed: _showImageDialog,
                    icon: const Icon(Icons.image,color: textColor1,),
                    label: const Text('Add Image',style: TextStyle(color: textColor1),),
                  ),
                  TextButton.icon(
                    onPressed: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                        return PostScreen();
                      }));
                    },
                    icon: const Icon(Icons.cancel,color: textColor1,),
                    label: const Text('Cancel',style: TextStyle(color: textColor1),),
                  ),
                ],
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
