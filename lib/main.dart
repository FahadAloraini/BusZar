import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:testing_phase1/screens/profile_screen.dart';
import 'package:testing_phase1/screens/search_screen.dart';
import 'package:testing_phase1/screens/settings_screen.dart';
import 'package:testing_phase1/screens/user_ticket_screen.dart';

import 'package:testing_phase1/screens/welcome_screen.dart';
import 'package:testing_phase1/screens/login_screen.dart';
import 'package:testing_phase1/screens/registration_screen.dart';
import 'package:testing_phase1/screens/home_screen.dart';
import 'package:testing_phase1/screens/history_screen.dart';

// github token = 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
// google api key = AIzaSyBrmrhO6Okkfo1noD68vaFC3TEUuu-UeY0
//void main() => runApp(FlashChat());
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        SearchScreen.id: (context) => SearchScreen(),
        ProfileScreen.id: (context) => ProfileScreen(),
        UserTicket.id: (context) => UserTicket(),
        HistoryScreen.id: (context) => HistoryScreen(),
        SettingsScreen.id: (context) => SettingsScreen(),
      },
    );
  }
}
