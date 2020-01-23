import 'package:flutter/material.dart';
import 'package:red/main.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (context) => Root());
    case '/home':
      return MaterialPageRoute(builder: (context) => ShowCase());
    default:
      return MaterialPageRoute(builder: (context) => ShowCase());
  }
}
