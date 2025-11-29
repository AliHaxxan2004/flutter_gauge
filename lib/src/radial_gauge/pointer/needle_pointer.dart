import 'dart:async';

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
    this.initialAnimationFrom,
    Duration duration = const Duration(milliseconds: 1000),
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

  /// [initialAnimationFrom] specifies the starting value for the initial animation.
  ///
  /// If null, no initial animation occurs.
  /// If set, the needle will animate from this value to the current value when first rendered.
  final double? initialAnimationFrom;

  @override
  ImplicitlyAnimatedWidgetState<NeedlePointer> createState() =>
      _NeedlePointerState();
}

class _NeedlePointerState extends AnimatedWidgetBaseState<NeedlePointer> {
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
      isVisible: _isPointerVisible,
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
    required this.isVisible,
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
  final bool isVisible;

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
      isVisible: isVisible,
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
      ..setRadialGauge = radialGauge
      ..setIsVisible = isVisible;
  }
}
