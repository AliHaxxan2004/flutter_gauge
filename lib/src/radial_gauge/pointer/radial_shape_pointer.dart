import 'package:flutter/foundation.dart';
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
  void didUpdateWidget(covariant RadialShapePointer oldWidget) {
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

    return _RadialShapePointerRenderWidget(
      value: _valueTween?.evaluate(animation) ?? widget.value,
      valueBarProgress: progressValue,
      color: widget.color,
      height: widget.height,
      width: widget.width,
      isInteractive: widget.isInteractive,
      onChanged: widget.onChanged,
      shape: widget.shape,
      radialGauge: scope.rGauge,
    );
  }
}

class _RadialShapePointerRenderWidget extends LeafRenderObjectWidget {
  const _RadialShapePointerRenderWidget({
    required this.value,
    required this.valueBarProgress,
    required this.color,
    required this.height,
    required this.width,
    required this.isInteractive,
    required this.onChanged,
    required this.shape,
    required this.radialGauge,
  });

  final double value;
  final double? valueBarProgress;
  final Color color;
  final double height;
  final double width;
  final bool isInteractive;
  final ValueChanged<double>? onChanged;
  final PointerShape shape;
  final RadialGauge radialGauge;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderRadialShapePointer(
      value: value,
      valueBarProgress: valueBarProgress,
      color: color,
      height: height,
      width: width,
      isInteractive: isInteractive,
      onChanged: onChanged,
      shape: shape,
      radialGauge: radialGauge,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderRadialShapePointer renderObject) {
    renderObject
      ..setValue = value
      ..valueBarProgress = valueBarProgress
      ..setRadialGauge = radialGauge
      ..setColor = color
      ..setHeight = height
      ..setWidth = width
      ..onChanged = onChanged
      ..setIsInteractive = isInteractive
      ..setShape = shape;
  }
}
