import 'package:flutter/material.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';
import 'package:geekyants_flutter_gauges/src/radial_gauge/radial_gauge_state.dart';
import 'needle_pointer_painter.dart';

///
/// Creates a needle pointer for [RadialGauge].
///
///```dart
///  RadialGauge(
///   needlePointer: [
///     NeedlePointer(value: 30),
///   ],
///   track: RadialTrack(
///     start: 0,
///     end: 100,
///   ),
///  ),
/// ```
class NeedlePointer extends ImplicitlyAnimatedWidget {
  /// Creates a needle pointer for [RadialGauge].
  ///
  ///```dart
  ///  RadialGauge(
  ///   needlePointer: [
  ///     NeedlePointer(value: 30),
  ///   ],
  ///   track: RadialTrack(
  ///     start: 0,
  ///     end: 100,
  ///   ),
  ///  ),
  /// ```
  const NeedlePointer({
    Key? key,
    required this.value,
    this.gradient,
    this.color = Colors.red,
    this.tailColor = Colors.red,
    this.needleWidth = 40,
    this.needleHeight = 300,
    this.onChanged,
    this.isInteractive = false,
    this.needleStyle = NeedleStyle.gaugeNeedle,
    this.tailRadius = 80,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
  }) : super(key: key, duration: duration, curve: curve);

  final double value;
  final bool isInteractive;
  final Color color;
  final double needleHeight;
  final double needleWidth;
  final double tailRadius;
  final LinearGradient? gradient;
  final Color tailColor;
  final NeedleStyle needleStyle;
  final ValueChanged<double>? onChanged;

  @override
  ImplicitlyAnimatedWidgetState<NeedlePointer> createState() =>
      _NeedlePointerState();
}

class _NeedlePointerState extends AnimatedWidgetBaseState<NeedlePointer> {
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

    return _NeedlePointerRenderWidget(
      value: _valueTween?.evaluate(animation) ?? widget.value,
      gradient: widget.gradient ??
          LinearGradient(colors: [widget.color, widget.color]),
      radialGauge: scope.rGauge,
      tailColor: widget.tailColor,
      needleStyle: widget.needleStyle,
      isInteractive: widget.isInteractive,
      color: widget.color,
      needleHeight: widget.needleHeight,
      onChanged: widget.onChanged,
      needleWidth: widget.needleWidth,
      tailRadius: widget.tailRadius,
    );
  }
}

class _NeedlePointerRenderWidget extends LeafRenderObjectWidget {
  const _NeedlePointerRenderWidget({
    required this.value,
    required this.gradient,
    required this.radialGauge,
    required this.tailColor,
    required this.needleStyle,
    required this.isInteractive,
    required this.color,
    required this.needleHeight,
    required this.onChanged,
    required this.needleWidth,
    required this.tailRadius,
  });

  final double value;
  final LinearGradient gradient;
  final RadialGauge radialGauge;
  final Color tailColor;
  final NeedleStyle needleStyle;
  final bool isInteractive;
  final Color color;
  final double needleHeight;
  final ValueChanged<double>? onChanged;
  final double needleWidth;
  final double tailRadius;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderNeedlePointer(
      gradient: gradient,
      radialGauge: radialGauge,
      value: value,
      tailColor: tailColor,
      needleStyle: needleStyle,
      isInteractive: isInteractive,
      color: color,
      needleHeight: needleHeight,
      onChanged: onChanged,
      needleWidth: needleWidth,
      tailRadius: tailRadius,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderNeedlePointer renderObject) {
    renderObject
      ..setValue = value
      ..setColor = color
      ..setIsInteractive = isInteractive
      ..setTailColor = tailColor
      ..setGradient = gradient
      ..setNeedleHeight = needleHeight
      ..setTailRadius = tailRadius
      ..onChanged = onChanged
      ..setNeedleStyle = needleStyle
      ..setNeedleWidth = needleWidth
      ..setRadialGauge = radialGauge;
  }
}
