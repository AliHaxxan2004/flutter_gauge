import 'package:flutter/material.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';
import 'package:geekyants_flutter_gauges/src/radial_gauge/valuebar/radial_value_bar_painter.dart';
import '../radial_gauge.dart';
import '../radial_gauge_state.dart';

///
/// [RadialValueBar] is used to render the value bar in the [RadialGauge].
///
/// ```dart
///  RadialGauge(
///  valueBar: RadialValueBar(
///   value: 10,
///  color: Colors.blue,
///       ),
///    ),
/// ```
///
class RadialValueBar extends ImplicitlyAnimatedWidget {
  ///
  /// [RadialValueBar] is used to render the value bar in the [RadialGauge].
  ///
  /// ```dart
  ///  RadialGauge(
  ///  valueBar: RadialValueBar(
  ///   value: 10,
  ///  color: Colors.blue,
  ///       ),
  ///    ),
  /// ```
  ///
  const RadialValueBar({
    Key? key,
    required this.value,
    this.color = Colors.blue,
    this.valueBarThickness = 10,
    this.gradient,
    this.radialOffset = 0,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
  }) : super(key: key, duration: duration, curve: curve);

  /// [value] denotes the value of the value bar.
  ///
  ///```dart
  /// RadialGauge(
  ///         valueBar: [
  ///           RadialValueBar(
  ///             value: 50,
  ///           ),
  ///         ],
  ///         track: RadialTrack(
  ///           start: 0,
  ///           end: 100,
  ///         ),
  ///       ),
  /// ```
  ///

  final double value;

  /// [color] denotes the color of the value bar.
  ///
  ///```dart
  /// RadialGauge(
  ///         valueBar: [
  ///           RadialValueBar(
  ///             value: 50,
  ///             color: Colors.blue
  ///           ),
  ///         ],
  ///         track: RadialTrack(
  ///           start: 0,
  ///           end: 100,
  ///         ),
  ///       ),
  /// ```
  ///
  final Color color;

  /// [radialOffset] denotes the offset of the value bar.
  /// The value bar will be rendered at the given offset.
  ///
  /// ```dart
  /// RadialGauge(
  ///         valueBar: [
  ///           RadialValueBar(
  ///             value: 50,
  ///             color: Colors.blue
  ///             radialOffset: 10,
  ///           ),
  ///         ],
  ///         track: RadialTrack(
  ///           start: 0,
  ///           end: 100,
  ///
  ///         ),
  ///       ),
  /// ```
  ///
  final double radialOffset;

  /// [valueBarThickness] denotes the thickness of the value bar.
  /// The value bar will be rendered at the given thickness.
  ///
  /// ```dart
  /// RadialGauge(
  ///         valueBar: [
  ///           RadialValueBar(
  ///             value: 50,
  ///             color: Colors.blue
  ///             valueBarThickness: 20,
  ///           ),
  ///         ],
  ///         track: RadialTrack(
  ///           start: 0,
  ///           end: 100,
  ///
  ///         ),
  ///       ),
  /// ```
  final double valueBarThickness;

  /// [gradient] denotes the gradient of the value bar.
  ///
  final LinearGradient? gradient;

  @override
  ImplicitlyAnimatedWidgetState<RadialValueBar> createState() =>
      _RadialValueBarState();
}

class _RadialValueBarState extends AnimatedWidgetBaseState<RadialValueBar> {
  Tween<double>? _valueTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _valueTween = visitor(
      _valueTween,
      widget.value,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    final RadialGaugeState scope = RadialGaugeState.of(context);

    return _RadialValueBarRenderWidget(
      value: _valueTween?.evaluate(animation) ?? widget.value,
      color: widget.color,
      gradient: widget.gradient ??
          LinearGradient(colors: [widget.color, widget.color]),
      radialOffset: widget.radialOffset,
      valueBarThickness: widget.valueBarThickness,
      radialGauge: scope.rGauge,
    );
  }
}

class _RadialValueBarRenderWidget extends LeafRenderObjectWidget {
  const _RadialValueBarRenderWidget({
    required this.value,
    required this.color,
    required this.gradient,
    required this.radialOffset,
    required this.valueBarThickness,
    required this.radialGauge,
  });

  final double value;
  final Color color;
  final LinearGradient gradient;
  final double radialOffset;
  final double valueBarThickness;
  final RadialGauge radialGauge;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderRadialValueBar(
      value: value,
      color: color,
      gradient: gradient,
      radialOffset: radialOffset,
      valueBarThickness: valueBarThickness,
      radialGauge: radialGauge,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderRadialValueBar renderObject) {
    renderObject
      ..setValue = value
      ..setColor = color
      ..setRadialOffset = radialOffset
      ..setLinearGradient = gradient
      ..setValueBarThickness = valueBarThickness
      ..setRadialGauge = radialGauge;
  }
}
