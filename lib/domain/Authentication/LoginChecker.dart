import 'dart:async';

import 'package:cng_navigator/config/StaticConstants.dart';
import 'package:cng_navigator/domain/Authentication/widgets/MobileAuth.dart';
import 'package:cng_navigator/domain/map/MapHome.dart';
import 'package:cng_navigator/pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginChecker extends StatefulWidget {
  const LoginChecker({Key? key}) : super(key: key);

  @override
  State<LoginChecker> createState() => _LoginCheckerState();
}

class _LoginCheckerState extends State<LoginChecker> {
  @override
  void initState() {
    super.initState();
    checkEmailVerified();
  }


  Future checkEmailVerified() async{
    var user = await FirebaseAuth.instance.currentUser;
    if(user != null) {
      user.reload();
      setState(() {
        isEmailVerified = user.emailVerified;
      });
    }
    // Timer.periodic(const Duration(seconds: 1), (Timer t) => setState((){}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
                child: CircularProgressIndicator()
            );
          }else if(snapshot.hasError){
            return const Center(child: Text('Something went Wrong!'));
          }
          else if(snapshot.hasData){
            return const HomePage(title: 'CNG Navigator',);
          }else{
            return const HomePage(title: 'CNG Navigator',);
            // return const MobileAuth();
          }
        },
      ),
    );
  }
}




