/*
 * Created by sylvain Alborini 
 */

import 'package:flutter/material.dart';
import 'package:restezchezvous/pages/pages.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashPage.route:
        return MaterialPageRoute(builder: (_) => SplashPage());

      case BoardingPage.route:
        return MaterialPageRoute(builder: (_) => BoardingPage());
      
      case MyPersonalInfoPage.route:
        return MaterialPageRoute(builder: (_) => MyPersonalInfoPage());
      
      case PDFGeneratePage.route:
        return MaterialPageRoute(builder: (_) => PDFGeneratePage());

      default:
        return MaterialPageRoute(
            builder: (_) => UndefinedView(
                  routeName: settings.name,
                ));
    }
  }
}
