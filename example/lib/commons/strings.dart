import 'package:flutter/widgets.dart';

/// This Inherited Widget will allow easy reference to all String constants with other benefits.
/// Strings which are used repeatedly in the code should be declared here and used through this Widget.
///
/// Use as: `StringConstants.of(context).contantStringExample`
///
/// Using this for repetitive Strings reduces memory consumption
/// & is performant with complexity O(1).
class StringConstants extends InheritedWidget {
  static StringConstants of(BuildContext context) =>
      // context.inheritFromWidgetOfExactType(StringConstants);
      context.dependOnInheritedWidgetOfExactType();

  const StringConstants({Widget child, Key key})
      : super(key: key, child: child);
  final String contantStringExample = 'An example';

  @override
  bool updateShouldNotify(StringConstants old) => false;
}
