import 'package:flutter/material.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';
import 'package:geekyants_flutter_gauges/src/radial_gauge/pointer/radial_widget_painter.dart';
import '../radial_gauge_state.dart';

///
/// A [RadialWidgetPointer] is used to render the widget pointer in the [RadialGauge].
///
/// ```dart
///RadialGauge(
///          widgetPointer: [
///            RadialWidgetPointer(value: 100, child: FlutterLogo())
///           ],
///           track: RadialTrack(
///             trackStyle: TrackStyle(),
///             start: 0,
///             end: 100,
///           ),
///         ),
/// ```
///

class RadialWidgetPointer extends ImplicitlyAnimatedWidget {
  const RadialWidgetPointer({
    Key? key,
    required this.value,
    required this.child,
    this.isInteractive = false,
    this.onChanged,
    this.onTap,
    Duration duration = const Duration(milliseconds: 1000),
    Curve curve = Curves.easeInOut,
  }) : super(key: key, duration: duration, curve: curve);

  ///
  /// `value` Sets the value of the pointer on the [RadialGauge]
  ///
  final double value;

  ///
  /// `child` is the widget to be displayed at the pointer position
  ///
  final Widget child;

  final VoidCallback? onTap; // Add this

  ///
  /// Specifies whether to enable the interaction for the pointers.
  ///
  final bool isInteractive;

  ///
  /// onChanged is a  callback function that will be invoked when a `pointer`
  /// value is changed.
  ///
  final ValueChanged<double>? onChanged;

  @override
  ImplicitlyAnimatedWidgetState<RadialWidgetPointer> createState() =>
      _RadialWidgetPointerState();
}

class _RadialWidgetPointerState
    extends AnimatedWidgetBaseState<RadialWidgetPointer> {
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

    return _RadialWidgetPointerRenderWidget(
      value: _valueTween?.evaluate(animation) ?? widget.value,
      radialGauge: scope.rGauge,
      isInteractive: widget.isInteractive,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      child: widget.child,
    );
  }
}

class _RadialWidgetPointerRenderWidget extends SingleChildRenderObjectWidget {
  const _RadialWidgetPointerRenderWidget({
    required this.value,
    required this.radialGauge,
    required this.isInteractive,
    required this.onChanged,
    required this.onTap,
    required Widget child,
  }) : super(child: child);

  final double value;
  final RadialGauge radialGauge;
  final bool isInteractive;
  final ValueChanged<double>? onChanged;
  final VoidCallback? onTap;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderRadialWidgetPointer(
      value: value,
      radialGauge: radialGauge,
      isInteractive: isInteractive,
      onChanged: onChanged,
      onTap: onTap,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderRadialWidgetPointer renderObject) {
    renderObject
      ..setValue = value
      ..setRadialGauge = radialGauge
      ..setIsInteractive = isInteractive
      ..onChanged = onChanged
      ..onTap = onTap;
  }
}
