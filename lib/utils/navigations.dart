import 'package:flutter/material.dart';

class Navigations {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<dynamic>? push( Widget page , BuildContext context) {
 

return  Navigator.push(context, MaterialPageRoute(builder: (context)=> page));

  }

  static void pop(BuildContext context) {
    return Navigator.pop(context);
  }

  static Future<dynamic>? pushReplacement(Widget page, BuildContext context) {
    return navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static Future<dynamic>? pushAndRemoveUntil(Widget page, BuildContext context) {
    return 
    Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => page),
  (Route<dynamic> route) => false, // Removes all previous routes
);
  
  }
}



