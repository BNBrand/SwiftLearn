import 'package:flutter/material.dart';
import 'package:swift_learn/utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: backgroundColor2,
        title: TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: backgroundColor2,
            border: InputBorder.none,
            hintText: 'Search',
              prefixIcon: IconButton(
                icon: const Icon(Icons.search, color: textColor1,),
                onPressed: (){},
              ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: textColor1,),
              onPressed: (){},
            )
          ),
        ),
      ),
    );
  }
}
