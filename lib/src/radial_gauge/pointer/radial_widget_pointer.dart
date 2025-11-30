import 'package:flutter/material.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';
import 'package:geekyants_flutter_gauges/src/radial_gauge/pointer/radial_widget_painter.dart';
import '../radial_gauge_state.dart';
import '../utils/radial_gauge_math.dart';

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
    this.fadeInTriggerProgress = 0.8,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.enableValueBasedStagger = true,
    Duration duration = const Duration(milliseconds: 1000),
    Curve curve = Curves.easeInOut,
  })  : assert(
          fadeInTriggerProgress >= 0 && fadeInTriggerProgress <= 1,
          '`fadeInTriggerProgress` must be within 0–1.',
        ),
        super(key: key, duration: duration, curve: curve);

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

  /// Fraction (0–1) of the implicit animation progress after which the pointer
  /// begins to fade in. Defaults to `0.8`, meaning the pointer waits until
  /// 80% of the animation has completed before becoming visible.
  final double fadeInTriggerProgress;

  /// Duration used to ease the fade in once it starts. This is internally
  /// normalized against [duration] to keep the fade smooth even if the total
  /// animation time is reduced to make the pointers appear sooner.
  final Duration fadeInDuration;

  /// When enabled, pointers with lower values start their fade earlier than
  /// pointers with higher values, creating a sequential appearance that follows
  /// the gauge values (e.g., 10 → 20 → 30).
  final bool enableValueBasedStagger;

  @override
  ImplicitlyAnimatedWidgetState<RadialWidgetPointer> createState() =>
      _RadialWidgetPointerState();
}

class _RadialWidgetPointerState
    extends AnimatedWidgetBaseState<RadialWidgetPointer> {
  Tween<double>? _valueTween;
  bool _isFirstBuild = true;

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

    final double fadeStart = _resolveFadeStart(scope);
    final double fadeSpan = _resolveFadeSpan();
    final double fadeEnd = (fadeStart + fadeSpan).clamp(fadeStart, 1.0);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final double pointerValue =
            _valueTween?.evaluate(animation) ?? widget.value;
        final double opacity =
            _resolveOpacity(animation.value, fadeStart, fadeEnd);

        return IgnorePointer(
          ignoring: opacity <= 0,
          child: Opacity(
            opacity: opacity,
            child: _RadialWidgetPointerRenderWidget(
              value: pointerValue,
              radialGauge: scope.rGauge,
              isInteractive: widget.isInteractive,
              onChanged: widget.onChanged,
              onTap: widget.onTap,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }

  double _resolveFadeStart(RadialGaugeState scope) {
    final double baseTrigger = widget.fadeInTriggerProgress.clamp(0.0, 1.0);

    if (!widget.enableValueBasedStagger) {
      return baseTrigger;
    }

    final double normalizedValue = normalizeGaugeValue(
      widget.value,
      scope.track.start,
      scope.track.end,
    );

    const double minFactor = 0.25;
    final double minTrigger = baseTrigger * minFactor;
    return minTrigger + (baseTrigger - minTrigger) * normalizedValue;
  }

  double _resolveFadeSpan() {
    final int totalMs = widget.duration.inMilliseconds;
    if (totalMs <= 0) {
      return 1;
    }

    final int fadeMs = widget.fadeInDuration.inMilliseconds.clamp(1, totalMs);
    return fadeMs / totalMs;
  }

  double _resolveOpacity(double progress, double fadeStart, double fadeEnd) {
    if (progress <= fadeStart) {
      return 0;
    }
    if (progress >= fadeEnd || fadeEnd == fadeStart) {
      return 1;
    }

    final double normalized = (progress - fadeStart) / (fadeEnd - fadeStart);
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
