import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/services/auth_methods.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}
AuthMethods authMethods = AuthMethods();

class _HomeState extends State<Home> {

  // String? displayName = '';
  // String? email = '';
  // String? photoURL = '';
  //
  // Future _getData() async{
  //   await FirebaseFirestore.instance.collection('user').doc(authMethods.currentUser!.uid)
  //       .get().then((snapshot) async{
  //     if(snapshot.exists){
  //       setState(() {
  //         displayName = snapshot.data()!['displayName'];
  //         photoURL = snapshot.data()!['photoURL'];
  //         email = snapshot.data()!['email'];
  //       });
  //     }
  //   });
  // }

  // @override
  // void initState() {
  //   _getData();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(authMethods.user.displayName!),
            const SizedBox(height: 10),
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(authMethods.user.photoURL!),
              radius: 50
            ),
            const SizedBox(height: 10),
            Text(authMethods.user.email!),
          ],
        ),
      ),
    );
  }
}
