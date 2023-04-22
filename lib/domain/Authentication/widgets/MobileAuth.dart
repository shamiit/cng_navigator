import 'package:cng_navigator/config/Colors.dart';
import 'package:flutter/material.dart';

class MobileAuth extends StatefulWidget {
  const MobileAuth({Key? key}) : super(key: key);

  @override
  State<MobileAuth> createState() => _MobileAuthState();
}

class _MobileAuthState extends State<MobileAuth> {
  TextEditingController CountryCode = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    CountryCode.text = "+91";
    super.initState();
  }
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
                decoration: BoxDecoration(border: Border.all(width: 1,color: loginColor2),
                borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children:  [
                    const SizedBox(width: 10,),
                    SizedBox(
                      width: 40,
                      child: TextField(
                        controller: CountryCode,
                        decoration: const InputDecoration(border: InputBorder.none),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    const Text("|",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 33,color: Colors.grey)),
                    const SizedBox(width: 10,),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(border: InputBorder.none,hintText: "Phone"),

                      ),
                    ),
                  ],

                ),

              ),
              const SizedBox(height: 12),
               SizedBox(
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "OtpVerification");
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  child: const Text("Get OTP"),
                ),
              ),


            ],

          ),
        ),
      ),
    );
  }
}