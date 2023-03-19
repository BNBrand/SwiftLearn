import 'package:flutter/material.dart';

import '../utils/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final IconData icon;
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.color,
    required this.icon,
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
          children: [
            Icon(icon),
            const SizedBox(width: 3.0,),
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

class CustomButton2 extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final String image;
  const CustomButton2({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.color,
    required this.image,
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
            Image.asset(image,height: 45,width: 45,),
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
