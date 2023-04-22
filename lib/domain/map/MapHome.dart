import 'dart:async';

import 'package:cng_navigator/config/Colors.dart';
import 'package:cng_navigator/config/DynamicConstants.dart';
import 'package:cng_navigator/config/StaticConstants.dart';
import 'package:cng_navigator/domain/map/config/constants.dart';
import 'package:cng_navigator/domain/map/functions/Computational.dart';
import 'package:cng_navigator/domain/map/functions/DirectionsRepository.dart';
import 'package:cng_navigator/domain/map/functions/RealTimeDb.dart';
import 'package:cng_navigator/domain/map/widgets/CustomFloatingButton.dart';
import 'package:cng_navigator/shared/functions/Computational.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlonglib;
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:motion_sensors/motion_sensors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'models/Directions.dart';

class MapHomePage extends StatefulWidget {
  const MapHomePage({Key? key}) : super(key: key);

  @override
  State<MapHomePage> createState() => MapHomePageState();
}

class MapHomePageState extends State<MapHomePage> {
  BitmapDescriptor myLocationMaker = BitmapDescriptor.defaultMarker;
  final databaseReference = FirebaseDatabase.instance.ref();
  late GoogleMapController googleMapController;
  final Completer<GoogleMapController> _controller = Completer();
  var firbaseClass = MapFirebase();
  Location location = Location();
  final user = FirebaseAuth.instance.currentUser;
  late LatLng destination;
  late LatLng myLocation;
  late LatLng mapCameraLocation;
  LocationData? currentLocationData;
  LocationData? currentLocationDataOld;
  late StreamSubscription _firebaseSubscriptionMe;
  late StreamSubscription _firebaseSubscriptionBus;
  late StreamSubscription _firebaseSubscriptionUserBus;
  List<LatLng> polylineCoordinates = [];
  late Directions _info;
  bool infoUpdate = false;

  Set<Marker> markers = {};
  Set<Map<dynamic, dynamic>> allUserCompleteData = {};

  Map<dynamic, dynamic> currentUserdata = <dynamic, dynamic>{};
  Map<dynamic, dynamic> selectedUserdata = <dynamic, dynamic>{};
  String currentUid = '';
  String selectedUid = '';
  String _selectedRoute = '';
  bool _mounted = true;
  final Vector3 _orientation = Vector3.zero();
  bool isLocationReady = true;
  bool isPolylineReady = false;
  bool isRouteLoaded = true;
  bool isUserBus = false;
  int exitCount = 0;

  void setUp() async {
    getMyInfo();
    if (await locationPermission()) getCurrentLocation();
    startSensors();
    zoomMap = await getZoomLevel(); //from sharedPrefs
    focusMe = true;
    if (_mounted) {
      setState(() {});
    }
  }

