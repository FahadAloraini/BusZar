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

import '../constants.dart';

class VoucherUI extends StatefulWidget {
  @override
  State<VoucherUI> createState() => _VoucherUIState();
}

class _VoucherUIState extends State<VoucherUI> {
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
                AppLocalizations.of(context)!.voucher,
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
              padding: const EdgeInsets.symmetric(horizontal: 10),
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
                  hintText: "hint: 123",
                  labelText: AppLocalizations.of(context)!.voucher,
                  labelStyle: TextStyle(
                      color: Colors.deepPurpleAccent,
                      fontWeight: FontWeight.bold),
                ),
                maxLines: 1,
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
                  if (ReportText == "123") {
                    DatabaseReference ref = FirebaseDatabase.instance
                        .ref()
                        .child("user")
                        .child(userModelCurrentInfo!.id.toString())
                        .child('wallet');
                    ref.once().then((snap) {
                      if (snap.snapshot.value == null) {
                        ref.set("10");
                        userModelCurrentInfo?.wallet = "10";
                        Navigator.pop(context);
                        //SystemNavigator.pop();
                      } else {
                        double pastWallet =
                            double.parse(snap.snapshot.value.toString());
                        double newWallet = (pastWallet + 10);
                        ref.set(newWallet.toString());
                        userModelCurrentInfo?.wallet = newWallet.toString();
                        Navigator.pop(context);
                        //SystemNavigator.pop();
                      }
                    });
                  } else {
                    Fluttertoast.showToast(msg: "Voucher Code invalid");
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
