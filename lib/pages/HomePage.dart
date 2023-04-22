import 'package:cng_navigator/config/Colors.dart';
import 'package:cng_navigator/config/DynamicConstants.dart';
import 'package:cng_navigator/domain/erpwebsite/WebViewController.dart';
import 'package:cng_navigator/domain/map/MapHome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../res/assets_res.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  var currentPage = DrawerSections.subscription;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int count = 0;
  double navTopPadding = 20;
  String firebasePath = '';
  var container;

  Future<void> permissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  @override
  void initState() {
    super.initState();
    permissions();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(true);
        // setState(() {
        //   count++;
        // });
        // print('Home Page');
        // print(count);
        // if(count > 2){
        //   return Future.value(true);
        // }else{
        //   return Future.value(false);
        // }
      },
      child: Scaffold(
          key: _scaffoldKey,
          endDrawer: Drawer(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[MyHeaderDrawer(), MyDrawerList()],
              ),
            ),
          ),
          endDrawerEnableOpenDragGesture: true,
          body: const SafeArea(child: MapHomePage()),
          floatingActionButton: favoriteButton(navTopPadding),
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
          floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
          ),
    );
  }

  Widget favoriteButton(double navTopPadding) {
    return Padding(
      padding: EdgeInsets.only(top: navTopPadding),
      child: FloatingActionButton(
        mini: true,
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(5)),
        onPressed: () async {
          _scaffoldKey.currentState?.openEndDrawer();
        },
        child: const Icon(Icons.menu),
      ),
    );
  }

  Widget MyDrawerList() {
    return Container(
      child: Column(
        // shows the list of menu drawer
        children: [
          menuItem(1, "Subscription", Icons.currency_rupee,
              currentPage == DrawerSections.subscription ? true : false),
          menuItem(2, "Privacy Policy", Icons.privacy_tip,
              currentPage == DrawerSections.privacypolicy ? true : false),
          menuItem(3, "Terms of Service", Icons.file_open,
              currentPage == DrawerSections.termsofservice ? true : false),
          menuItem(4, "Feedback", Icons.feedback,
              currentPage == DrawerSections.feedback ? true : false),
          Divider(),
          menuItem(5, "Logout", Icons.logout,
              currentPage == DrawerSections.logout ? true : false),
        ],
      ),
    );
  }

  Widget menuItem(int id, String title, IconData icon, bool selected) {
    return Material(
      color: selected ? Colors.grey[bnBarColor] : Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          if (mounted) {
            setState(() {
              if (id > navlen) {
                selectedIndex = 0;
                sepFlag = 1;
              } else {
                selectedIndex = id - 1;
                sepFlag = 0;
              }
              var pathfirebase = '';
              if (id == 1) {
                currentPage = DrawerSections.subscription;
                pathfirebase='subscription';
              } else if (id == 2) {
                currentPage = DrawerSections.privacypolicy;
                pathfirebase='privacypolicy';
              } else if (id == 3) {
                currentPage = DrawerSections.termsofservice;
                pathfirebase='termsofservice';
              } else if (id == 4) {
                currentPage = DrawerSections.feedback;
                pathfirebase='feedback';
              }  else if (id == 5) {
                currentPage = DrawerSections.logout;
                FirebaseAuth.instance.signOut();
              }
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => WebViewController(firebasePath: pathfirebase),
              ));

            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
          child: Row(
            children: [
              Expanded(
                child: Icon(
                  icon,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget MyHeaderDrawer() {
    return Material(
      color: Colors.green[700],
      child: InkWell(
        child: Container(
          width: double.infinity,
          height: 200,
          padding: EdgeInsets.only(top: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10),
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(AssetsRes.LOGO),
                  ),
                ),
              ),
              Text(
                '${user?.displayName}',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              Text(
                "${user?.phoneNumber}",
                style: TextStyle(
                  color: Colors.grey[200],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
