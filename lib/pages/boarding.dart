import 'package:fancy_on_boarding/fancy_on_boarding.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages.dart';

class BoardingPage extends StatefulWidget {
  static const String route = '/onBoard';


  BoardingPage({Key key}) : super(key: key);

  @override
  _BoardingPageState createState() => new _BoardingPageState();
}

class _BoardingPageState extends State<BoardingPage> {
  Future<void> onBoardingDone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('seen', true);
    Navigator.of(context).pushReplacementNamed(MyPersonalInfoPage.route);
  }

  //Create a list of PageModel to be set on the onBoarding Screens.
  final pageList = [
    PageModel(
        color: const Color(0xFF0961ED),
        heroAssetPath: 'assets/png/stores.png',
        title: Text('Restez chez vous',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: 34.0,
            )),
        body: Text(
            'A moins d\'avoir une bonne raison de sortir, il faut rester chez soi!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            )),
        iconAssetPath: 'assets/png/shopping_cart.png'),
    PageModel(
        color: const Color(0xFFC5C5C5),
        heroAssetPath: 'assets/png/banks.png',
        title: Text('Autorisation',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: 34.0,
            )),
        body: Text(
            'Cette app permet de générer automatiquement l\'autorisation de déplacement',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            )),
        iconAssetPath: 'assets/png/wallet.png'),
    PageModel(
      color: const Color(0xFFDE0D1B),
      heroAssetPath: 'assets/png/hotels.png',
      title: Text('Disclaimer',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 34.0,
          )),
      body: Text('Vous êtes seuls responsables de l\'utilisation de cette app',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          )),
      iconAssetPath: 'assets/png/key.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Pass pageList and the mainPage route.
      body: FancyOnBoarding(
        doneButtonText: "Compris",
        showSkipButton: false,
        pageList: pageList,
        onDoneButtonPressed: onBoardingDone,
      ),
    );
  }
}
