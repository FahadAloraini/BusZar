import 'dart:ffi';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:testing_phase1/screens/rate_driver_screen.dart';
import 'package:testing_phase1/screens/trips_ticket_ui.dart';
import '../components/app_info.dart';
import '../components/directions.dart';
import '../components/global.dart';
import '../components/request_assistant.dart';
import '../components/trips_history_model.dart';
import 'history_design_ui.dart';

class TripsScreen extends StatefulWidget {
  static const String id = 'trips_screen';
  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  @override
  DateTime now = DateTime.now();
  List<TripsHistoryModel>? tripsHistoryModelTemp;
  late int itemCount;
  late Duration diff;
  late double totalTime;
  void initState() {
    // TODO: implement initState
    super.initState();
    tripsHistoryModelTemp = Provider.of<AppInfo>(context, listen: false)
        .allTripsHistoryInformationList;

    var seen = Set<String>();
    List<TripsHistoryModel> uniquelist =
        tripsHistoryModelTemp!.where((d) => seen.add(d.TripID!)).toList();
    tripsHistoryModelTemp = uniquelist;

    itemCount = tripsHistoryModelTemp!.length;
    uniquelist = [];
    for (var i = 0; i < tripsHistoryModelTemp!.length; i++) {
      diff = now.difference(DateTime.parse(tripsHistoryModelTemp![i].time!));
      totalTime = double.parse(tripsHistoryModelTemp![i]
              .DriverToStationTime!
              .toString()
              .substring(
                  0,
                  tripsHistoryModelTemp![i]
                          .DriverToStationTime!
                          .toString()
                          .length -
                      4)) +
          double.parse(tripsHistoryModelTemp![i].duration!.toString().substring(
              0, tripsHistoryModelTemp![i].duration!.toString().length - 4));
      print(diff.inMinutes.toString());
      print(totalTime.toString());
      if (diff.inMinutes < totalTime) {
        uniquelist.add(tripsHistoryModelTemp![i]);
      }
    }
    tripsHistoryModelTemp = uniquelist;
    itemCount = tripsHistoryModelTemp!.length;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(AppLocalizations.of(context)!.trips),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
            // SystemNavigator.pop();
          },
        ),
      ),
      body: ListView.separated(
        separatorBuilder: (context, i) => const Divider(
          color: Colors.white,
          thickness: 0,
          height: 2,
        ),
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () async {
              print("test cards");
              await getPlaceDirectionDetails(
                  tripsHistoryModelTemp![i].PlaceID, context);
              //Navigator.pushNamed(context, RateDriverScreen.id);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (c) =>
              //             RateDriverScreen(assignedDriverId: chosenDriverId)));
            },
            child: Card(
              color: Colors.white54,
              child: TripsTicketUIWidget(
                tripsHistoryModel: tripsHistoryModelTemp![i],
                //Provider.of<AppInfo>(context, listen: false)
                // .allTripsHistoryInformationList[i],
              ),
            ),
          );
        },
        itemCount: itemCount,
        // Provider.of<AppInfo>(context, listen: false)
        //   .allTripsHistoryInformationList
        //   .length,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }

  getPlaceDirectionDetails(String? placeId, context) async {
    String placeDirectionDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=AIzaSyBrmrhO6Okkfo1noD68vaFC3TEUuu-UeY0";
    var responseApi =
        await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);

    if (responseApi == "Error Occurred, Failed. No Response.") {
      return;
    }
    print("place ID");
    print(placeId);
    if (responseApi["status"] == "OK") {
      Directions directions = Directions();
      directions.locationName = responseApi["result"]["name"];
      directions.locationId = placeId;
      directions.locationLatitude =
          responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude =
          responseApi["result"]["geometry"]["location"]["lng"];

      Provider.of<AppInfo>(context, listen: false)
          .updateDropOffLocationAddress(directions);

      Navigator.pop(context, "obtainedDropoff");
    }
  }
}
