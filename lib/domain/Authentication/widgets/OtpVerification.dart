import 'package:flutter/material.dart';

class OtpVerification extends StatefulWidget {
  const OtpVerification({Key? key}) : super(key: key);

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(left: 25,right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:   const [
              Text('OTP Verification',
                style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('We need to register your Mobile number before getting Started !',
                style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500, ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 45,
                child: ElevatedButton(onPressed: null,
                  // style: ElevatedButton.icon(backgroundColor: Colors.blueGrey),
                  child: Text("Get OTP"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
