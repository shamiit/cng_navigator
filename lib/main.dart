import 'package:cng_navigator/config/Colors.dart';
import 'package:cng_navigator/domain/Authentication/widgets/MobileAuth.dart';
import 'package:cng_navigator/domain/Authentication/widgets/OtpVerification.dart';
import 'package:cng_navigator/shared/functions/popupSnakbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try{
    final GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = false;
      mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
    }
  }catch(e){};
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final Future<FirebaseApp> initializeApp = Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyB483rAHGtlqCd5ccI3Lz3-ahsdS2-lBDI",
          authDomain: "cngnavigator.firebaseapp.com",
          databaseURL: "https://cngnavigator-default-rtdb.firebaseio.com",
          projectId: "cngnavigator",
          storageBucket: "cngnavigator.appspot.com",
          messagingSenderId: "774275349732",
          appId: "1:774275349732:android:49d42cbd68047bba4a80f1",
          // measurementId: "G-4Z2VBTH0BN"
      )
  );
  final navigatorKey = GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      scaffoldMessengerKey: PopupSnackBar.messangerKey,
      navigatorKey: navigatorKey,
      title: 'CNG Navigator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: themeColor,
        appBarTheme: const AppBarTheme(
          // backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home:FutureBuilder(
          future: initializeApp,
          builder: (context, snapshot) {
            if(snapshot.hasError){
            }
            if(snapshot.connectionState == ConnectionState.done){
              // return OrderTrackingPage();
              return const MobileAuth();
            }
            return const CircularProgressIndicator();
          }
      ),
      routes: {
        'MobileAuth': (context) => MobileAuth(),
        'OtpVerification': (context) => OtpVerification(),
      },
    );
  }
}

