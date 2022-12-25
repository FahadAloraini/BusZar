import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:testing_phase1/components/global.dart';

class RateDriverScreen extends StatefulWidget {
  static const String id = 'rate_driver_screen';
  String? assignedDriverId;
  String? tripID;

  RateDriverScreen({this.assignedDriverId, this.tripID});

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
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
          color: Colors.white54,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 22.0,
            ),
            const Text(
              "Rate Trip Experience",
              style: TextStyle(
                fontSize: 22,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
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
            SmoothStarRating(
              rating: countRatingStars,
              allowHalfRating: false,
              starCount: 5,
              color: Colors.green,
              borderColor: Colors.green,
              size: 46,
              onRatingChanged: (valueOfStarsChoosed) {
                countRatingStars = valueOfStarsChoosed;

                if (countRatingStars == 1) {
                  setState(() {
                    titleStarsRating = "Very Bad";
                  });
                }
                if (countRatingStars == 2) {
                  setState(() {
                    titleStarsRating = "Bad";
                  });
                }
                if (countRatingStars == 3) {
                  setState(() {
                    titleStarsRating = "Good";
                  });
                }
                if (countRatingStars == 4) {
                  setState(() {
                    titleStarsRating = "Very Good";
                  });
                }
                if (countRatingStars == 5) {
                  setState(() {
                    titleStarsRating = "Excellent";
                  });
                }
              },
            ),
            const SizedBox(
              height: 12.0,
            ),
            Text(
              titleStarsRating,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(
              height: 18.0,
            ),
            ElevatedButton(
                onPressed: () {
                  DatabaseReference rateDriverRef = FirebaseDatabase.instance
                      .ref()
                      .child("All Ride Requests")
                      .child(widget.tripID!)
                      .child("rated?");

                  rateDriverRef.set("yes");

                  rateDriverRef = FirebaseDatabase.instance
                      .ref()
                      .child("driver")
                      .child(widget.assignedDriverId!)
                      .child("ratings");

                  DatabaseReference NumrateDriverRef = FirebaseDatabase.instance
                      .ref()
                      .child("All Ride Requests")
                      .child(widget.tripID!)
                      .child("num ratings");

                  rateDriverRef.once().then((snap) {
                    if (snap.snapshot.value == null) {
                      rateDriverRef.set(countRatingStars.toString());
                      NumrateDriverRef.set("1");
                      Fluttertoast.showToast(msg: "Thank You for rating");
                      Navigator.pop(context);
                      //SystemNavigator.pop();
                    } else {
                      NumrateDriverRef.once().then((snap2) {
                        double pastRatings =
                            double.parse(snap.snapshot.value.toString());
                        double pastNumRatings =
                            double.parse(snap2.snapshot.value.toString()) + 1;
                        NumrateDriverRef.set(pastNumRatings.toString());
                        double newAverageRatings =
                            (pastRatings + countRatingStars) / pastNumRatings;
                        rateDriverRef.set(newAverageRatings.toString());
                        Fluttertoast.showToast(msg: "Thank You for rating");
                        Navigator.pop(context);
                      });

                      //SystemNavigator.pop();
                    }

                    //Fluttertoast.showToast(msg: "Please Restart App Now");
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 74),
                ),
                child: const Text(
                  "Submit",
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
