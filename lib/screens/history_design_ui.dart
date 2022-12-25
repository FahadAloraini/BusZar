import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testing_phase1/screens/rate_driver_screen.dart';
import 'package:testing_phase1/screens/report_ui.dart';
import '../components/global.dart';
import '../components/trips_history_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HistoryDesignUIWidget extends StatefulWidget {
  TripsHistoryModel? tripsHistoryModel;

  HistoryDesignUIWidget({this.tripsHistoryModel});

  @override
  State<HistoryDesignUIWidget> createState() => _HistoryDesignUIWidgetState();
}

class _HistoryDesignUIWidgetState extends State<HistoryDesignUIWidget> {
  String formatDateAndTime(String dateTimeFromDB) {
    DateTime dateTime = DateTime.parse(dateTimeFromDB);

    // Dec 10                            //2022                         //1:12 pm
    String formattedDatetime =
        "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";

    return formattedDatetime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            spreadRadius: 3,
            blurRadius: 9,
            offset: Offset(0, 4), // changes position of shadowhadow position
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //driver name + Fare Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Text(
                    AppLocalizations.of(context)!.driver +
                        ": " +
                        widget.tripsHistoryModel!.driverName!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Text(
                  "\$ " + widget.tripsHistoryModel!.fareAmount!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 2,
            ),

            //icon + pickup
            Row(
              children: [
                Image.asset(
                  "images/origin.png",
                  height: 26,
                  width: 26,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Container(
                    child: Text(
                      widget.tripsHistoryModel!.originAddress!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            //icon + dropOff
            Row(
              children: [
                Image.asset(
                  "images/destination.png",
                  height: 24,
                  width: 24,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Container(
                    child: Text(
                      widget.tripsHistoryModel!.destinationAddress!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            //trip time and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(""),
                Text(
                  formatDateAndTime(widget.tripsHistoryModel!.time!),
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  child: Text(
                    AppLocalizations.of(context)!.ratethedriver,
                  ),
                  onPressed: () {
                    DatabaseReference rateDriverRef = FirebaseDatabase.instance
                        .ref()
                        .child("All Ride Requests")
                        .child(widget.tripsHistoryModel!.TripID!)
                        .child("rated?");

                    rateDriverRef.once().then((snap) {
                      if (snap.snapshot.value == null) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return RateDriverScreen(
                                  assignedDriverId: chosenDriverId,
                                  tripID: widget.tripsHistoryModel!.TripID!);
                            });
                      } else {
                        Fluttertoast.showToast(msg: "Driver was already rated");
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Colors.yellow.shade700,
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  child: Text(
                    AppLocalizations.of(context)!.report,
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ReportUI(
                              TripID: widget.tripsHistoryModel!.TripID!);
                        });
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(
              height: 2,
            ),
          ],
        ),
      ),
    );
  }
}
