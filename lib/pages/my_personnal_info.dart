import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:restezchezvous/getit_setup.dart';
import 'package:restezchezvous/pages/pages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_validator/string_validator.dart';

import '../utils.dart';

class MyPersonalInfoPage extends StatefulWidget {
  static const String route = '/personnalInfo';

  @override
  _MyPersonalInfoState createState() => new _MyPersonalInfoState();
}

class _MyPersonalInfoState extends State<MyPersonalInfoPage> {
  SharedPreferences prefs = getIt.get<SharedPreferences>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Informations'),
        ),
        body: PreferencePage(
          [
            PreferenceTitle('Informations nominatives'),
            TextFieldPreference('Prénom', 'firstName', validator: (str) {
              if (!isAlpha(str)) {
                return "Nom invalide";
              }
              return null;
            }),
            TextFieldPreference('Nom', 'lastName', validator: (str) {
              if (!isAlpha(str)) {
                return "Prénom invalide";
              }
              return null;
            }),
            TextFieldPreference('Date de Naissance', 'birthDate',
                validator: (str) {
              if (!matches(str,
                  r'^([0-2][0-9]|(3)[0-1])(\/)(((0)[0-9])|((1)[0-2]))(\/)\d{4}$')) {
                return "Format : dd/mm/aaaa";
              }
              return null;
            }),
            TextFieldPreference('Lieu de naissance', 'birthPlace',
                validator: (str) {
              if (!isAlpha(str)) {
                return "Lieu invalide";
              }
              return null;
            }),
            TextFieldPreference(
              'Adresse',
              'address',
            ),
            TextFieldPreference('Ville', 'city', validator: (str) {
              if (!isAlpha(str)) {
                return "Ville invalide";
              }
              return null;
            }),
            TextFieldPreference(
              'Code postal',
              'postalCode',
              keyboardType: new TextInputType.numberWithOptions(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => allMandatoryPrefsOK(prefs)
              ? Navigator.of(context)
                  .pushNamedAndRemoveUntil(PDFGeneratePage.route, (_) => false)
              : null,
          tooltip: 'Increment Counter',
          child: const Icon(Icons.done),
        ));
  }
}
