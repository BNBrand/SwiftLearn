import 'package:flutter/material.dart';

import '../utils/color.dart';

class CustumTextField extends StatelessWidget {
  String? errorText;
  TextEditingController controller;
  String labelText;
  CustumTextField({
   required this.controller,
   required  this.errorText,
   required this.labelText,
});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
              border: InputBorder.none,
              errorText: errorText,
              errorStyle: TextStyle(color: Colors.red),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear,color: CClass.textColor2,),
                onPressed: controller.clear,
              ),
              labelText: labelText,
              labelStyle: TextStyle(color: CClass.textColor2)
          ),
        ),
         Divider(color: CClass.containerColor, thickness: 2,),
      ],
    );

  }
}