  void loadRouteInfo() async {
    List<String> routeList = [];
    databaseReference.child("routes").onValue.listen((DatabaseEvent event) {
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        routeList.add(value);
      });
      if (_mounted) {
        setState(() {
          userRoute = routeList;
        });
      }
    });
  }

  Future getMyInfo() async {
    DatabaseReference starCountRef =
        FirebaseDatabase.instance.ref('users/${user?.uid}');
    _firebaseSubscriptionMe =
        starCountRef.onValue.listen((DatabaseEvent event) {
      currentUserdata = event.snapshot.value as Map<dynamic, dynamic>;
      myCategory = currentUserdata['post'] == 'Driver' ? 'buses' : 'users';
      myRoute = currentUserdata['route'];
      currentUserdata['post'] == 'Driver'
          ? getBusAndUsersInfoByRootId(myRoute)
          : getBusInfoByRootId(myRoute);
      if (currentUserdata['routeAccess'] == true && isRouteLoaded == true) {
        isRouteLoaded = false;
        loadRouteInfo();
      }

      if (_mounted) {
        getLocationIcon();
        setState(() {});
      }
    });
  }

  Future getBusAndUsersInfoByRootId(String route) async {
    isUserBus = true;
    DatabaseReference starCountRef =
        FirebaseDatabase.instance.ref().child("routesAll/$route");
    _firebaseSubscriptionUserBus =
        starCountRef.onValue.listen((DatabaseEvent event) {
      allUserCompleteData = {};
      if (event.snapshot.value == null) return;
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;
      if (data["buses"] != null) {
        data["buses"].forEach((key, value) {
          if (key != user?.uid) {
            value['icon'] = "bus";
            allUserCompleteData.add({key: value});
          }
        });
      }
      if (data["users"] != null) {
        data["users"].forEach((key, value) {
          value['icon'] = "person";
          allUserCompleteData.add({key: value});
        });
      }
      if (_mounted) {
        getLocationIcon();
        setState(() {});
      }
    });
  }

  Future getBusInfoByRootId(String route) async {
    DatabaseReference starCountRef =
        FirebaseDatabase.instance.ref().child("routesAll/$route/buses");
    _firebaseSubscriptionBus =
        starCountRef.onValue.listen((DatabaseEvent event) {
      allUserCompleteData = {};
      if (event.snapshot.value == null) return;
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        value['icon'] = "bus";
        allUserCompleteData.add({key: value});
      });
      if (_mounted) {
        getLocationIcon();
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    final user = this.user;
    if (user != null) {
      currentUid = user.uid;
    }
    setUp();
  }

  Future<void> firstDistanceLoaded(double newDistance) async {
    if (!distanceLoaded) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('totalDistance', newDistance);
      distanceLoaded = true;
      if (_mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _mounted = false;
    _firebaseSubscriptionMe.cancel();
    isUserBus
        ? _firebaseSubscriptionUserBus.cancel()
        : _firebaseSubscriptionBus.cancel();
    super.dispose();
  }

  Future<void> getLocationIcon() async {
    firstDistanceLoaded(currentUserdata['distance'] ?? 0);
    var defaultIcon = personIconAsset;
    if (currentUserdata['image'] != null &&
        currentUserdata['trackMe'] == true) {
      var url = Uri.parse(currentUserdata['image']);
      var request = await http.get(url);
      var dataBytes = request.bodyBytes;
      myLocationMaker =
          BitmapDescriptor.fromBytes(dataBytes.buffer.asUint8List());
    } else {
      String busIconDynamic = tiltMap > 30 ? busIconAsset : busTopIconAsset;
      String busOffIconDynamic =busIconAsset;
      if (currentUserdata['trackMe'] == true) {
        defaultIcon = currentUserdata['post'] == 'Driver'
            ? busIconDynamic
            : personIconAsset;
      } else {
        defaultIcon = currentUserdata['post'] == 'Driver'
            ? busOffIconDynamic
            : personIconAsset;
      }
      await BitmapDescriptor.fromAssetImage(
              ImageConfiguration.empty, defaultIcon)
          .then((value) {
        myLocationMaker = value;
      });
    }
  }

  void getCurrentLocation() async {
    location.changeSettings(
        accuracy: LocationAccuracy.high, interval: 10, distanceFilter: 0);
    location.getLocation().then((value) {
      currentLocationData = value;
      myLocation = LatLng(setPrecision(currentLocationData!.latitude!, 3),
          setPrecision(currentLocationData!.longitude!, 3));
      mapCameraLocation = myLocation;
      if (_mounted) {
        setState(() {});
      }
    });

    location.onLocationChanged.listen((newLocation) async {
      currentLocationData = newLocation;
      speed = ((currentLocationData?.speed ?? 0) * speedBias).toInt();
      firbaseClass.setMyCoordinatesOptimized(
          currentLocationData!.latitude!.toString(),
          currentLocationData!.longitude!.toString(),
          bearingMap);
      myLocation = LatLng(setPrecision(currentLocationData!.latitude!, 3),
          setPrecision(currentLocationData!.longitude!, 3));
      currentLocationDataOld =
          await updateDistanceTravelled(currentLocationData);
      if (_mounted) {
        updateMakers();
        mapCameraController();
        setState(() {});
      }
    });
    await location.enableBackgroundMode(enable: isLocationBackground);
  }

  Future<LocationData?> updateDistanceTravelled(
      LocationData? currentLocationData) async {
    currentLocationDataOld ??= currentLocationData;
    var distance = const latlonglib.Distance();
    final meter = distance(
        latlonglib.LatLng(currentLocationDataOld!.latitude!,
            currentLocationDataOld!.longitude!),
        latlonglib.LatLng(
            currentLocationData!.latitude!, currentLocationData.longitude!));
    if (recordingStart) {
      distanceTravelled += meter;
      await setTotalDistanceTravelled(firbaseClass, meter);
    }
    currentLocationDataOld = currentLocationData;
    return currentLocationData; //now this will became old data.
  }

  void startSensors() {
    FlutterCompass.events?.listen((event) {
      if (_mounted) {
        setState(() {
          bearingMap = event.heading!;
        });
      }
    });
    motionSensors.isOrientationAvailable().then((available) {
      if (available) {
        motionSensors.orientation.listen((OrientationEvent event) {
          if (_mounted) {
            setState(() {
              _orientation.setValues(event.yaw, event.pitch, event.roll);
              tiltMap = degrees(_orientation.y);
            });
          }
        });
      }
    });
  }

  Future<void> mapCameraController() async {
    googleMapController = await _controller.future;
    if (focusMe || focusDest) {
      if (focusMe) {
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                bearing: bearingMap,
                tilt: tiltMap,
                zoom: zoomMap,
                target: LatLng(currentLocationData!.latitude!,
                    currentLocationData!.longitude!))));
      } else if (selectedUid.isNotEmpty) {
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                bearing: bearingMap,
                tilt: tiltMap,
                zoom: zoomMap,
                target: destination)));
      }
    }
  }

  void getPolyPoints() async {
    if (selectedUid.isEmpty) {
      return;
    }
    final directions = await DirectionsRepository().getDirections(
        origin: LatLng(
            currentLocationData!.latitude!, currentLocationData!.longitude!),
        destination: destination);
    if (directions.polylinePoints.isNotEmpty) {
      polylineCoordinates = [];
      directions.polylinePoints.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    infoUpdate = true;
    _info = directions;
    if (_mounted) {
      setState(() {});
    }
  }

  Future showSelectedUserInfoPopup(String Uid) async {
    DatabaseReference starCountRef =
        FirebaseDatabase.instance.ref('users/$Uid');
    starCountRef.onValue.listen((DatabaseEvent event) {
      selectedUserdata = event.snapshot.value as Map<dynamic, dynamic>;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: Text(
                  '${selectedUserdata['post']}: ${selectedUserdata['name']}'),
              content: InkWell(
                onTap: () {
                },
                child: Text(
                  'Call: ${selectedUserdata['phone']}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.blue,
                  ),
                ),
              ));
        },
      );
    });
  }

  void updateMakers() async {
    if (selectedUid.isNotEmpty && allUserCompleteData.isNotEmpty) {
      var val = allUserCompleteData
          .firstWhere((element) => element.containsKey(selectedUid));
      destination = LatLng(double.parse(val[selectedUid]['latitude']),
          double.parse(val[selectedUid]['longitude']));
    }
    markers = {};
    markers.add(
      Marker(
        rotation: bearingMap,
        infoWindow: InfoWindow(
            title: '${currentUserdata['post']}: ${user?.displayName}',
            snippet: 'Phone: ${currentUserdata['phone']}',
            onTap: () {}),
        icon: myLocationMaker,
        markerId: MarkerId(user?.email as String),
        position: LatLng(
            currentLocationData!.latitude!, currentLocationData!.longitude!),
      ),
    );
    for (var element in allUserCompleteData) {
      element.forEach((key, value) async {
        BitmapDescriptor locationMaker = BitmapDescriptor.defaultMarker;
        if (value['image'] != null) {
          var url = Uri.parse(value['image']);
          var request = await http.get(url);
          var dataBytes = request.bodyBytes;
          locationMaker =
              BitmapDescriptor.fromBytes(dataBytes.buffer.asUint8List());
        } else {
          String busIconDynamic =
              tiltMap > tiltMapThreshold ? busIconAsset : busTopIconAsset;
          await BitmapDescriptor.fromAssetImage(ImageConfiguration.empty,
                  value['icon'] == 'bus' ? busIconDynamic : personIconAsset)
              .then((value) => locationMaker = value);
        }

        double netDirection =
            netRotationDirection(value['direction'] ?? 0, bearingMap);
        markers.add(
          Marker(
            rotation: netDirection,
            onTap: () {
              selectedUid = key;
              destination = LatLng(double.parse(value['latitude']),
                  double.parse(value['longitude']));
              getPolyPoints();
              showSelectedUserInfoPopup(selectedUid);
            },
            icon: locationMaker,
            markerId: MarkerId(key),
            position: LatLng(double.parse(value['latitude']),
                double.parse(value['longitude'])),
          ),
        );
      });
    }
    if (_mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUid.isNotEmpty && currentUserdata['trackMe'] != null) {
      setState(() {
        _selectedRoute = currentUserdata['route'];
        iconVisible = currentUserdata['trackMe'];
        myRoute = _selectedRoute;
      });
    }

    return WillPopScope(
      onWillPop: () async {
        final value = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Alert'),
                content: const Text('Do you want to Exit'),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Exit'),
                  )
                ],
              );
            });
        if (value != null) {
          return Future.value(value);
        } else {
          return Future.value(false);
        }
      },
      child: Scaffold(
        body: currentLocationData == null
            ? Center(
                child: TextButton(
                  onPressed: () {
                    getCurrentLocation();
                  },
                  child: const Text('Click here to Reload'),
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  GoogleMap(
                    onCameraMove: (object) => {
                      if (_mounted)
                        setState(() {
                          mapCameraLocation = LatLng(
                              object.target.latitude, object.target.longitude);
                          focusMe = compareLatLang(
                              myLocation, mapCameraLocation, zoomPrecision);
                          if (selectedUid.isNotEmpty) {
                            focusDest = compareLatLang(
                                destination, mapCameraLocation, zoomPrecision);
                          }
                        })
                    },
                    mapType: MapType.hybrid,
                    tiltGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                    mapToolbarEnabled: true,
                    compassEnabled: true,
                    buildingsEnabled: true,
                    myLocationEnabled: true,
                    trafficEnabled: true,
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    initialCameraPosition: CameraPosition(
                        bearing: bearingMap,
                        tilt: tiltMap,
                        target: LatLng(currentLocationData!.latitude!,
                            currentLocationData!.longitude!),
                        zoom: zoomMap),
                    polylines: {
                      Polyline(
                          polylineId: const PolylineId("route"),
                          points: polylineCoordinates,
                          color: primaryColor,
                          width: 6)
                    },
                    markers: markers,
                    onMapCreated: (mapController) {
                      _controller.complete(mapController);
                    },
                  ),
                  if (infoUpdate)
                    Positioned(
                      top: 20.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 6.0,
                            )
                          ],
                        ),
                        child: Text(
                          '${_info.totalDistance}, ${_info.totalDuration}',
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
        floatingActionButton:
            CustomFloatingButton(selectedUid: selectedUid, maxZoom: 22.0),
      ),
    );
  }
}
