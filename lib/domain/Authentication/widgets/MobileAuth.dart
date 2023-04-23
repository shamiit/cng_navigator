import 'package:flutter/material.dart';

class MobileAuth extends StatefulWidget {
  const MobileAuth({Key? key}) : super(key: key);

  @override
  State<MobileAuth> createState() => _MobileAuthState();
}

class _MobileAuthState extends State<MobileAuth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  const [
               Text('Phone Verification',
                style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold),
            ),
              SizedBox(height: 8),
              Text('Enter your 10 Digit Mobile Number',
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
