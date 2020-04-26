import 'package:flutter/material.dart';
import 'package:red/main.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
    default:
      return MaterialPageRoute(builder: (context) => ShowCase());
  }
}
