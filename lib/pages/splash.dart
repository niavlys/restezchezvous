import 'dart:async';

import 'package:flutter/material.dart';
import 'package:restezchezvous/getit_setup.dart';
import 'package:restezchezvous/pages/pages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils.dart';

class SplashPage extends StatefulWidget {
  static const String route = '/splash';

  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<SplashPage> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = getIt.get<SharedPreferences>();

    if (alreadyOnBoarded(prefs)) {
      if (allMandatoryPrefsOK(prefs)) {
        Navigator.of(context).pushNamedAndRemoveUntil(PDFGeneratePage.route, (_) => false);
      } else {
        Navigator.of(context).pushReplacementNamed(MyPersonalInfoPage.route);
      }
    } else {
      Navigator.of(context).pushReplacementNamed(BoardingPage.route);
    }
  }

  @override
  void initState() {
    super.initState();
    new Timer(new Duration(milliseconds: 2000), () {
      checkFirstSeen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Text('Made with ❤️ using Flutter...'),
      ),
    );
  }
}
