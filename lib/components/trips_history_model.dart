import 'package:firebase_database/firebase_database.dart';

class TripsHistoryModel {
  String? time;
  String? originAddress;
  String? destinationAddress;
  //String? status;
  String? fareAmount;
  //String? car_details;
  String? driverName;
  String? TripID;
  String? DriverToStationTime;
  String? duration;
  String? PlaceID;

  TripsHistoryModel({
    this.time,
    this.originAddress,
    this.destinationAddress,
    //this.status,
    this.fareAmount,
    //this.car_details,
    this.driverName,
    this.TripID,
    this.DriverToStationTime,
    this.duration,
    this.PlaceID,
  });

  TripsHistoryModel.fromSnapshot(DataSnapshot dataSnapshot) {
    time = (dataSnapshot.value as Map)["time"];
    originAddress = (dataSnapshot.value as Map)["originAddress"];
    destinationAddress = (dataSnapshot.value as Map)["destinationAddress"];
    //status = (dataSnapshot.value as Map)["status"];
    fareAmount = (dataSnapshot.value as Map)["fareAmount"];
    //car_details = (dataSnapshot.value as Map)["car_details"];
    driverName = (dataSnapshot.value as Map)["driverName"];
    TripID = dataSnapshot.key;
    DriverToStationTime = (dataSnapshot.value as Map)["DriverToStationTime"];
    duration = (dataSnapshot.value as Map)["duration"];
    PlaceID = (dataSnapshot.value as Map)["PlaceID"];
  }
}
