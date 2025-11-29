import 'package:flutter/foundation.dart';
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
  ValueListenable<double>? _valueBarProgressListenable;
  double? _latestValueBarProgress;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscribeToValueBarProgress();
  }

  @override
  void didUpdateWidget(covariant NeedlePointer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _subscribeToValueBarProgress();
  }

  @override
  void dispose() {
    _valueBarProgressListenable?.removeListener(_onValueBarProgressChanged);
    super.dispose();
  }

  void _subscribeToValueBarProgress() {
    final RadialGaugeState scope = RadialGaugeState.of(context);
    final ValueListenable<double>? listenable =
        scope.valueBarAnimationProgress;
    if (_valueBarProgressListenable == listenable) {
      return;
    }

    _valueBarProgressListenable
        ?.removeListener(_onValueBarProgressChanged);
    _valueBarProgressListenable = listenable;
    _latestValueBarProgress = listenable?.value;
    _valueBarProgressListenable
        ?.addListener(_onValueBarProgressChanged);
  }

  void _onValueBarProgressChanged() {
    if (!mounted) {
      return;
    }
    setState(() {
      _latestValueBarProgress = _valueBarProgressListenable?.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final RadialGaugeState scope = RadialGaugeState.of(context);
    final double? progressValue =
        _latestValueBarProgress ?? scope.valueBarAnimationProgress?.value;

    return _NeedlePointerRenderWidget(
      value: _valueTween?.evaluate(animation) ?? widget.value,
      valueBarProgress: progressValue,
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
    required this.valueBarProgress,
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
  final double? valueBarProgress;
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
      valueBarProgress: valueBarProgress,
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
      ..valueBarProgress = valueBarProgress
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
