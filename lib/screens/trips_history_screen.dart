import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:testing_phase1/screens/rate_driver_screen.dart';
import '../components/app_info.dart';
import '../components/global.dart';
import '../components/trips_history_model.dart';
import 'history_design_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TripsHistoryScreen extends StatefulWidget {
  static const String id = 'trips_history_screen';
  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
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
      if (diff.inMinutes > totalTime) {
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
        title: Text(AppLocalizations.of(context)!.triphistory),
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
          height: 0,
        ),
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () {
              //Navigator.pushNamed(context, RateDriverScreen.id);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (c) =>
              //             RateDriverScreen(assignedDriverId: chosenDriverId)));
            },
            child: Card(
              color: Colors.white,
              child: HistoryDesignUIWidget(
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
}
