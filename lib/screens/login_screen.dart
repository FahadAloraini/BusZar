import 'package:flutter/material.dart';
import 'package:testing_phase1/components/rounded_button.dart';
import 'package:testing_phase1/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testing_phase1/screens/home_screen.dart';
import 'package:testing_phase1/screens/welcome_screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../components/global.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailtexteditingcontroller = TextEditingController();
  TextEditingController passwordtexteditingcontroller = TextEditingController();

  validateForm() {
    if (!emailtexteditingcontroller.text.contains("@")) {
      Fluttertoast.showToast(msg: "Email address is not Valid.");
    } else if (passwordtexteditingcontroller.text.isEmpty) {
      Fluttertoast.showToast(msg: "Password is required.");
    } else {
      loginNow();
    }
  }

  loginNow() async {
    final User? firebaseUser = (await fAuth
            .signInWithEmailAndPassword(
      email: emailtexteditingcontroller.text.trim(),
      password: passwordtexteditingcontroller.text.trim(),
    )
            .catchError((msg) {
      Fluttertoast.showToast(msg: "Error: " + msg.toString());
    }))
        .user;

    if (firebaseUser != null) {
      DatabaseReference usersRef =
          FirebaseDatabase.instance.ref().child("user");
      usersRef.child(firebaseUser.uid).once().then((userKey) {
        final snap = userKey.snapshot;
        if (snap.value != null) {
          currentFirebaseUser = firebaseUser;
          Fluttertoast.showToast(msg: "Login Successful.");
          Navigator.pushNamed(context, HomeScreen.id);
        } else {
          Fluttertoast.showToast(msg: "No record exist with this email.");
          fAuth.signOut();
        }
      });
    } else {
      Fluttertoast.showToast(msg: "Error Occurred during Login.");
    }
  }

  bool showSpinner = false;

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
                    WavyAnimatedText(AppLocalizations.of(context)!.login,
                        textAlign: TextAlign.center),
                  ],
                  totalRepeatCount: 1,
                  // repeatForever: true,
                ),
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
                title: AppLocalizations.of(context)!.login,
                colour: Colors.deepPurpleAccent,
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
