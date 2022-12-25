import 'package:firebase_auth/firebase_auth.dart';
import 'package:testing_phase1/components/user_model.dart';

import 'direction_details_info.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
List dList = []; //online-active drivers Information List
DirectionDetailsInfo? tripDirectionDetailsInfo;
List<DirectionDetailsInfo> DriverToStationInfo = [];
String? chosenDriverId = "";
String driverName = "";
String driverPhone = "";
double countRatingStars = 0.0;
String titleStarsRating = "";
String RideFareAmount = "";
String PlaceID = "";
String RaidTime = "";
String RaidToStationTime = "";
bool isSwitched = true;
bool DarkMode = true;
