// ignore: file_names
import 'package:cutomer_app/Screens/ngk_terms_conditions_screen.dart';
import 'package:cutomer_app/SigninSignUp/LoginScreen.dart';
import 'package:cutomer_app/Screens/splashScreen.dart';

import 'package:cutomer_app/Terms/TermsAndConditionsScreen.dart';

import 'package:flutter/material.dart';

var onGenerateRoute = (RouteSettings settings) {
  print('my routs: ${settings.name}');
  switch (settings.name) {
    case "/":
      return MaterialPageRoute(builder: (builder) => const SplashScreen());

    case "/login":
      return MaterialPageRoute(builder: (builder) => Loginscreen());

    case "/termsandcondition":
      return MaterialPageRoute(
          builder: (builder) => TermsAndConditionsScreen());

    case "/ngktermsconditions":
      return MaterialPageRoute(
          builder: (builder) => NgkTermsConditionsScreen());
    default:
  }
};
