import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../components/language.dart';
import '../../home_screen.dart';
import 'settings_body.dart';
import '../../../components/language_constants.dart';
import 'package:testing_phase1/main.dart';
import '../../../components/global.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SettingsItem(
          title: AppLocalizations.of(context)!.language,
          icon: const Icon(Icons.language),
          isSwitchButton: false,
          islanguage: true,
        ),
        SettingsItem(
          title: AppLocalizations.of(context)!.darkMode,
          icon: const Icon(Icons.dark_mode),
          isSwitchButton: true,
          islanguage: true,
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
  void toggleSwitch(bool value) {
    setState(() {
      isSwitched = value;
      DarkMode = value;
      Navigator.pushNamed(context, HomeScreen.id);
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
                  : Center(
                      child: DropdownButton<Language>(
                      iconSize: 30,
                      hint: Text(translation(context).languageCode),
                      onChanged: (Language? language) async {
                        if (language != null) {
                          Locale _locale =
                              await setLocale(language.languageCode);
                          BusZar.setLocale(context, _locale);
                        }
                      },
                      items: Language.languageList()
                          .map<DropdownMenuItem<Language>>(
                            (e) => DropdownMenuItem<Language>(
                              value: e,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[Text(e.name)],
                              ),
                            ),
                          )
                          .toList(),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
