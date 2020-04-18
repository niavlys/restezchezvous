
import 'package:flutter/material.dart';
import 'package:restezchezvous/getit_setup.dart';
import 'package:restezchezvous/routes/router.dart';
import 'pages/pages.dart';




void main() { 
  setupGetIt();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      color: Colors.blue,
      onGenerateRoute: Router.generateRoute,
      initialRoute: SplashPage.route,
    );
  }
}


