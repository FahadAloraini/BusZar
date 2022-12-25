import 'package:flutter/material.dart';
import 'package:testing_phase1/components/rounded_button.dart';
import 'package:testing_phase1/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testing_phase1/screens/home_screen.dart';
import 'package:testing_phase1/screens/welcome_screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:testing_phase1/components/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController nametexteditingcontroller = TextEditingController();
  TextEditingController emailtexteditingcontroller = TextEditingController();
  TextEditingController phonetexteditingcontroller = TextEditingController();
  TextEditingController passwordtexteditingcontroller = TextEditingController();

  validateForm() {
    if (nametexteditingcontroller.text.length < 3) {
      Fluttertoast.showToast(msg: "name must be atleast 3 Characters.");
    } else if (!emailtexteditingcontroller.text.contains("@")) {
      Fluttertoast.showToast(msg: "Email address is not Valid.");
    } else if (phonetexteditingcontroller.text.isEmpty) {
      Fluttertoast.showToast(msg: "Phone Number is required.");
    } else if (passwordtexteditingcontroller.text.length < 6) {
      Fluttertoast.showToast(msg: "Password must be atleast 6 Characters.");
    } else {
      saveInfoNow();
    }
  }

  saveInfoNow() async {
    final User? firebaseUser = (await fAuth
            .createUserWithEmailAndPassword(
      email: emailtexteditingcontroller.text.trim(),
      password: passwordtexteditingcontroller.text.trim(),
    )
            .catchError((msg) {
      //Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error: " + msg.toString());
    }))
        .user;

    if (firebaseUser != null) {
      Map userMap = {
        "id": firebaseUser.uid,
        "name": nametexteditingcontroller.text.trim(),
        "email": emailtexteditingcontroller.text.trim(),
        "phone": phonetexteditingcontroller.text.trim(),
        "wallet": "0",
      };

      DatabaseReference usersRef =
          FirebaseDatabase.instance.ref().child("user");
      usersRef.child(firebaseUser.uid).set(userMap);

      currentFirebaseUser = firebaseUser;
      Fluttertoast.showToast(msg: "Account has been Created.");
      Navigator.pushNamed(context, HomeScreen.id);
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Account has not been Created.");
    }
  }

  bool showSpinner = false;
  late List Ticket = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    WavyAnimatedText('SignUp', textAlign: TextAlign.center),
                  ],
                  totalRepeatCount: 1,
                  // repeatForever: true,
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                controller: nametexteditingcontroller,
                decoration: kTextFieldDecoration.copyWith(
                    hintText: AppLocalizations.of(context)!.enterYour +
                        " " +
                        AppLocalizations.of(context)!.name),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.phone,
                controller: phonetexteditingcontroller,
                decoration: kTextFieldDecoration.copyWith(
                    hintText: AppLocalizations.of(context)!.enterYour +
                        " " +
                        AppLocalizations.of(context)!.phoneNumber),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                controller: emailtexteditingcontroller,
                decoration: kTextFieldDecoration.copyWith(
                    hintText: AppLocalizations.of(context)!.enterYour +
                        " " +
                        AppLocalizations.of(context)!.email),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                controller: passwordtexteditingcontroller,
                decoration: kTextFieldDecoration.copyWith(
                    hintText: AppLocalizations.of(context)!.enterYour +
                        " " +
                        AppLocalizations.of(context)!.password),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: AppLocalizations.of(context)!.register,
                colour: Colors.deepPurple,
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    validateForm();

                    setState(() {
                      showSpinner = false;
                    });
                  } catch (e) {
                    print(e);
                    setState(() {
                      showSpinner = false;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
