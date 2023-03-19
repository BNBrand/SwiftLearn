import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/services/auth_methods.dart';
import 'package:swift_learn/utils/colors.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}
AuthMethods authMethods = AuthMethods();

class _HomeState extends State<Home> {
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
