import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_learn/screens/Forum/Q&A/q&a_screen.dart';
import 'package:swift_learn/screens/Forum/Quiz/quiz_sceen.dart';
import 'package:swift_learn/screens/Forum/search_sceen.dart';
import 'package:swift_learn/screens/Forum/social_media/post_screen.dart';
import 'package:uuid/uuid.dart';
import '../../utils/color.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_button.dart';
import 'social_media/comments.dart';
import 'package:intl/intl.dart';

class ForumScreen extends StatefulWidget {

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> with SingleTickerProviderStateMixin {

  TextEditingController captionController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController questionController = TextEditingController();
  TextEditingController quizController = TextEditingController();
  Future<QuerySnapshot>? searchResultFuture;
  PageController pageController = PageController();
  TabController? tabController;
  bool isLoading = false;
  File? imageFile;
  String? imageUrl;
  bool isUploading = false;
  String postId = const Uuid().v4();
  String questionId = const Uuid().v4();
  String quizId = const Uuid().v4();
  String displayNameUser = '';
  String occupation = '';
  String photoURLUser = '';
  int selectedIndex = 0;

  Future _getData() async{
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then((snapshot) async{
      if(snapshot.exists){
        setState(() {
          displayNameUser = snapshot.data()!['displayName'];
          photoURLUser = snapshot.data()!['photoURL'];
          occupation = snapshot.data()!['occupation'];
        });
      }
    });
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
  handleSubmit() async{
    setState(() {
      isUploading = true;
    });
    await uploadImage();
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
        'displayName': displayNameUser,
        'photoURL': photoURLUser,
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
  withImage(){
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            SizedBox(
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
                backgroundImage: CachedNetworkImageProvider(photoURLUser!),
              ),
              title: Container(
                width: 250.0,
                child: TextField(
                  controller: captionController,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: captionController.clear,
                        icon: Icon(Icons.clear, color: CClass.textColor2,)
                    ),
                    border: InputBorder.none,
                    hintText: 'Write a caption...',
                    filled: true,
                    fillColor: CClass.bGColor2Theme(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            CustomButton(
              text: 'Post',
              onPressed: isUploading ? null : handleSubmit,
              color: CClass.bTColorTheme(),
              icon: Icons.upload,
              textColor: CClass.textColorTheme(),
            ),
            isUploading ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: CClass.bTColorTheme(),),
                SizedBox(width: 5.0,),
                Text('uploading...'),
              ],
            ) : TextButton.icon(
              onPressed: (){
                setState(() {
                  imageFile = null;
                });
              },
              icon: Icon(Icons.cancel,color: CClass.textColorTheme(),),
              label: Text('Cancel',style: TextStyle(color: CClass.textColorTheme()),),
            ),
          ],
        ),
      ),
    );
  }
  showComments(BuildContext context, { required String postId, required String ownerId, required String postImage}){
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return Comments(
          postId: postId,
          postImage: postImage,
          ownerId: ownerId
      );
    }));
  }
  _handleQuestion()async{
    if(questionController.text.isNotEmpty){
      await FirebaseFirestore.instance.collection('questions').doc(questionId).set(
          {
            'question': questionController.text.trim(),
            'questionId': questionId,
            'ownerId': FirebaseAuth.instance.currentUser!.uid,
            'createdAt': Timestamp.now(),
            'photoURL': photoURLUser,
            'displayName': displayNameUser,
            'answers': 0,
          });
      questionController.clear();
      questionId = const Uuid().v4();
      Navigator.of(context).pop();
    }else{
      Navigator.of(context).pop();
    }
  }
  _handleQuizCourse()async{
    await FirebaseFirestore.instance.collection('quiz').doc(quizId).set(
        {
          'quizTitle': quizController.text.trim().toUpperCase(),
          'quizId': quizId,
          'ownerId': FirebaseAuth.instance.currentUser!.uid,
          'photoURL': photoURLUser,
          'displayName': displayNameUser,
          'createdAt': DateFormat.yMMMMd().add_jms().format(DateTime.now())
        });
    quizId = const Uuid().v4();
  }
  _showQuestionSheet(BuildContext context){
    return showModalBottomSheet(
      backgroundColor: CClass.backgroundColor,
        context: context,
        builder: (BuildContext context){
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  autofocus: true,
                  autocorrect: true,
                  controller: questionController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Enter Question',
                    labelStyle: TextStyle(color: CClass.backgroundColor2),
                    filled: true,
                    fillColor: CClass.textColor1,
                  ),
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      height: 1.5),
                ),
              ),
              CustomButton(
                  text: 'Done',
                  onPressed: (){
                    setState(() {
                      _handleQuestion();
                    });
                  },
                  color: Colors.green,
                  icon: Icons.check,
                  textColor: CClass.textColor1
              )
            ],
          ),
        ],
      );
        }
    );
  }
  _showQuizDialog(BuildContext context){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            backgroundColor: CClass.bGColorTheme(),
            title: Column(
              children: [
                const Text('Enter Quiz Title'),
                const SizedBox(height: 30,),
                TextField(
                  controller: quizController,
                  decoration: InputDecoration(
                      hintText: 'Enter Title',
                      filled: true,
                      fillColor: CClass.containerColor,
                      border: InputBorder.none
                  ),
                ),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                        quizController.clear();
                      },
                      child: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: CClass.bTColorTheme()
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async{
                        setState(() {
                         _handleQuizCourse();
                        });
                        Navigator.pop(context);
                        quizController.clear();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: CClass.bTColorTheme()
                      ),
                      child: const Text('Done'),
                    )
                  ],
                ),
              ],
            ),
          );
        }
    );
  }
  showDialogBox(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            backgroundColor: CClass.bGColorTheme(),
            title: Column(
              children: [
                const Text('Enter Course'),
                const SizedBox(height: 30,),
                TextField(
                  controller: quizController,
                  decoration: InputDecoration(
                      hintText: 'Enter Title',
                      filled: true,
                      fillColor: CClass.containerColor,
                      border: InputBorder.none
                  ),
                ),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                        quizController.clear();
                      },
                      child: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: CClass.bTColorTheme()
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async{
                        setState(() {
                          _handleQuizCourse();
                        });
                        Navigator.pop(context);
                        quizController.clear();
                      },
                      child: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: CClass.bTColorTheme()
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        }
    );
  }

  @override
  void initState() {
    tabController = TabController(length: 4, vsync: this);
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    tabController!.addListener(() {
      selectedIndex = tabController!.index;
    });
    _getData();
    return imageFile != null ?  withImage() :
    Scaffold(
      floatingActionButton: selectedIndex == 0 ? FloatingActionButton(
        onPressed: (){
          _showQuestionSheet(context);
        },
        child: Icon(Icons.question_mark,color: CClass.textColor1,),
        backgroundColor: Colors.green,
      ):
      selectedIndex == 1 ? FloatingActionButton(
        onPressed: _showImageDialog,
        child: Icon(Icons.upload,color: CClass.textColor1,),
        backgroundColor: CClass.buttonColor,
      ):
      selectedIndex == 2 ? FloatingActionButton(
        onPressed: (){
          _showQuizDialog(context);
        },
        child: Icon(Icons.quiz,color: CClass.textColor1,),
        backgroundColor: Colors.red,
      ):null,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: CClass.backgroundColor2,
        automaticallyImplyLeading: false,
        title: TabBar(
          indicatorColor: selectedIndex == 0 ? Colors.greenAccent
              :selectedIndex == 1 ? CClass.buttonColor2
              :selectedIndex == 2 ? Colors.redAccent
              :selectedIndex == 3 ? CClass.textColor1 : null,
          controller: tabController,
          tabs: const [
            Tab(text: 'Q&A',),
            Tab(text: 'Post',),
            Tab(text: 'Quiz',),
            Tab(text: 'Search',)
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          const QAScreen(),
          const PostScreen(),
          QuizScreen(),
          const SearchScreen()
        ],
      )
    );
  }
}