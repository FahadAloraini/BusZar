import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:testing_phase1/components/global.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'complaint_report_ui.dart';
import 'missing_item_report_ui.dart';

class ReportUI extends StatefulWidget {
  String? TripID;

  ReportUI({this.TripID});

  @override
  State<ReportUI> createState() => _ReportUIState();
}

class _ReportUIState extends State<ReportUI> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      backgroundColor: Colors.white60,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 22.0,
            ),
            Opacity(
              opacity: 0.8,
              child: Text(
                AppLocalizations.of(context)!.whatseemstobetheproblem,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),
            ),
            const SizedBox(
              height: 22.0,
            ),
            const Divider(
              height: 4.0,
              thickness: 4.0,
            ),
            const SizedBox(
              height: 22.0,
            ),

            //buttons here
            ElevatedButton(
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return MissingItemReportUI(TripID: widget.TripID!);
                      });

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 74),
                ),
                child: Text(
                  AppLocalizations.of(context)!.missingitem,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )),

            const SizedBox(
              height: 18.0,
            ),
            ElevatedButton(
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ComplaintReportUI(TripID: widget.TripID!);
                      });

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 50),
                ),
                child: Text(
                  AppLocalizations.of(context)!.complaintreport,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )),
            const SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }
}
