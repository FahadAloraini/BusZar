import 'package:flutter/material.dart';
import 'package:testing_phase1/main.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SettingsItem(
          title: 'Language',
          icon: const Icon(Icons.language),
          isSwitchButton: false,
          islanguage: true,
        ),
        SettingsItem(
          title: 'Dark Mode',
          icon: const Icon(Icons.dark_mode),
          isSwitchButton: true,
          islanguage: false,
        ),
        SettingsItem(
          title: 'Notifications',
          icon: const Icon(Icons.notifications),
          isSwitchButton: true,
          islanguage: false,
        ),
      ],
    );
  }
}

class SettingsItem extends StatefulWidget {
  SettingsItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.isSwitchButton,
    required this.islanguage,
  }) : super(key: key);

  final String title;
  final Icon icon;
  final bool isSwitchButton;
  final bool islanguage;

  @override
  State<SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem> {
  bool isSwitched = true;

  void toggleSwitch(bool value) {
    setState(() {
      isSwitched = value;
      print("value: $value");
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              widget.icon,
              const SizedBox(width: 20),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // ignore: prefer_const_constructors
              Spacer(),
              Container(margin: EdgeInsets.symmetric(horizontal: 3)),
              widget.isSwitchButton
                  ? Switch(
                      value: isSwitched,
                      activeColor: Colors.deepPurple,
                      onChanged: toggleSwitch,
                    )
                  : Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }
}
