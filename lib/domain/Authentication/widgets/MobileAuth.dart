import 'package:cng_navigator/config/Colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MobileAuth extends StatefulWidget {
  const MobileAuth({Key? key}) : super(key: key);

  @override
  State<MobileAuth> createState() => _MobileAuthState();
}
class _MobileAuthState extends State<MobileAuth> {
  TextEditingController CountryCode = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late var phoneNumber = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;


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
        child: Transform.translate(
          offset: const Offset(0, -50),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Display the logo image
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 5,
                        color: Colors.black,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo6.png',
                        width: 150,
                        height: 150,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

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
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'Enter phone number',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a phone number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            // Save the phone number entered by the user
                            phoneNumber = value as TextEditingController;
                          },
                        ),
                      ),
                    ],

                  ),

                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 45,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validate the phone number entered by the user
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      // Start the phone number verification process
                      try {
                        await _auth.verifyPhoneNumber(
                          phoneNumber: phoneNumber!,
                          verificationCompleted: (PhoneAuthCredential credential) {},
                          verificationFailed: (FirebaseAuthException e) {
                            if (e.code == 'invalid-phone-number') {
                              print('The provided phone number is not valid.');
                            }
                          },
                          codeSent: (String verificationId, int? resendToken) {
                            // Save the verification ID and resend token so we can use them later
                            _verificationId = verificationId;
                            _resendToken = resendToken;

                            // Navigate to the OTP verification screen
                            Navigator.pushNamed(
                              context,
                              'OtpVerification',
                              arguments: {'verificationId': verificationId},
                            );
                          },
                          codeAutoRetrievalTimeout: (String verificationId) {
                            // Timeout event occurs
                          },
                        );
                      } catch (e) {
                        print('Error occurred: $e');
                      }
                    },
                    child: Text('Get OTP'),
                  ),
                ),
              ],

            ),
          ),
        ),
      ),
    );
  }
}