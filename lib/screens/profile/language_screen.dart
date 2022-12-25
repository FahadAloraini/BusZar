import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../main.dart';
import '../../components/language_constants.dart';
import '../../components/language.dart';

class LanguageButton extends StatefulWidget {
  const LanguageButton({Key? key}) : super(key: key);

  @override
  State<LanguageButton> createState() => _LanguageButtonState();
}

class _LanguageButtonState extends State<LanguageButton> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translation(context).settings),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
          child: DropdownButton<Language>(
        iconSize: 30,
        hint: Text(translation(context).languageCode),
        onChanged: (Language? language) async {
          if (language != null) {
            Locale _locale = await setLocale(language.languageCode);
            BusZar.setLocale(context, _locale);
          }
        },
        items: Language.languageList()
            .map<DropdownMenuItem<Language>>(
              (e) => DropdownMenuItem<Language>(
                value: e,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[Text(e.name)],
                ),
              ),
            )
            .toList(),
      )),
    );
  }
}
