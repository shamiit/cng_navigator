import 'package:cng_navigator/config/Colors.dart';
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
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the logo image
              Image.asset(
                'assets/logo_login_page.png',
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

              // Display the phone number input field
              Container(

                child: Row(
                  children: const [
                    Expanded(
                      child: TextField(
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Display the "Get OTP" button
              const SizedBox(
                height: 45,
                child: ElevatedButton(
                  onPressed: null, // TODO: Implement the "Get OTP" functionality
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