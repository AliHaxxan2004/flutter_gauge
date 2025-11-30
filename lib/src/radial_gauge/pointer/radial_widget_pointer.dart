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
  bool _isInitialAnimation = false;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    if (_isFirstBuild && widget.initialAnimationFrom != null) {
      _isInitialAnimation = true;
    }

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

    // Check if animation finished to reset _isInitialAnimation
    if (_isInitialAnimation && animation.status == AnimationStatus.completed) {
      _isInitialAnimation = false;
    }

    double currentValue = _valueTween?.evaluate(animation) ?? widget.value;
    double opacity = 1.0;

    if (_isInitialAnimation) {
      // During initial animation, we want the pointer to be stationary at the target value
      // and fade in as the "progress" (animation value) passes it.
      currentValue = widget.value;

      final double trackStart = scope.rGauge.track.start;
      final double trackEnd = scope.rGauge.track.end;
      final double range = trackEnd - trackStart;

      if (range != 0) {
        final double relativePosition = (widget.value - trackStart) / range;
        final double currentProgress = animation.value;

        // Calculate opacity
        // We want it to start fading in slightly before or exactly when progress reaches it.
        // Let's say we want a quick fade in.
        const double fadeWindow = 0.1; // 10% of the duration to fade in

        if (currentProgress < relativePosition) {
          opacity = 0.0;
        } else {
          double fadeProgress =
              (currentProgress - relativePosition) / fadeWindow;
          opacity = fadeProgress.clamp(0.0, 1.0);
        }
      }
    }

    return _RadialWidgetPointerRenderWidget(
      value: currentValue,
      radialGauge: scope.rGauge,
      isInteractive: widget.isInteractive,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      child: Opacity(
        opacity: opacity,
        child: widget.child,
      ),
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
