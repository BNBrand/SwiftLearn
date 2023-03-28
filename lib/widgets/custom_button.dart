import 'package:flutter/material.dart';

import '../utils/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color textColor;
  final Color color;
  final IconData icon;
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.color,
    required this.icon,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:color,
          minimumSize: const Size(
            double.infinity,
            50,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: buttonColor),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 3.0,),
            Text(
              text,
              style: TextStyle(
                fontSize: 17,
                color: textColor
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomButton2 extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final String image;
  final Color borderColor;
  const CustomButton2({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.color,
    required this.image,
    required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:color,
          minimumSize: const Size(
            double.infinity,
            50,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: borderColor),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image,height: 35,width: 35,),
            SizedBox(width: 3,),
            Text(
              text,
              style: const TextStyle(
                  fontSize: 17,
                  color: backgroundColor2
              ),
            ),
          ],
        ),
      ),
    );
  }
}
