import 'package:flutter/material.dart';
import 'package:swift_learn/screens/Forum/uploadForm.dart';
import '../../services/auth_methods.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import 'home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;
  onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  List<Widget> pages = [
    const Home(),
    const UploadForm(),
    const Text('Contacts'),
    const Text('search'),
    SafeArea(child: CustomButton(text: 'Log Out', onPressed: () => AuthMethods().signOut(), color: buttonColor, icon: Icons.logout,)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_page],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: backgroundColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: onPageChanged,
        currentIndex: _page,
        type: BottomNavigationBarType.fixed,
        unselectedFontSize: 14,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.question_answer,
            ),
            label: 'Q&A',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.video_call,
            ),
            label: 'Meetings',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dehaze,
            ),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
