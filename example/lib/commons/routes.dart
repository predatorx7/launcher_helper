import 'package:flutter/material.dart';
import '../main.dart';
import 'routing_constants.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case ShowcaseRoute:
    default:
      return MaterialPageRoute(builder: (context) => Showcase());
  }
}
