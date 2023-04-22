import 'package:cng_navigator/config/Colors.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OtpVerification extends StatefulWidget {
  const OtpVerification({Key? key}) : super(key: key);

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Scaffold(
      appBar: AppBar(
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the logo image
              Image.asset(
                'assets/logo6.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 8),

              // Display the header text
              const Text(
                'Phone Verification',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Display the description text
              const Text(
                'We need to register your Mobile number before getting Started !',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            const Pinput(
              length: 6,
              showCursor: true,

            ),
              const SizedBox(height: 12),
              SizedBox(
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "OtpVerification");
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  child: const Text("Verify OTP"),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(onPressed: () {
                    Navigator.pushNamed(context, 'MobileAuth');
                  }, child: Text(
                    "Edit Phone number ?"
                  ))
                ],
              )
            ],

          ),
        ),
      ),
    );
  }
}
