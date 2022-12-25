import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:testing_phase1/components/global.dart';
import 'dart:developer';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:testing_phase1/components/rounded_button.dart';
import 'package:testing_phase1/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:testing_phase1/components/PopUp.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants.dart';

class MissingItemReportUI extends StatefulWidget {
  String? TripID;

  MissingItemReportUI({this.TripID});
  @override
  State<MissingItemReportUI> createState() => _MissingItemReportUIState();
}

class _MissingItemReportUIState extends State<MissingItemReportUI> {
  @override
  String ReportText = "";
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
                AppLocalizations.of(context)!.howcanwehelp,
                style: TextStyle(
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.deepPurple),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 3, color: Colors.red),
                  ),
                  hintText: AppLocalizations.of(context)!
                      .writeadescriptionabouttheitem,
                  labelText: AppLocalizations.of(context)!.itemdescription,
                  labelStyle: TextStyle(
                      color: Colors.deepPurpleAccent,
                      fontWeight: FontWeight.bold),
                ),
                maxLines: 4,
                onChanged: (value) {
                  ReportText = value;
                },
              ),
            ),

            const SizedBox(
              height: 18.0,
            ),
            ElevatedButton(
                onPressed: () {
                  if (!ReportText.isEmpty) {
                    FirebaseFirestore.instance.collection('ReportItem').add({
                      'Email': userModelCurrentInfo?.email.toString(),
                      'TicketNumber': widget.TripID,
                      'Description': ReportText
                    });
                    Fluttertoast.showToast(msg: "Report submitted");
                    Navigator.of(context).pop();
                  } else {
                    Fluttertoast.showToast(
                        msg: "you can not submit an empty report");
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 74),
                ),
                child: Text(
                  AppLocalizations.of(context)!.submit,
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
