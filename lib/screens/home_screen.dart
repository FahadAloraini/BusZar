import 'dart:async';
import 'package:flutter/services.dart';
import 'package:testing_phase1/screens/check_out_screen.dart';
import 'package:testing_phase1/screens/profile/settings_screen.dart';
import 'package:testing_phase1/screens/select_nearest_active_driver_screen.dart';
import 'package:testing_phase1/screens/trips_screen.dart';
import 'dart:ui' as ui;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../components/direction_details_info.dart';
import '../main.dart';
import 'search_places_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:testing_phase1/components/global.dart';
import 'package:testing_phase1/screens/profile_screen.dart';
import 'package:testing_phase1/screens/search_screen.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
//import 'package:testing_phase1/screens/settings_screen.dart';
import 'package:testing_phase1/screens/user_ticket_screen.dart';
import '../components/app_info.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:testing_phase1/components/rounded_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:testing_phase1/components/assistant_methods.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:testing_phase1/components/active_nearby_available_drivers.dart';
import 'package:testing_phase1/components/geofire_assistant.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:testing_phase1/components/bus_station.dart';
import 'dart:math' show cos, sqrt, asin;
import 'trips_history_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;
  //to cancel the selected location
  bool locationSelected = true;

  var _selectedTab = _SelectedTab.home;
  void _handleIndexChanged(int i) {
    setState(() async {
      setState(() {
        _selectedTab = _SelectedTab.values[i];
      });
      i == 0 ? Navigator.pushNamed(context, HomeScreen.id) : null;

      if (i == 1) {
        var responseFromSearchScreen =
            await Navigator.pushNamed(context, TripsScreen.id);

        if (responseFromSearchScreen == "obtainedDropoff") {
          //draw routes - draw polyline
          setState(() {
            locationSelected = false;
          });
          await locateUserPosition();

          await drawPolyLineFromOriginToDestination();
        }
      }
      if (i == 2) {
        if (locationSelected) {
          var responseFromSearchScreen =
              await Navigator.pushNamed(context, SearchPlacesScreen.id);

          if (responseFromSearchScreen == "obtainedDropoff") {
            setState(() {
              showUIForAssignedTripInfo();
              locationSelected = false;
            });

            //draw routes - draw polyline
            await drawPolyLineFromOriginToDestination();
          }
        } else {
          Navigator.pushNamed(context, HomeScreen.id);
        }
      }

      i == 3 ? Navigator.pushNamed(context, ProfileScreen.id) : null;
      i == 4 ? Navigator.pushNamed(context, SettingsScreen.id) : null;
      print(i);
      print(locationSelected);
    });
  }

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  double searchLocationContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;
  double navBarContainerHeight = 180;

  DateTime loginClickTime = DateTime.now();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoOrdinatesList = [];
  List<LatLng> pLineCoOrdinatesList2 = [];
  List<LatLng> pLineCoOrdinatesList3 = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Marker> stationMarkersSet = {};
  Set<Circle> circlesSet = {};
  Set<Marker> stationMarkersSetOnThePath = {};

  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;
  BitmapDescriptor? OriginIcon;
  BitmapDescriptor? DestinationIcon;

  List<ActiveNearbyAvailableDrivers> onlineNearByAvailableDriversList = [];

  DatabaseReference? referenceRideRequest;
  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;

  Map<PolylineId, Polyline> polylines = {}; //my att

  RemovePOI() {
    newGoogleMapController!.setMapStyle('''
    [
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "transit.station.bus",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit.station.bus",
    "elementType": "geometry",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit.station.bus",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit.station.bus",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit.station.bus",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit.station.bus",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit.station.bus",
    "elementType": "labels.text",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit.station.bus",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit.station.bus",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]
  ''');
  }

  blackThemeGoogleMap() {
    newGoogleMapController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                       
      {
        "featureType": "poi",
        "stylers": [
          { "visibility": "off" }
        ]
      }
    
                    ]
                ''');
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoOrdinates(
            userCurrentPosition!, context);
    print("this is your address = " + humanReadableAddress);

    initializeGeoFireListener();

    AssistantMethods.readTripsKeysForOnlineUser(context);
  }

  @override
  void initState() {
    super.initState();
    AssistantMethods.readCurrentOnlineUserInfo();
    print(fAuth.currentUser?.email!.toString());
    checkIfLocationPermissionAllowed();

    controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
    loadData();
  }

  Uint8List? marketimages;
  List<String> images = [
    'images/Bus_Station.png',
    'images/origin.png',
    'images/destination.png'
  ];

  // created list of coordinates of various locations
  final List<LatLng> _latLen = <LatLng>[
    LatLng(26.316623, 50.139768),
    LatLng(26.322904, 50.162030),
    LatLng(26.332573, 50.180432),
    LatLng(26.373514, 50.178106),
    LatLng(26.366407, 50.141829),
    LatLng(26.370198, 50.091064),
    LatLng(26.357973, 50.045163),
    LatLng(26.359774, 50.017453),
    LatLng(26.410888, 50.110438),
    LatLng(26.389174, 50.064984),
    LatLng(26.426109, 50.100820),
    LatLng(26.396255, 50.040478),
    LatLng(26.420328, 50.022297),
    LatLng(26.440148, 50.173283),
    LatLng(26.405696, 50.185931),
    LatLng(26.363679, 50.208197),
    LatLng(26.309128, 50.218342),
    LatLng(26.288103, 50.183560),
    LatLng(26.258923, 50.191860),
    LatLng(24.691572, 46.777048),
    LatLng(24.688567, 46.789244),
  ];

  // declared method to get Images
  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  loadData() async {
    stationMarkersSet.clear();
    for (int i = 0; i < _latLen.length; i++) {
      final Uint8List markIcons = await getImages(images[0], 100);
      // makers added according to index
      markersSet.add(Marker(
        // given marker id
        markerId: MarkerId(i.toString()),
        // given marker icon
        icon: BitmapDescriptor.fromBytes(markIcons),
        // given position
        position: _latLen[i],
        infoWindow: InfoWindow(
          // given title for marker
          title: 'Location: ' + i.toString(),
        ),
      ));
      stationMarkersSet.add(Marker(
        // given marker id
        markerId: MarkerId(i.toString()),
        // given marker icon
        icon: BitmapDescriptor.fromBytes(markIcons),
        // given position
        position: _latLen[i],
        infoWindow: InfoWindow(
          // given title for marker
          title: 'Location: ' + i.toString(),
        ),
      ));
      setState(() {});
    }
    Uint8List markIcons1 = await getImages(images[1], 100);
    OriginIcon = BitmapDescriptor.fromBytes(markIcons1);
    Uint8List markIcons2 = await getImages(images[2], 100);
    DestinationIcon = BitmapDescriptor.fromBytes(markIcons2);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  saveRideRequestInformation() {
    //1. save the RideRequest Information
    referenceRideRequest =
        FirebaseDatabase.instance.ref().child("All Ride Requests").push();

    var originLocation =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationLocation =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    Map originLocationMap = {
      //"key": value,
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation!.locationLongitude.toString(),
    };

    Map destinationLocationMap = {
      //"key": value,
      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation!.locationLongitude.toString(),
    };

    Map userInformationMap = {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().toString(),
      "userName": userModelCurrentInfo!.name,
      "userPhone": userModelCurrentInfo!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "driverId": "waiting",
    };

    referenceRideRequest!.set(userInformationMap);

    onlineNearByAvailableDriversList =
        GeoFireAssistant.activeNearbyAvailableDriversList;
    searchNearestOnlineDrivers();
  }

  searchNearestOnlineDrivers() async {
    //no active driver available
    if (onlineNearByAvailableDriversList.length == 0) {
      //cancel/delete the RideRequest Information
      referenceRideRequest!.remove();

      setState(() {
        polyLineSet.clear();
        loadData();
        stationMarkersSetOnThePath.clear();
        circlesSet.clear();
        pLineCoOrdinatesList.clear();
        pLineCoOrdinatesList2.clear();
        pLineCoOrdinatesList3.clear();
      });

      Fluttertoast.showToast(
          msg:
              "No Online Nearest Driver Available. Search Again after some time, Restarting App Now.");

      Future.delayed(const Duration(milliseconds: 4000), () {
        SystemNavigator.pop();
        //BusZar.restartApp(context);
      });

      return;
    }

    //active driver available
    await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);

    var response = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => SelectNearestActiveDriversScreen(
                referenceRideRequest: referenceRideRequest)));

    if (response == "driverChoosed") {
      FirebaseDatabase.instance
          .ref()
          .child("driver")
          .child(chosenDriverId!)
          .once()
          .then((snap) {
        if (snap.snapshot.value != null) {
          //send notification to that specific driver
          //sendNotificationToDriverNow(chosenDriverId!);

          showUIForAssignedDriverInfo();
        } else {
          Fluttertoast.showToast(msg: "This driver do not exist. Try again.");
        }
      });
    }

    //referenceRideRequest!.onDisconnect();
    //tripRideRequestInfoStreamSubscription!.cancel();
  }

  showUIForAssignedDriverInfo() {
    setState(() {
      searchLocationContainerHeight = 0;
      assignedDriverInfoContainerHeight = 250;
      navBarContainerHeight = 0;
    });
  }

  showUIForAssignedTripInfo() {
    setState(() {
      searchLocationContainerHeight = 240;
      assignedDriverInfoContainerHeight = 0;
      navBarContainerHeight = 0;
    });
  }

  retrieveOnlineDriversInformation(List onlineNearestDriversList) async {
    dList.clear();
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("driver");
    for (int i = 0; i < onlineNearestDriversList.length; i++) {
      await ref
          .child(onlineNearestDriversList[i].driverId.toString())
          .once()
          .then((dataSnapshot) {
        var driverKeyInfo = dataSnapshot.snapshot.value;
        dList.add(driverKeyInfo);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    createActiveNearByDriverIconMarker();

    return Scaffold(
      // appBar: AppBar(
      //   title: Text("HomePage"),
      //   backgroundColor: Colors.deepPurple,
      // ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            polylines: polyLineSet, //Set<Polyline>.of(polylines.values), //
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              //for black theme google map
              //blackThemeGoogleMap();
              DarkMode ? RemovePOI() : null;

              setState(() {
                bottomPaddingOfMap = 250;
              });

              locateUserPosition();
            },
          ),
          // if (!locationSelected) ...[
          //   Positioned(
          //     top: 110,
          //     child: ElevatedButton(
          //       child: const Text(
          //         "Request a Ride",
          //       ),
          //       onPressed: () {
          //         if (Provider.of<AppInfo>(context, listen: false)
          //                 .userDropOffLocation !=
          //             null) {
          //           saveRideRequestInformation();
          //         } else {
          //           Fluttertoast.showToast(
          //               msg: "Please select destination location");
          //         }
          //       },
          //       style: ElevatedButton.styleFrom(
          //           primary: Colors.green,
          //           textStyle: const TextStyle(
          //               fontSize: 16, fontWeight: FontWeight.bold)),
          //     ),
          //   ),
          // ],
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: assignedDriverInfoContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //status of ride
                    Center(
                      child: Text(
                        driverName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 10.0,
                    ),

                    const Divider(
                      height: 2,
                      thickness: 2,
                      color: Colors.white54,
                    ),

                    const SizedBox(
                      height: 10.0,
                    ),

                    //driver vehicle details
                    Text(
                      AppLocalizations.of(context)!.theticketwillbe +
                          "\$ " +
                          RideFareAmount,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),

                    const SizedBox(
                      height: 2.0,
                    ),

                    //driver name
                    Text(
                      AppLocalizations.of(context)!.thedurationoftheraid +
                          RaidTime,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),

                    const SizedBox(
                      height: 15.0,
                    ),

                    const Divider(
                      height: 2,
                      thickness: 2,
                      color: Colors.white54,
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Text(
                      AppLocalizations.of(context)!
                              .thedriverwillarrivetothestationin +
                          RaidToStationTime,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),

                    const SizedBox(
                      height: 10.0,
                    ),

                    //call driver button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) => CheckOutScreen(
                                          referenceRideRequest:
                                              referenceRideRequest))); // DatabaseReference acceptRide = FirebaseDatabase
                              //     .instance
                              //     .ref()
                              //     .child("All Ride Requests")
                              //     .child(referenceRideRequest!.key!);
                              //
                              // acceptRide.update({
                              //   "status": "paid",
                              //   "driverId": chosenDriverId?.trim(),
                              //   "fareAmount": RideFareAmount.trim(),
                              //   "driverName": driverName.trim(),
                              // });

                              //Navigator.pushNamed(context, HomeScreen.id);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                            ),
                            icon: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Colors.black54,
                              size: 22,
                            ),
                            label: Text(
                              AppLocalizations.of(context)!.gotocheckout,
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              referenceRideRequest!.remove();
                              Navigator.pushNamed(context, HomeScreen.id);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                            ),
                            icon: const Icon(
                              Icons.cancel_outlined,
                              color: Colors.black54,
                              size: 22,
                            ),
                            label: Text(
                              AppLocalizations.of(context)!.cancel,
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: searchLocationContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    children: [
                      //from
                      Row(
                        children: [
                          const Icon(
                            Icons.add_location_alt_outlined,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.from,
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              Text(
                                Provider.of<AppInfo>(context)
                                            .userPickUpLocation !=
                                        null
                                    ? (Provider.of<AppInfo>(context)
                                                .userPickUpLocation!
                                                .locationName!)
                                            .substring(0, 24) +
                                        "..."
                                    : "not getting address",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10.0),

                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),

                      const SizedBox(height: 16.0),

                      //to
                      GestureDetector(
                        onTap: () async {},
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add_location_alt_outlined,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 12.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.to,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                                Text(
                                  Provider.of<AppInfo>(context)
                                              .userDropOffLocation !=
                                          null
                                      ? truncateString(
                                          Provider.of<AppInfo>(context)
                                              .userDropOffLocation!
                                              .locationName!,
                                          24)
                                      : "Where to go?",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10.0),

                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),

                      const SizedBox(height: 16.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.directions_bus_sharp,
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.selectadriver,
                                ),
                              ],
                            ),
                            onPressed: () {
                              if (isRedundentClick(DateTime.now())) {
                                print('hold on, processing');
                                return;
                              }

                              if (Provider.of<AppInfo>(context, listen: false)
                                      .userDropOffLocation !=
                                  null) {
                                saveRideRequestInformation();
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Please select destination location");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          ElevatedButton(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.white,
                                  size: 20.0,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.cancel,
                                ),
                              ],
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, HomeScreen.id);
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Localizations.override(
              context: context,
              locale: Locale('en', ''),
              child: Container(
                height: navBarContainerHeight + 1,
                child: DotNavigationBar(
                  currentIndex: _SelectedTab.values.indexOf(_selectedTab),
                  onTap: _handleIndexChanged,
                  // dotIndicatorColor: Colors.black,
                  items: [
                    /// Home
                    DotNavigationBarItem(
                      icon: Icon(Icons.home),
                      selectedColor: Colors.purple,
                    ),

                    /// Likes
                    DotNavigationBarItem(
                      icon: Icon(Icons.directions_bus_rounded),
                      selectedColor: Colors.pink,
                    ),

                    /// Search
                    DotNavigationBarItem(
                      icon: Icon(
                        locationSelected ? Icons.search : Icons.close,
                      ),
                      unselectedColor:
                          locationSelected ? Colors.black : Colors.red,
                      selectedColor: Colors.red,
                    ),

                    /// Profile
                    DotNavigationBarItem(
                      icon: Icon(Icons.person),
                      selectedColor: Colors.teal,
                    ),
                    DotNavigationBarItem(
                      icon: Icon(Icons.settings),
                      selectedColor: Colors.deepPurple,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> drawPolyLineFromOriginToDestination() async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition.locationLongitude!);

    // print("These are points = ");
    // print(directionDetailsInfo!.e_points);
    //
    PolylinePoints pPoints = PolylinePoints();
    // List<PointLatLng> decodedPolyLinePointsResultList =
    //     pPoints.decodePolyline(directionDetailsInfo!.e_points!);
    pLineCoOrdinatesList.clear();
    pLineCoOrdinatesList2.clear();
    pLineCoOrdinatesList3.clear();

    var closestToUser;
    var closestToDestination;
    Marker nearestMarkerToUser = Marker(markerId: MarkerId("nothing"));
    Marker nearestMarkerToDestination = Marker(markerId: MarkerId("nothing"));
    stationMarkersSet.forEach((element) async {
      if (closestToUser == null) {
        closestToUser = calculateDistance(
            originLatLng.latitude,
            originLatLng.longitude,
            element.position.latitude,
            element.position.longitude);
        nearestMarkerToUser = element;
        print("testing the new station alg == null");
        print(nearestMarkerToUser!.position);
        print("end of testing the new station alg");
      } else {
        if (closestToUser >
            calculateDistance(originLatLng.latitude, originLatLng.longitude,
                element.position.latitude, element.position.longitude)) {
          closestToUser = calculateDistance(
              originLatLng.latitude,
              originLatLng.longitude,
              element.position.latitude,
              element.position.longitude);
          nearestMarkerToUser = element;
        }
      }
    });

    stationMarkersSet.forEach((element) async {
      if (closestToDestination == null) {
        closestToDestination = calculateDistance(
            element.position.latitude,
            element.position.longitude,
            destinationLatLng.latitude,
            destinationLatLng.longitude);
        nearestMarkerToDestination = element;
      } else {
        if (closestToDestination >
            calculateDistance(
                element.position.latitude,
                element.position.longitude,
                destinationLatLng.latitude,
                destinationLatLng.longitude)) {
          closestToDestination = calculateDistance(
              element.position.latitude,
              element.position.longitude,
              destinationLatLng.latitude,
              destinationLatLng.longitude);
          nearestMarkerToDestination = element;
        }
      }
    });

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            nearestMarkerToUser.position, nearestMarkerToDestination.position);

    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    // //my att
    // PolylineResult result = await pPoints.getRouteBetweenCoordinates(
    //     "AIzaSyBrmrhO6Okkfo1noD68vaFC3TEUuu-UeY0",
    //     PointLatLng(originLatLng.latitude, originLatLng.longitude),
    //     PointLatLng(destinationLatLng.latitude, destinationLatLng.longitude),
    //     travelMode: TravelMode.driving,
    //     wayPoints: [
    //       PolylineWayPoint(
    //           location: nearestMarkerToUser.position.latitude.toString() +
    //               "," +
    //               nearestMarkerToUser.position.longitude.toString())
    //     ]);
    PolylineResult result = await pPoints.getRouteBetweenCoordinates(
        "AIzaSyBrmrhO6Okkfo1noD68vaFC3TEUuu-UeY0",
        PointLatLng(originLatLng.latitude, originLatLng.longitude),
        PointLatLng(nearestMarkerToUser.position.latitude,
            nearestMarkerToUser.position.longitude),
        travelMode: TravelMode.walking);

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        pLineCoOrdinatesList.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    PolylineId id1 = PolylineId("firstPolyline");
    Polyline polyline1 = Polyline(
      polylineId: id1,
      patterns: <PatternItem>[PatternItem.dot, PatternItem.gap(10.0)],
      color: Colors.deepOrange,
      points: pLineCoOrdinatesList,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: false,
      width: 5,
    );
    polyLineSet.add(polyline1);

    PolylineResult result2 = await pPoints.getRouteBetweenCoordinates(
        "AIzaSyBrmrhO6Okkfo1noD68vaFC3TEUuu-UeY0",
        PointLatLng(nearestMarkerToUser.position.latitude,
            nearestMarkerToUser.position.longitude),
        PointLatLng(nearestMarkerToDestination.position.latitude,
            nearestMarkerToDestination.position.longitude),
        travelMode: TravelMode.driving);
    if (result2.points.isNotEmpty) {
      result2.points.forEach((PointLatLng point) {
        pLineCoOrdinatesList2.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }

    PolylineId id2 = PolylineId("secondPolyline");
    Polyline polyline2 = Polyline(
      polylineId: id2,
      color: Colors.blue,
      points: pLineCoOrdinatesList2,
      width: 5,
    );
    polyLineSet.add(polyline2);

    PolylineResult result3 = await pPoints.getRouteBetweenCoordinates(
        "AIzaSyBrmrhO6Okkfo1noD68vaFC3TEUuu-UeY0",
        PointLatLng(nearestMarkerToDestination.position.latitude,
            nearestMarkerToDestination.position.longitude),
        PointLatLng(destinationLatLng.latitude, destinationLatLng.longitude),
        travelMode: TravelMode.walking);
    if (result3.points.isNotEmpty) {
      result3.points.forEach((PointLatLng point) {
        pLineCoOrdinatesList3.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }

    PolylineId id3 = PolylineId("thirdPolyline");
    Polyline polyline3 = Polyline(
      polylineId: id3,
      color: Colors.deepOrange,
      points: pLineCoOrdinatesList3,
      width: 5,
    );
    polyLineSet.add(polyline3);
    setState(() {});

    //driver to busStation time

    for (ActiveNearbyAvailableDrivers eachDriver
        in GeoFireAssistant.activeNearbyAvailableDriversList) {
      LatLng eachDriverActivePosition =
          LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

      var directionDetailsInfo =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
              eachDriverActivePosition, nearestMarkerToUser.position);

      DriverToStationInfo?.add(directionDetailsInfo!);
    }

    // //end my att
    // if (decodedPolyLinePointsResultList.isNotEmpty) {
    //   decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
    //     pLineCoOrdinatesList
    //         .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
    //   });
    // }
    //
    // polyLineSet.clear();
    //
    // setState(() {
    //   //polyline attributes
    //   Polyline polyline = Polyline(
    //     color: Colors.purpleAccent,
    //     polylineId: const PolylineId("PolylineID"),
    //     jointType: JointType.round,
    //     points: pLineCoOrdinatesList,
    //     startCap: Cap.roundCap,
    //     endCap: Cap.roundCap,
    //     geodesic: true,
    //   );
    //
    //   polyLineSet.add(polyline);
    // });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow:
          InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: OriginIcon!,
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: DestinationIcon!,
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });
  }

  initializeGeoFireListener() {
    Geofire.initialize("activeDrivers");

    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 20)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          //whenever any driver become active/online
          case Geofire.onKeyEntered:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver =
                ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireAssistant.activeNearbyAvailableDriversList
                .add(activeNearbyAvailableDriver);
            print("activeNearbyDriverKeysLoaded");
            print(activeNearbyDriverKeysLoaded);
            if (activeNearbyDriverKeysLoaded == true) {
              displayActiveDriversOnUsersMap();
            }
            break;

          //whenever any driver become non-active/offline
          case Geofire.onKeyExited:
            GeoFireAssistant.deleteOfflineDriverFromList(map['key']);
            displayActiveDriversOnUsersMap();
            break;

          //whenever driver moves - update driver location
          case Geofire.onKeyMoved:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver =
                ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireAssistant.updateActiveNearbyAvailableDriverLocation(
                activeNearbyAvailableDriver);
            displayActiveDriversOnUsersMap();
            break;

          //display those online/active drivers on user's map
          case Geofire.onGeoQueryReady:
            activeNearbyDriverKeysLoaded = true;
            displayActiveDriversOnUsersMap();
            break;
        }
      }

      setState(() {});
    });
  }

  displayActiveDriversOnUsersMap() {
    setState(() {
      loadData();
      stationMarkersSetOnThePath.clear();
      circlesSet.clear();

      Set<Marker> driversMarkerSet = Set<Marker>();

      for (ActiveNearbyAvailableDrivers eachDriver
          in GeoFireAssistant.activeNearbyAvailableDriversList) {
        LatLng eachDriverActivePosition =
            LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

        Marker marker = Marker(
          markerId: MarkerId("driver" + eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );

        driversMarkerSet.add(marker);
      }

      markersSet = driversMarkerSet;
      loadData();
    });
  }

  createActiveNearByDriverIconMarker() {
    if (activeNearbyIcon == null) {
      //ImageConfiguration imageConfiguration =
      //createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              ImageConfiguration(size: Size(2, 2)), 'images/Bus.png')
          .then((value) {
        activeNearbyIcon = value;
      });
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  bool isRedundentClick(DateTime currentTime) {
    print('diff is ${currentTime.difference(loginClickTime).inSeconds}');
    if (currentTime.difference(loginClickTime).inSeconds < 10) {
      //set this difference time in seconds
      return true;
    }

    loginClickTime = currentTime;
    return false;
  }

  String truncateString(String data, int length) {
    return (data.length >= length) ? '${data.substring(0, length)}...' : data;
  }
}

enum _SelectedTab { home, UserTicket, search, person, settings }
