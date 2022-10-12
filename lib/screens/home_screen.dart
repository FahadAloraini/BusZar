import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:testing_phase1/screens/profile_screen.dart';
import 'package:testing_phase1/screens/search_screen.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:testing_phase1/screens/settings_screen.dart';
import 'package:testing_phase1/screens/user_ticket_screen.dart';
import '../components/directions_model.dart';
import '../components/directions_repository.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:testing_phase1/components/rounded_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static final CameraPosition _DefultGoogleMap = CameraPosition(
    target: LatLng(26.236355, 50.032600),
    zoom: 12,
  );
  late Directions? _info = null;
  late GoogleMapController _googleMapController;
  late Marker _Origin = Marker(
    visible: true,
    markerId: const MarkerId('origin'),
    infoWindow: const InfoWindow(title: 'origin'),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    position: LatLng(26.236355, 50.032600),
  );
  late Marker _Destination = Marker(
    visible: false,
    markerId: const MarkerId('Destination'),
  );

  late AnimationController controller;
  late Animation animation;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User loggedInUser;

  var _selectedTab = _SelectedTab.home;
  void _handleIndexChanged(int i) {
    setState(() {
      _selectedTab = _SelectedTab.values[i];
      i == 1 ? Navigator.pushNamed(context, UserTicket.id) : null;
      i == 2 ? Navigator.pushNamed(context, SearchScreen.id) : null;
      i == 3 ? Navigator.pushNamed(context, ProfileScreen.id) : null;
      i == 4 ? Navigator.pushNamed(context, SettingsScreen.id) : null;
      print(i);
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print("loged in" + loggedInUser.email.toString());
        setState(() {});
      } else {
        print("not logged in");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HomePage"),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (_Origin.visible)
            TextButton(
                onPressed: () => _googleMapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _Origin.position,
                          zoom: 14.5,
                          tilt: 50.0,
                        ),
                      ),
                    ),
                style: TextButton.styleFrom(
                    primary: Colors.green,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600)),
                child: Text("Origin")),
          if (_Destination.visible)
            TextButton(
                onPressed: () => _googleMapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _Destination.position,
                          zoom: 14.5,
                          tilt: 50.0,
                        ),
                      ),
                    ),
                style: TextButton.styleFrom(
                    primary: Colors.blue,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600)),
                child: Text("Destination")), // Navigate to the Search Screen
          IconButton(
              onPressed: () => Navigator.pushNamed(context, SearchScreen.id),
              icon: Icon(Icons.search))
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            markers: {
              if (_Origin != null) _Origin,
              if (_Destination != null) _Destination
            },
            polylines: {
              if (_info != null)
                Polyline(
                  polylineId: const PolylineId('overview_polyline'),
                  color: Colors.red,
                  width: 5,
                  points: _info!.polylinePoints
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                ),
            },
            onLongPress: AddMarker,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _DefultGoogleMap,
            onMapCreated: (controller) => _googleMapController = controller,
          ),
          if (_info != null)
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
                  '${_info!.totalDistance}, ${_info!.totalDuration}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed: () => _googleMapController.animateCamera(
          _info != null
              ? CameraUpdate.newLatLngBounds(_info!.bounds, 100.0)
              : CameraUpdate.newCameraPosition(_DefultGoogleMap),
        ),
        child: const Icon(Icons.center_focus_strong),
      ),
      bottomNavigationBar: DotNavigationBar(
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
            icon: Icon(Icons.search),
            selectedColor: Colors.orange,
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
    );
  }

  void AddMarker(LatLng pos) async {
    setState(() {
      _Destination = Marker(
        visible: true,
        markerId: const MarkerId('destination'),
        infoWindow: const InfoWindow(title: 'destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: pos,
      );
    });
    // Get directions
    final directions = await DirectionsRepository()
        .getDirections(origin: _Origin.position, destination: pos);
    setState(() => _info = directions!);
  }
}

enum _SelectedTab { home, UserTicket, search, person, settings }
