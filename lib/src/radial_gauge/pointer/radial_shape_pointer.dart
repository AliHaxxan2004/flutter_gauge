import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';
import 'package:geekyants_flutter_gauges/src/radial_gauge/pointer/radial_shape_pointer_painter.dart';
import 'package:geekyants_flutter_gauges/src/radial_gauge/radial_gauge_state.dart';

///
/// [RadialShapePointer] is used to render the shape pointer in the [RadialGauge].
///
/// Currently Only Supports Circle Shape Pointers.
///
/// ```dart
///RadialGauge(
///   track: const RadialTrack(start: 0, end: 100),
///   shapePointer: [
///     RadialShapePointer(
///       value: value,
///       color: Colors.pink,
///       height: 20,
///       width: 20,
///     ),
///   ],
/// ),
/// ```
///

class RadialShapePointer extends ImplicitlyAnimatedWidget {
  /// [RadialShapePointer] is used to render the shape pointer in the [RadialGauge].
  ///
  /// Currently Only Supports Circle Shape Pointers.
  /// More Shapes to be added soon!
  const RadialShapePointer({
    super.key,
    required this.value,
    this.color = Colors.red,
    this.height = 10,
    this.width = 10,
    this.onChanged,
    this.isInteractive = false,
    this.shape = PointerShape.triangle,
    this.initialAnimationFrom,
    Duration duration = const Duration(milliseconds: 1000),
    Curve curve = Curves.easeInOut,
  }) : super(duration: duration, curve: curve);

  ///
  /// `value` sets the value of the [RadialShapePointer] on the [RadialGauge]
  ///
  final double value;

  ///
  /// `color` sets the color of the [RadialShapePointer] on the [RadialGauge]
  ///
  final Color color;

  ///
  /// `isInteractive` specifies whether to enable the interaction for the pointers.
  ///
  /// Defaults to false.
  final bool isInteractive;

  ///
  /// `onChanged` is a  callback function that will be invoked when a `pointer`
  /// value is changed.
  ///
  final ValueChanged<double>? onChanged;

  ///
  /// `height` sets the height of the [RadialShapePointer] on the [RadialGauge]
  ///
  /// Defaults to 10.
  ///
  final double height;

  ///
  /// `width` sets the width of the [RadialShapePointer] on the [RadialGauge]
  ///
  /// Defaults to 10.
  ///
  final double width;

  ///
  /// `shape` sets the shape of the [RadialShapePointer] on the [RadialGauge]
  /// Defaults to [PointerShape.circle]
  ///
  /// Currently Only Supports Circle Shape Pointers.
  ///
  final PointerShape shape;

  /// [initialAnimationFrom] specifies the starting value for the initial animation.
  ///
  /// If null, no initial animation occurs.
  /// If set, the pointer will animate from this value to the current value when first rendered.
  final double? initialAnimationFrom;

  @override
  ImplicitlyAnimatedWidgetState<RadialShapePointer> createState() =>
      _RadialShapePointerState();
}

class _RadialShapePointerState
    extends AnimatedWidgetBaseState<RadialShapePointer> {
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

    return _RadialShapePointerRenderWidget(
      value: _valueTween?.evaluate(animation) ?? widget.value,
      color: widget.color,
      height: widget.height,
      width: widget.width,
      isInteractive: widget.isInteractive,
      onChanged: widget.onChanged,
      shape: widget.shape,
      radialGauge: scope.rGauge,
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

class _RadialShapePointerRenderWidget extends LeafRenderObjectWidget {
  const _RadialShapePointerRenderWidget({
    required this.value,
    required this.color,
    required this.height,
    required this.width,
    required this.isInteractive,
    required this.onChanged,
    required this.shape,
    required this.radialGauge,
    required this.isVisible,
  });

  final double value;
  final Color color;
  final double height;
  final double width;
  final bool isInteractive;
  final ValueChanged<double>? onChanged;
  final PointerShape shape;
  final RadialGauge radialGauge;
  final bool isVisible;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderRadialShapePointer(
      value: value,
      color: color,
      height: height,
      width: width,
      isInteractive: isInteractive,
      onChanged: onChanged,
      shape: shape,
      radialGauge: radialGauge,
      isVisible: isVisible,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderRadialShapePointer renderObject) {
    renderObject
      ..setValue = value
      ..setRadialGauge = radialGauge
      ..setColor = color
      ..setHeight = height
      ..setWidth = width
      ..onChanged = onChanged
      ..setIsInteractive = isInteractive
      ..setShape = shape
      ..setIsVisible = isVisible;
  }
}
