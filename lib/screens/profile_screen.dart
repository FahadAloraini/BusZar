import 'package:flutter/material.dart';
import 'package:testing_phase1/components/rounded_button.dart';
import 'package:testing_phase1/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testing_phase1/screens/history_screen.dart';
import 'package:testing_phase1/screens/home_screen.dart';
import 'package:testing_phase1/screens/trips_history_screen.dart';
import 'package:testing_phase1/screens/wallet_screen.dart';
import 'package:testing_phase1/screens/welcome_screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../components/assistant_methods.dart';
import '../components/global.dart';

class ProfileScreen extends StatefulWidget {
  static const String id = 'profile_screen';
  @override
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  void initState() {
    super.initState();
    AssistantMethods.readCurrentOnlineUserInfo();
    print(fAuth.currentUser?.email!.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          minimum: EdgeInsets.only(top: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const CircleAvatar(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minRadius: 50,
                maxRadius: 70,
                child: Icon(
                  Icons.person,
                  size: 100,
                ),
                //backgroundImageIcon(Icons.person):,
              ),
              const SizedBox(
                height: 20,
                width: double.infinity,
                child: Divider(
                  color: Colors.black,
                ),
              ),
              Text(
                userModelCurrentInfo!.name ?? "",
                style: const TextStyle(
                  fontSize: 40.0,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Pacifico",
                ),
              ),

              const SizedBox(
                height: 20,
                width: double.infinity,
                child: Divider(
                  color: Colors.black,
                ),
              ),
              Card(
                color: Colors.white,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                child: ListTile(
                  leading: const Icon(
                    Icons.email,
                    color: Colors.deepPurple,
                  ),
                  title: Text(
                    userModelCurrentInfo!.email ?? "",
                    style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 20,
                        fontFamily: "Source Sans Pro"),
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                child: ListTile(
                  leading: const Icon(
                    Icons.phone,
                    color: Colors.deepPurple,
                  ),
                  title: Text(
                    userModelCurrentInfo!.phone ?? "",
                    style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 20,
                        fontFamily: "Source Sans Pro"),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RoundedButton(
                      title: AppLocalizations.of(context)!.wallet,
                      colour: Colors.deepPurpleAccent,
                      onPressed: () {
                        Navigator.pushNamed(context, WalletScreen.id);
                      },
                    ),
                    RoundedButton(
                      title: AppLocalizations.of(context)!.history,
                      colour: Colors.deepPurpleAccent,
                      onPressed: () {
                        Navigator.pushNamed(context, TripsHistoryScreen.id);
                      },
                    ),
                    RoundedButton(
                      title: AppLocalizations.of(context)!.signOut,
                      colour: Colors.red,
                      onPressed: () {
                        fAuth.signOut();
                        Navigator.pushNamed(context, WelcomeScreen.id);
                      },
                    ),
                  ],
                ),
              )

              // we will be creating a new widget name info carrd
            ],
          ),
        ));
  }
}
