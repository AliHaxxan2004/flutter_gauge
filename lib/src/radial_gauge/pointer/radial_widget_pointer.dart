import 'package:flutter/foundation.dart';
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
  void didUpdateWidget(covariant RadialWidgetPointer oldWidget) {
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
    setState(
      () => _latestValueBarProgress =
          _valueBarProgressListenable?.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final RadialGaugeState scope = RadialGaugeState.of(context);
    final double? progressValue =
        _latestValueBarProgress ?? scope.valueBarAnimationProgress?.value;

    return _RadialWidgetPointerRenderWidget(
      value: _valueTween?.evaluate(animation) ?? widget.value,
      valueBarProgress: progressValue,
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
    required this.valueBarProgress,
    required this.radialGauge,
    required this.isInteractive,
    required this.onChanged,
    required this.onTap,
    required Widget child,
  }) : super(child: child);

  final double value;
  final double? valueBarProgress;
  final RadialGauge radialGauge;
  final bool isInteractive;
  final ValueChanged<double>? onChanged;
  final VoidCallback? onTap;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderRadialWidgetPointer(
      value: value,
      valueBarProgress: valueBarProgress,
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
      ..valueBarProgress = valueBarProgress
      ..setRadialGauge = radialGauge
      ..setIsInteractive = isInteractive
      ..onChanged = onChanged
      ..onTap = onTap;
  }
}
