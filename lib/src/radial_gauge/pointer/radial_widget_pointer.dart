import 'dart:async';

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
  bool _hasScheduledInitialDelay = false;
  bool _isPointerVisible = true;
  Timer? _visibilityTimer;

  @override
  void initState() {
    super.initState();
    _isPointerVisible = widget.initialAnimationFrom == null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleInitialDelayIfNeeded();
  }

  @override
  void dispose() {
    _visibilityTimer?.cancel();
    super.dispose();
  }

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

    return _RadialWidgetPointerRenderWidget(
      value: _valueTween?.evaluate(animation) ?? widget.value,
      radialGauge: scope.rGauge,
      isInteractive: widget.isInteractive,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      isVisible: _isPointerVisible,
      child: widget.child,
    );
  }

  void _scheduleInitialDelayIfNeeded() {
    if (_hasScheduledInitialDelay) {
      return;
    }

    _hasScheduledInitialDelay = true;

    if (widget.initialAnimationFrom == null) {
      _isPointerVisible = true;
      return;
    }

    final RadialGaugeState scope = RadialGaugeState.of(context);
    final Duration delay = _computeVisibilityDelay(scope.rGauge, scope.track);

    if (delay <= Duration.zero) {
      _isPointerVisible = true;
      return;
    }

    _isPointerVisible = false;
    controller.stop();
    controller.value = 0;

    _visibilityTimer = Timer(delay, () {
      if (!mounted) {
        return;
      }
      _visibilityTimer = null;
      setState(() {
        _isPointerVisible = true;
      });
      controller.forward();
    });
  }

  Duration _computeVisibilityDelay(RadialGauge gauge, RadialTrack track) {
    final double range = track.end - track.start;
    if (range == 0) {
      return Duration.zero;
    }

    final double normalized =
        ((widget.value - track.start) / range).clamp(0.0, 1.0);
    final Duration referenceDuration = _resolveReferenceDuration(gauge);
    final int delayMs =
        (referenceDuration.inMilliseconds * normalized).round();

    return Duration(milliseconds: delayMs);
  }

  Duration _resolveReferenceDuration(RadialGauge gauge) {
    final List<RadialValueBar>? valueBars = gauge.valueBar;
    if (valueBars == null || valueBars.isEmpty) {
      return widget.duration;
    }

    Duration longest = valueBars.first.duration;
    for (int i = 1; i < valueBars.length; i++) {
      if (valueBars[i].duration > longest) {
        longest = valueBars[i].duration;
      }
    }
    return longest;
  }
}

class _RadialWidgetPointerRenderWidget extends SingleChildRenderObjectWidget {
  const _RadialWidgetPointerRenderWidget({
    required this.value,
    required this.radialGauge,
    required this.isInteractive,
    required this.onChanged,
    required this.onTap,
    required this.isVisible,
    required Widget child,
  }) : super(child: child);

  final double value;
  final RadialGauge radialGauge;
  final bool isInteractive;
  final ValueChanged<double>? onChanged;
  final VoidCallback? onTap;
  final bool isVisible;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderRadialWidgetPointer(
      value: value,
      radialGauge: radialGauge,
      isInteractive: isInteractive,
      onChanged: onChanged,
      onTap: onTap,
      isVisible: isVisible,
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
      ..onTap = onTap
      ..isVisible = isVisible;
  }
}
