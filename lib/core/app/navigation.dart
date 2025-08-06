import 'package:flutter/material.dart';

class NavigationService{

  static Future<void> navigate(BuildContext context, Widget screen) async{
    Navigator.push(context, _materialPageRoute(context, screen));
  }

  static Future<void> navigateTo(BuildContext context, Widget screen) async{
    Navigator.pushReplacement(context, _materialPageRoute(context, screen));
  }

  static void back(BuildContext context) {
    Navigator.pop(context);
  }

  static MaterialPageRoute _materialPageRoute(BuildContext context, Widget screen) {
    return MaterialPageRoute(builder: (context) => screen,);
  }

}