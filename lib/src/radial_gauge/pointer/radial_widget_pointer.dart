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
    this.initialAnimationFrom,
    Duration duration = const Duration(milliseconds: 500),
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

  /// [initialAnimationFrom] specifies the starting value for the initial animation.
  ///
  /// If null, no initial animation occurs.
  /// If set, the pointer will animate from this value to the current value when first rendered.
  final double? initialAnimationFrom;

  @override
  ImplicitlyAnimatedWidgetState<RadialWidgetPointer> createState() =>
      _RadialWidgetPointerState();
}

class _RadialWidgetPointerState
    extends AnimatedWidgetBaseState<RadialWidgetPointer> {
  Tween<double>? _valueTween;
  bool _isFirstBuild = true;

  static const double _fadeWindowFraction = 0.35;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    final beginValue = _isFirstBuild && widget.initialAnimationFrom != null
        ? widget.initialAnimationFrom!
        : widget.value;

    _valueTween = visitor(
      _valueTween,
      widget.value,
      (dynamic value) => Tween<double>(begin: beginValue),
    ) as Tween<double>?;

    _isFirstBuild = false;
  }

  @override
  Widget build(BuildContext context) {
    final RadialGaugeState scope = RadialGaugeState.of(context);
    final radialGauge = scope.rGauge;
    final normalizedValue = _normalizeValueForGauge(
      radialGauge.track.start,
      radialGauge.track.end,
      widget.value,
    );
    final fadeAnimation = _buildFadeAnimation(normalizedValue);

    return _RadialWidgetPointerRenderWidget(
      value: _valueTween?.evaluate(animation) ?? widget.value,
      radialGauge: radialGauge,
      isInteractive: widget.isInteractive,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: widget.child,
      ),
    );
  }

  Animation<double> _buildFadeAnimation(double normalizedValue) {
    final double clampedWindow =
        _fadeWindowFraction.clamp(0.1, 1.0 - 1e-6); // avoid zero width
    final double start =
        (normalizedValue * (1 - clampedWindow)).clamp(0.0, 1.0 - clampedWindow);
    final double end = (start + clampedWindow).clamp(start + 1e-3, 1.0);
    final curve = Interval(start, end, curve: Curves.easeInOut);
    return CurvedAnimation(parent: animation, curve: curve);
  }

  double _normalizeValueForGauge(double start, double end, double value) {
    if (start == end) {
      return 0.0;
    }
    final normalized = (value - start) / (end - start);
    return normalized.clamp(0.0, 1.0);
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
