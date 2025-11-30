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
  late final AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _fadeDelayTimer;
  double? _lastNormalizedValue;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: _fadeDurationFrom(widget.duration),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateFadeSequence(forceRestart: true);
  }

  @override
  void didUpdateWidget(RadialWidgetPointer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _fadeController.duration = _fadeDurationFrom(widget.duration);
    }
    if (widget.value != oldWidget.value) {
      _updateFadeSequence(forceRestart: true);
    } else {
      _updateFadeSequence(forceRestart: false);
    }
  }

  @override
  void dispose() {
    _fadeDelayTimer?.cancel();
    _fadeController.dispose();
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
    final radialGauge = scope.rGauge;

    return _RadialWidgetPointerRenderWidget(
      value: _valueTween?.evaluate(animation) ?? widget.value,
      radialGauge: radialGauge,
      isInteractive: widget.isInteractive,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }

  double _normalizeValueForGauge(double start, double end, double value) {
    if (start == end) {
      return 0.0;
    }
    final normalized = (value - start) / (end - start);
    return normalized.clamp(0.0, 1.0);
  }

  void _updateFadeSequence({required bool forceRestart}) {
    final radialGauge = RadialGaugeState.of(context).rGauge;
    final normalizedValue = _normalizeValueForGauge(
      radialGauge.track.start,
      radialGauge.track.end,
      widget.value,
    );

    final bool sameValue = _lastNormalizedValue != null &&
        (_lastNormalizedValue! - normalizedValue).abs() < 0.0001;
    if (!forceRestart && sameValue) {
      return;
    }
    _lastNormalizedValue = normalizedValue;
    _startFadeWithDelay(normalizedValue);
  }

  void _startFadeWithDelay(double normalizedValue) {
    _fadeDelayTimer?.cancel();
    _fadeController.value = 0.0;

    final int totalMs = widget.duration.inMilliseconds;
    if (totalMs <= 0) {
      _fadeController.forward(from: 0.0);
      return;
    }

    final double clampedWindow =
        _fadeWindowFraction.clamp(0.1, 1.0 - 1e-6); // avoid zero width
    final double delayFraction =
        (normalizedValue * (1 - clampedWindow)).clamp(0.0, 1.0);
    final int delayMs = (totalMs * delayFraction).round();

    if (delayMs <= 0) {
      _fadeController.forward(from: 0.0);
      return;
    }

    _fadeDelayTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      _fadeController.forward(from: 0.0);
    });
  }

  Duration _fadeDurationFrom(Duration base) {
    final int totalMs = base.inMilliseconds;
    if (totalMs <= 0) {
      return const Duration(milliseconds: 1);
    }
    final fadeMs = (totalMs * _fadeWindowFraction)
        .round()
        .clamp(1, totalMs); // always at least 1ms
    return Duration(milliseconds: fadeMs);
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
