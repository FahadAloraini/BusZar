import 'package:flutter/material.dart';
import 'components/settings_body.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  static const String id = 'settings_screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.settings),
          backgroundColor: Colors.deepPurple,
        ),
        body: Body());
  }
}
