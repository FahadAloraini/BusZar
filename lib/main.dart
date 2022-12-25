import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:testing_phase1/components/app_info.dart';
import 'package:testing_phase1/screens/check_out_screen.dart';
import 'package:testing_phase1/screens/profile/settings_screen.dart';
import 'package:testing_phase1/screens/profile_screen.dart';
import 'package:testing_phase1/screens/rate_driver_screen.dart';
import 'package:testing_phase1/screens/search_screen.dart';
//import 'package:testing_phase1/screens/settings_screen.dart';
import 'package:testing_phase1/screens/trips_history_screen.dart';
import 'package:testing_phase1/screens/trips_screen.dart';
import 'package:testing_phase1/screens/user_ticket_screen.dart';
import 'package:testing_phase1/screens/wallet_screen.dart';
import 'components/language_constants.dart';
import 'screens/search_places_screen.dart';
import 'package:testing_phase1/screens/welcome_screen.dart';
import 'package:testing_phase1/screens/login_screen.dart';
import 'package:testing_phase1/screens/registration_screen.dart';
import 'package:testing_phase1/screens/home_screen.dart';
import 'package:testing_phase1/screens/history_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'components/global.dart';
import 'screens/profile/components/settings_body.dart';

// github token = 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
// google api key = AIzaSyBrmrhO6Okkfo1noD68vaFC3TEUuu-UeY0
//void main() => runApp(FlashChat());
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(BusZar());
}

class BusZar extends StatefulWidget {
  const BusZar({Key? key}) : super(key: key);

  @override
  State<BusZar> createState() => _BusZarState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _BusZarState? state = context.findAncestorStateOfType<_BusZarState>();
    state?.setLocale(newLocale);
  }
}

class _BusZarState extends State<BusZar> {
  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) => {setLocale(locale)});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate, // Add this line
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en', ''), // English, no country code
          Locale('ar', ''), // Spanish, no country code
        ],
        locale: _locale,
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
          SearchPlacesScreen.id: (context) => SearchPlacesScreen(),
          TripsHistoryScreen.id: (context) => TripsHistoryScreen(),
          RateDriverScreen.id: (context) => RateDriverScreen(),
          CheckOutScreen.id: (context) => CheckOutScreen(),
          TripsScreen.id: (context) => TripsScreen(),
          WalletScreen.id: (context) => WalletScreen(),
        },
      ),
    );
  }
}
