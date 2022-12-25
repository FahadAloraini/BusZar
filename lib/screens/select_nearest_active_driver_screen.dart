import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:testing_phase1/components/global.dart';
import 'package:firebase_database/firebase_database.dart';
import '../components/assistant_methods.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectNearestActiveDriversScreen extends StatefulWidget {
  DatabaseReference? referenceRideRequest;
  SelectNearestActiveDriversScreen({this.referenceRideRequest});
  @override
  _SelectNearestActiveDriversScreenState createState() =>
      _SelectNearestActiveDriversScreenState();
}

class _SelectNearestActiveDriversScreenState
    extends State<SelectNearestActiveDriversScreen> {
  String fareAmount = "";

  getFareAmountAccordingToVehicleType(int index) {
    if (tripDirectionDetailsInfo != null) {
      fareAmount = (AssistantMethods.calculateFareAmountFromOriginToDestination(
              tripDirectionDetailsInfo!))
          .toString();
    }
    return fareAmount;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var seen = Set<String>();
    List<dynamic> uniquelist = dList.where((d) => seen.add(d["name"])).toList();
    dList = uniquelist;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          AppLocalizations.of(context)!.nearestonlinedrivers,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            //delete/remove the ride request from database
            widget.referenceRideRequest!.remove();
            dList.clear();
            SystemNavigator.pop();
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: dList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                chosenDriverId = dList[index]["id"].toString();
                driverName = dList[index]["name"].toString();
                RideFareAmount = getFareAmountAccordingToVehicleType(index);

                DatabaseReference acceptRide = FirebaseDatabase.instance
                    .ref()
                    .child("All Ride Requests")
                    .child(widget.referenceRideRequest!.key!);
                acceptRide.update({
                  "DriverToStationTime":
                      DriverToStationInfo![index]!.duration_text!,
                  "duration": tripDirectionDetailsInfo!.duration_text!
                });
                RaidToStationTime = DriverToStationInfo![index]!.duration_text!;
                RaidTime = tripDirectionDetailsInfo!.duration_text!;
              });
              Navigator.pop(context, "driverChoosed");
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: Colors.black,
                ),
              ),
              color: Colors.white,
              elevation: 10,
              shadowColor: Colors.black,
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Image.asset(
                      "images/BusH.png",
                      width: 60,
                    ),
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        dList[index]["name"],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 3),
                      SmoothStarRating(
                        rating: dList[index]["ratings"] == null
                            ? 0.0
                            : double.parse(dList[index]["ratings"]),
                        color: Colors.yellow.shade800,
                        borderColor: Colors.yellow.shade800,
                        allowHalfRating: true,
                        starCount: 5,
                        size: 20,
                      ),
                      SizedBox(height: 8),
                      Text(
                        DriverToStationInfo![index] != null
                            ? AppLocalizations.of(context)!
                                    .thedriverwillarrivetothestationin +
                                DriverToStationInfo![index]!.duration_text!
                            : "",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "\$ " + getFareAmountAccordingToVehicleType(index),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        tripDirectionDetailsInfo != null
                            ? tripDirectionDetailsInfo!.duration_text!
                            : "",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontSize: 12),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        tripDirectionDetailsInfo != null
                            ? tripDirectionDetailsInfo!.distance_text!
                            : "",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
