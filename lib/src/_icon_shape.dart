import 'package:flutter/material.dart';

const double defaultIconRadius = 25;

const double defaultIconScale = 1.5;

enum _ShapeType { circular, square, squircle, teardrop, unknown }

class AppIconShapeData {
  /// An immutable set of radii for each corner of an [IconLayer].
  final BorderRadiusGeometry borderRadius;

  /// A radius where horizontal and vertical axes will have the same radius value.
  /// defaults to 25.
  final double radius;

  /// Icon scale.
  /// defaults to 1.5.
  final double scale;

  final _ShapeType shapeType;

  final Clip clipBehavior;

  /// Usually used with [defaultIconRadius]
  static BorderRadius _circularBorderRadius(double radius) {
    return BorderRadius.circular(radius * 2.0);
  }

  /// Usually used with [defaultIconRadius]
  static BorderRadius _squircleBorderRadius(double radius) {
    return BorderRadius.circular(radius - (radius / 2.5));
  }

  static BorderRadius _squareBorderRadius() {
    return BorderRadius.zero;
  }

  static BorderRadius _teardropBorderRadius(double radius) {
    final Radius _circularRadius = Radius.circular(radius * 2.0);
    final BorderRadius _borderRadius = BorderRadius.only(
      topLeft: _circularRadius,
      topRight: _circularRadius,
      bottomLeft: _circularRadius,
      bottomRight: Radius.circular(radius - (radius / 2.5)),
    );
    return _borderRadius;
  }

  BorderRadius _getEffectiveBorderRadius(double copiedRadius) {
    final radius = copiedRadius ?? defaultIconRadius;
    switch (this.shapeType) {
      case _ShapeType.circular:
        return _circularBorderRadius(radius);
      case _ShapeType.square:
        return _squareBorderRadius();
      case _ShapeType.squircle:
        return _squircleBorderRadius(radius);
      case _ShapeType.teardrop:
        return _teardropBorderRadius(radius);
      case _ShapeType.unknown:
      default:
        return this.borderRadius;
    }
  }

  AppIconShapeData({
    this.borderRadius,
    this.radius,
    this.scale,
  })  : shapeType = _ShapeType.unknown,
        clipBehavior = Clip.hardEdge;

  AppIconShapeData._({
    @required this.borderRadius,
    @required this.radius,
    @required this.scale,
    @required this.shapeType,
  }) : clipBehavior = Clip.hardEdge;

  AppIconShapeData._withClip({
    @required this.borderRadius,
    @required this.radius,
    @required this.scale,
    @required this.shapeType,
    @required this.clipBehavior,
  });

  factory AppIconShapeData.teardrop() {
    final BorderRadius _borderRadius = _teardropBorderRadius(defaultIconRadius);
    const double _radius = defaultIconRadius;
    return AppIconShapeData._(
      borderRadius: _borderRadius,
      radius: _radius,
      scale: defaultIconScale,
      shapeType: _ShapeType.teardrop,
    );
  }
  factory AppIconShapeData.square() {
    final BorderRadius _borderRadius = _squareBorderRadius();
    const double _radius = defaultIconRadius;
    return AppIconShapeData._(
      borderRadius: _borderRadius,
      radius: _radius,
      scale: defaultIconScale,
      shapeType: _ShapeType.square,
    );
  }
  factory AppIconShapeData.squircle() {
    final BorderRadius _borderRadius = _squircleBorderRadius(defaultIconRadius);
    const double _radius = defaultIconRadius;
    return AppIconShapeData._(
      borderRadius: _borderRadius,
      radius: _radius,
      scale: defaultIconScale,
      shapeType: _ShapeType.squircle,
    );
  }
  factory AppIconShapeData.circular() {
    final BorderRadius _borderRadius = _circularBorderRadius(defaultIconRadius);
    const double _radius = defaultIconRadius;
    return AppIconShapeData._(
      borderRadius: _borderRadius,
      radius: _radius,
      scale: defaultIconScale,
      shapeType: _ShapeType.circular,
    );
  }

  factory AppIconShapeData.fallback() {
    return AppIconShapeData.circular();
  }

  /// Creates a copy of this [AppIconShapeData] but with the given fields replaced based upon new values.
  ///
  /// Cannot maintain shape if [borderRadius] is provided.
  /// Either remove [borderRadius] or set [maintainShape] to false.
  AppIconShapeData copyWith({
    BorderRadiusGeometry borderRadius,
    Clip clipBehavior,
    bool maintainShape = true,
    double radius,
    double scale,
  }) {
    borderRadius =
        maintainShape ? _getEffectiveBorderRadius(radius) : borderRadius;
    return AppIconShapeData._withClip(
      borderRadius: borderRadius,
      radius: radius ?? this.radius,
      scale: scale ?? this.scale,
      shapeType: maintainShape ? this.shapeType : _ShapeType.unknown,
      clipBehavior: clipBehavior ?? this.clipBehavior ?? Clip.hardEdge,
    );
  }
}

class AppIconShape extends StatelessWidget {
  /// Applies the given icon shape [data] to [child].
  ///
  /// The [data] and [child] arguments must not be null.
  const AppIconShape({
    Key key,
    @required this.data,
    this.isMaterialAppTheme = false,
    @required this.child,
  })  : assert(child != null),
        assert(data != null),
        super(key: key);

  final AppIconShapeData data;

  final bool isMaterialAppTheme;

  final Widget child;

  static final AppIconShapeData _kFallbackTheme = AppIconShapeData.fallback();

  static AppIconShapeData of(BuildContext context,
      {bool shadowThemeOnly = false}) {
    final _InheritedIconShape inheritedStyle =
        context.dependOnInheritedWidgetOfExactType<_InheritedIconShape>();
    if (shadowThemeOnly) {
      if (inheritedStyle == null || inheritedStyle.style.isMaterialAppTheme)
        return null;
      return inheritedStyle.style.data;
    }

    final AppIconShapeData style =
        inheritedStyle?.style?.data ?? _kFallbackTheme;
    return style;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedIconShape(
      style: this,
      child: child,
    );
  }
}

class _InheritedIconShape extends InheritedTheme {
  const _InheritedIconShape({
    Key key,
    @required this.style,
    @required Widget child,
  })  : assert(style != null),
        super(key: key, child: child);

  final AppIconShape style;

  @override
  Widget wrap(BuildContext context, Widget child) {
    final _InheritedIconShape ancestorTheme =
        context.findAncestorWidgetOfExactType<_InheritedIconShape>();
    return identical(this, ancestorTheme)
        ? child
        : AppIconShape(data: style.data, child: child);
  }

  @override
  bool updateShouldNotify(_InheritedIconShape old) =>
      style.data != old.style.data;
}
