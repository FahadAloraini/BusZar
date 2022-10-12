import 'package:flutter/material.dart';
import 'package:testing_phase1/components/settings_body.dart';

class SettingsScreen extends StatelessWidget {
  static const String id = 'settings_screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Body());
  }
}
