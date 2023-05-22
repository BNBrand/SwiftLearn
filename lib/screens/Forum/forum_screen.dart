import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../utils/color.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_button.dart';
import '../more/profile/profile_screen.dart';
import 'social_media/comments.dart';

class PostScreen extends StatefulWidget {

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> with SingleTickerProviderStateMixin {

  TextEditingController captionController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResultFuture;
  List<Post> post = [];
  PageController pageController = PageController();
  TabController? tabController;
  bool isLoading = false;
  File? imageFile;
  String? imageUrl;
  bool isUploading = false;
  bool isPost = true;
  String postId = const Uuid().v4();
  String? displayNameUser = '';
  String? email = '';
  String? photoURLUser = '';
  int selectedIndex = 0;

  @override
  Future _getData() async{
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then((snapshot) async{
      if(snapshot.exists){
        setState(() {
          displayNameUser = snapshot.data()!['displayName'];
          photoURLUser = snapshot.data()!['photoURL'];
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
  postsContent() async{
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).get();
    setState(() {
      isPost = true;
      isLoading = false;
      post = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
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
        postsContent();
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
                  postsContent();
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
  qAContent(){
    setState(() {
      isPost = false;
    });
    return Text('Q&A');
  }
  searchContent(){
    setState(() {
      isPost = false;
    });
    return Column(
      children: [
        TextField(
          controller: searchController,
          onChanged: (val) {
            setState(() {
              searchController.text.isEmpty ? null :
              handleSearch(val);
            });
          },
          onSubmitted: handleSearch,
          decoration: InputDecoration(
              filled: true,
              fillColor: CClass.bGColor2Theme(),
              border: InputBorder.none,
              hintText: 'Search',
              prefixIcon: Icon(Icons.search, color: CClass.textColorTheme(),),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: CClass.textColorTheme(),),
                onPressed: (){
                  setState(() {
                    searchController.clear();
                  });
                },
              )
          ),
        ),
        searchController.text.isEmpty ?
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 80, color: CClass.containerColor,),
              Text('Search users')
            ],
          ),
        ):
        SingleChildScrollView(child: buildSearchResults(),)
      ],
    );
  }
  quizContent(){
    setState(() {
      isPost = false;
    });
    return Text('Quiz');
  }
  handleSearch(String query){
    Future<QuerySnapshot> users = FirebaseFirestore.instance.collection('users')
        .where('displayName', isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResultFuture = users;
    });
  }
  buildSearchResults(){
    return FutureBuilder(
        future: searchResultFuture,
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: CClass.buttonColor2,));
          }
          List<Padding> searchResults = [];
          snapshot.data!.docs.forEach((doc) {
            Users user = Users.fromDocument(doc);
            searchResults.add(
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return ProfileScreen(profileId: user.uid);
                    }));
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: CClass.secondaryBackgroundColor,
                      backgroundImage: CachedNetworkImageProvider(user.photoURL),
                    ),
                    title: Text(user.displayName, overflow: TextOverflow.ellipsis,),
                    subtitle: Text(user.email, overflow: TextOverflow.ellipsis),
                    trailing: user.uid != FirebaseAuth.instance.currentUser!.uid ? TextButton.icon(
                      label: Text('Follow',style: TextStyle(color: CClass.buttonColor2),),
                      icon: Icon(Icons.add,color: CClass.buttonColor2,),
                      onPressed: (){},
                    )
                        :
                    null,
                  ),
                ),
              ),
            );
          });
          return Column(
              children: searchResults
          );
        }
    );
  }
  void initState() {
    tabController = TabController(length: 4, vsync: this);
    postsContent();
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    postsContent();
    return imageFile != null ?  withImage() :
    Scaffold(
      floatingActionButton: isPost ? FloatingActionButton(
        onPressed: _showImageDialog,
        child: Icon(Icons.upload,color: CClass.textColor1,),
        backgroundColor: CClass.buttonColor,
      ) : null,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: CClass.backgroundColor2,
        automaticallyImplyLeading: false,
        title: TabBar(
          indicatorColor: CClass.buttonColor2,
          controller: tabController,
          tabs: [
            Tab(text: 'Post',),
            Tab(text: 'Q&A',),
            Tab(text: 'Quiz',),
            Tab(text: 'Search',)
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          ListView(
            children: [
              Column(
                children: post,
              ),
            ],
          ),
          qAContent(),
          quizContent(),
          searchContent()
        ],
      )
    );
  }
}