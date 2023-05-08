import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swift_learn/widgets/custum_textField.dart';

import '../../utils/color.dart';
import '../../widgets/custom_button.dart';
import '../home/home_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {

  TextEditingController levelController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController degreeController = TextEditingController();
  TextEditingController schoolController = TextEditingController();

  bool _bioValue = true;
  bool _schoolValue = true;
  bool _degreeValue = true;
  bool _levelValue = true;
  bool _departmentValue = true;
  bool isStudent = true;

  valideField(){
    setState(() {
      bioController.text.trim().length > 100 ? _bioValue = false : _bioValue = true;
      schoolController.text.trim().length > 50 ? _schoolValue = false : _schoolValue = true;
      levelController.text.trim().length > 50 ? _levelValue = false : _levelValue = true;
      departmentController.text.trim().length > 50 ? _departmentValue = false :_departmentValue = true;
      degreeController.text.trim().length > 50 ? _degreeValue = false : _degreeValue = true;
    });
  }
  handleDetails() async{
    await valideField();
    if(_bioValue && _levelValue && _schoolValue && _departmentValue && _degreeValue){
      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'occupation': isStudent ? 'Student': 'Teacher',
        'level': levelController.text.trim(),
        'school': schoolController.text.trim(),
        'department': departmentController.text.trim(),
        'degree' : isStudent ? degreeController.text.trim() : '',
        'bio': bioController.text.trim()
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
        return HomeScreen();
      }));
    }
  }

  studentDetail(){
    isStudent = true;
    return Column(
      children: [
        SizedBox(height: 10.0,),
        CustumTextField(
          controller: levelController,
          errorText: _levelValue ? null : 'Educational level must be less than 50 characters',
          labelText: 'Educational Level',
        ),
        CustumTextField(
          controller: schoolController,
          errorText: _schoolValue ? null : 'School must be less than 50 characters',
          labelText: 'School',
        ),
        CustumTextField(
          controller: departmentController,
          errorText: _departmentValue ? null : 'Department must be less than 50 characters',
          labelText: 'Department',
        ),
        CustumTextField(
            controller: degreeController,
            errorText: _degreeValue ? null : 'Degree program must be less than 50 characters',
            labelText: 'Degree Program',
        ),
        CustumTextField(
            controller: bioController,
            errorText: _bioValue ? null : 'Bio must be less than 100 characters',
            labelText: 'Interests /About Yourself'
        ),
      ],
    );
  }
  teacherDetail(){
    isStudent = false;
    return Column(
      children: [
        SizedBox(height: 10.0,),
        CustumTextField(
          controller: levelController,
          errorText: _levelValue ? null : 'Educational level must be less than 50 characters',
          labelText: 'Level Taught',
        ),
        CustumTextField(
          controller: schoolController,
          errorText: _schoolValue ? null : 'School must be less than 50 characters',
          labelText: 'School',
        ),
        CustumTextField(
          controller: departmentController,
          errorText: _departmentValue ? null : 'Department must be less than 50 characters',
          labelText: 'Department',
        ),
        CustumTextField(
            controller: bioController,
            errorText: _bioValue ? null : 'Bio must be less than 100 characters',
            labelText: 'Interests /About Yourself'
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CClass.bGColorTheme(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
              onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                  return HomeScreen();
                }));
              },
              child: Text('Skip',style: TextStyle(color: CClass.bTColor2Theme(),fontSize: 16),)
          )
        ],
        elevation: 0.0,
        backgroundColor: CClass.bGColorTheme(),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 10.0),
              child: Text('Welcome To SwiftLearn',
              style: TextStyle(
                fontSize: 25
              ),
              ),
            ),
            const Text('Choose an Occupation',style: TextStyle(
                fontSize: 18,
            ),
            ),
             Divider(color: CClass.containerColor,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal:MediaQuery.of(context).size.width * 0.1,
                    vertical: 5.0
                  ),
                  color: isStudent? CClass.containerColor : CClass.bGColorTheme(),
                  child: TextButton(
                      onPressed: (){
                        setState(() {
                          isStudent = true;
                        });
                      },
                      child: Text('Student',
                      style: TextStyle(
                        fontSize: isStudent ? 18 : 14,
                        color: isStudent ? CClass.bTColor2Theme() : CClass.bTColorTheme()
                      ),
                      )
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal:MediaQuery.of(context).size.width * 0.1,
                      vertical: 5.0
                  ),
                  color: isStudent? CClass.bGColorTheme() : CClass.containerColor,
                  child: TextButton(
                      onPressed: (){
                        setState(() {
                          isStudent = false;
                        });
                      },
                      child: Text('Teacher',
                        style: TextStyle(
                            fontSize: isStudent ? 14 : 18,
                            color: isStudent ? CClass.bTColorTheme() : CClass.bTColor2Theme()
                        ),)
                  ),
                )
              ],
            ),
            isStudent ? studentDetail() : teacherDetail(),
            CustomButton(
              text: 'Done',
              onPressed: handleDetails,
              color: CClass.bTColor2Theme(),
              icon: Icons.check,
              textColor: CClass.textColorTheme(),

            )
          ],
        ),
      ),
    );
  }
}
