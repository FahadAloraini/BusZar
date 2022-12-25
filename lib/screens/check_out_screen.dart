import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:testing_phase1/screens/rate_driver_screen.dart';
import 'package:testing_phase1/screens/voucher_ui.dart';
import '../components/app_info.dart';
import '../components/global.dart';
import '../components/trips_history_model.dart';
import 'history_design_ui.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_ui_challenges/core/presentation/widgets/rounded_bordered_container.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'home_screen.dart';

class CheckOutScreen extends StatefulWidget {
  static const String id = 'check_out_screen';
  DatabaseReference? referenceRideRequest;
  CheckOutScreen({this.referenceRideRequest});
  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  @override
  String Wallet = userModelCurrentInfo!.wallet.toString();
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.chooseyourplan,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          spreadRadius: 3,
                          blurRadius: 9,
                          offset: Offset(
                              0, 4), // changes position of shadowhadow position
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 8.0,
                    ),
                    padding: EdgeInsets.only(bottom: 10, top: 10, left: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(context)!.currentwallet,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22.0,
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          "\$" +
                              double.parse(Wallet)
                                  .toStringAsFixed(1)
                                  .toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 24.0,
                          ),
                        ),
                        SizedBox(height: 20.0),
                        GestureDetector(
                          onTap: () async {
                            await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return VoucherUI();
                                });

                            setState(() {
                              Wallet = userModelCurrentInfo!.wallet.toString();
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(0),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              leading: Icon(
                                IconData(0xf06bd, fontFamily: 'MaterialIcons'),
                                color: Colors.indigo,
                              ),
                              title:
                                  Text(AppLocalizations.of(context)!.voucher),
                              trailing: Icon(Icons.arrow_forward_ios),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30.0),
            GestureDetector(
              onTap: () {
                Fluttertoast.showToast(msg: "currently unavailable ");
              },
              child: const RoundedContainer(
                margin: EdgeInsets.all(8.0),
                padding: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(
                    FontAwesomeIcons.paypal,
                    color: Colors.indigo,
                  ),
                  title: Text("Paypal"),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Fluttertoast.showToast(msg: "currently unavailable ");
              },
              child: const RoundedContainer(
                margin: EdgeInsets.all(8.0),
                padding: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(
                    FontAwesomeIcons.googleWallet,
                    color: Colors.indigo,
                  ),
                  title: Text("Google Pay"),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Fluttertoast.showToast(msg: "currently unavailable ");
              },
              child: const RoundedContainer(
                margin: EdgeInsets.all(8.0),
                padding: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(
                    FontAwesomeIcons.applePay,
                    color: Colors.indigo,
                  ),
                  title: Text("Apple Pay"),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                DatabaseReference acceptRide = FirebaseDatabase.instance
                    .ref()
                    .child("All Ride Requests")
                    .child(widget.referenceRideRequest!.key!);
                DatabaseReference refWallet = FirebaseDatabase.instance
                    .ref()
                    .child("user")
                    .child(userModelCurrentInfo!.id.toString())
                    .child('wallet');

                print(double.parse(RideFareAmount).toString());
                print(double.parse(userModelCurrentInfo!.wallet.toString())
                    .toString());

                if (double.parse(RideFareAmount) >
                    double.parse(userModelCurrentInfo!.wallet.toString())) {
                  Fluttertoast.showToast(msg: "insufficient funds");
                } else {
                  acceptRide.update({
                    "PlaceID": PlaceID,
                    "status": "paid",
                    "driverId": chosenDriverId?.trim(),
                    "fareAmount": RideFareAmount.trim(),
                    "driverName": driverName.trim(),
                  });

                  refWallet.once().then((snap2) {
                    double pastWallet =
                        double.parse(snap2.snapshot.value.toString());
                    double newWallet =
                        (pastWallet - double.parse(RideFareAmount));
                    refWallet.set(newWallet.toString());
                    userModelCurrentInfo?.wallet = newWallet.toString();
                  });
                  Fluttertoast.showToast(msg: "Ticket purchased");

                  Navigator.pushNamed(context, HomeScreen.id);
                }
              },
              child: RoundedContainer(
                margin: EdgeInsets.all(8.0),
                padding: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(
                    FontAwesomeIcons.wallet,
                    color: Colors.indigo,
                  ),
                  title: Text(AppLocalizations.of(context)!.wallet),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.symmetric(
            //     vertical: 16.0,
            //     horizontal: 32.0,
            //   ),
            //   child: ElevatedButton(
            //     style: ElevatedButton.styleFrom(
            //       primary: Colors.deepPurple,
            //       padding: EdgeInsets.all(24),
            //     ),
            //     child: Text("Continue"),
            //     onPressed: () {
            //       DatabaseReference acceptRide = FirebaseDatabase.instance
            //           .ref()
            //           .child("All Ride Requests")
            //           .child(widget.referenceRideRequest!.key!);
            //
            //       acceptRide.update({
            //         "status": "paid",
            //         "driverId": chosenDriverId?.trim(),
            //         "fareAmount": RideFareAmount.trim(),
            //         "driverName": driverName.trim(),
            //       });
            //
            //       Navigator.pushNamed(context, HomeScreen.id);
            //     },
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}

class RoundedContainer extends StatelessWidget {
  const RoundedContainer({
    Key? key,
    required this.child,
    this.height,
    this.width,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.borderRadius,
    this.alignment,
    this.elevation,
  }) : super(key: key);
  final Widget child;
  final double? width;
  final double? height;
  final Color color;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final AlignmentGeometry? alignment;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.all(0),
      color: color,
      elevation: elevation ?? 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(20.0),
      ),
      child: Container(
        alignment: alignment,
        height: height,
        width: width,
        padding: padding,
        child: child,
      ),
    );
  }
}
