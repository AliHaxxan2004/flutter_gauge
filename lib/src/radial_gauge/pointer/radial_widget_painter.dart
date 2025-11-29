import 'dart:math';
import 'package:flutter/rendering.dart';
import '../../../geekyants_flutter_gauges.dart';

class RenderRadialWidgetPointer extends RenderProxyBox {
  RenderRadialWidgetPointer({
    required double value,
    required RadialGauge radialGauge,
    required bool isInteractive,
    required ValueChanged<double>? onChanged,
    VoidCallback? onTap, // Add this
  })  : _value = value,
        _radialGauge = radialGauge,
        _isInteractive = isInteractive,
        _onChanged = onChanged,
        _onTap = onTap;

  /// Gets the value to [RadialWidgetPointer].
  double get value => _value;
  double _value;

  /// Sets the value for [RadialWidgetPointer].
  set setValue(double value) {
    if (_value == value) {
      return;
    }
    _value = value;
    markNeedsPaint();
    markNeedsLayout();
  }

  /// Sets  isInteractive for  [RadialWidgetPointer].
  set setIsInteractive(bool value) {
    if (value == _isInteractive) {
      return;
    }

    _isInteractive = value;
    markNeedsPaint();
    markNeedsLayout();
  }

  RadialGauge get radialGauge => _radialGauge;
  RadialGauge _radialGauge;
  set setRadialGauge(RadialGauge value) {
    if (value == _radialGauge) {
      return;
    }

    _radialGauge = value;
    markNeedsPaint();
    markNeedsLayout();
  }

  /// Gets  isInteractive for  [RadialWidgetPointer].
  bool get isInteractive => _isInteractive;
  bool _isInteractive;

  /// Gets and sets the onChanged assigned to [RadialWidgetPointer].
  ValueChanged<double>? get onChanged => _onChanged;
  ValueChanged<double>? _onChanged;
  set onChanged(ValueChanged<double>? value) {
    if (value == _onChanged) {
      return;
    }
    _onChanged = value;
  }

  @override
  void performLayout() {
    // Use the same layout logic as the shape pointer
    size = Size(constraints.maxWidth, constraints.maxHeight);

    if (child != null) {
      // Layout the child with the available constraints
      child!.layout(constraints, parentUsesSize: true);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    double gaugeStart = _radialGauge.track.start;
    double gaugeEnd = _radialGauge.track.end;

    // Use the exact same center calculation as the shape pointer
    final center = Offset(
        size.width * _radialGauge.xCenterCoordinate + offset.dx,
        size.height * _radialGauge.yCenterCoordinate + offset.dy);

    double value = calculateValueAngle(_value, gaugeStart, gaugeEnd);
    double startAngle = (_radialGauge.track.startAngle - 180) * (pi / 180);
    double endAngle = (_radialGauge.track.endAngle - 180) * (pi / 180);

    final double angle = startAngle + (value / 100) * (endAngle - startAngle);

    // Calculate radius to match the center of the value bar
    // This matches the RadialValueBar calculation: (size.shortestSide / 2.0 - track.thickness) * radiusFactor
    double circlePointerOffset =
        (size.shortestSide / 2.0 - _radialGauge.track.thickness) *
            _radialGauge.radiusFactor;

    double circlePointerEndX = center.dx + circlePointerOffset * cos(angle);
    double circlePointerEndY = center.dy + circlePointerOffset * sin(angle);

    // Center the child widget at the pointer position
    final childCenterOffset = Offset(circlePointerEndX - child!.size.width / 2,
        circlePointerEndY - child!.size.height / 2);

    // Save the canvas state, translate to the correct position, and paint the child
    context.paintChild(child!, childCenterOffset);
  }

  double calculateValueAngle(double value, double gaugeStart, double gaugeEnd) {
    double newValue = (value - gaugeStart) / (gaugeEnd - gaugeStart) * 100;
    return newValue;
  }

  VoidCallback? get onTap => _onTap;
  VoidCallback? _onTap;
  set onTap(VoidCallback? value) {
    if (value == _onTap) return;
    _onTap = value;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (child == null) return false;

    // Recalculate the child's painted offset (same math as paint)
    double gaugeStart = _radialGauge.track.start;
    double gaugeEnd = _radialGauge.track.end;

    final center = Offset(
      size.width * _radialGauge.xCenterCoordinate,
      size.height * _radialGauge.yCenterCoordinate,
    );

    double value = calculateValueAngle(_value, gaugeStart, gaugeEnd);
    double startAngle = (_radialGauge.track.startAngle - 180) * (pi / 180);
    double endAngle = (_radialGauge.track.endAngle - 180) * (pi / 180);

    final double angle = startAngle + (value / 100) * (endAngle - startAngle);

    double circlePointerOffset =
        (size.shortestSide / 2.0 - _radialGauge.track.thickness) *
            _radialGauge.radiusFactor;

    double circlePointerEndX = center.dx + circlePointerOffset * cos(angle);
    double circlePointerEndY = center.dy + circlePointerOffset * sin(angle);

    final childCenterOffset = Offset(
      circlePointerEndX - child!.size.width / 2,
      circlePointerEndY - child!.size.height / 2,
    );

    // Convert position into child's local coordinate system
    final Offset localChildPos = position - childCenterOffset;

    // Delegate hit testing to the child at its local coordinates.
    if (child!.hitTest(result, position: localChildPos)) {
      // add an entry for this render object so handleEvent is called on it
      result.add(BoxHitTestEntry(this, position));
      return true;
    }

    return false;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerUpEvent) {
      // trigger on release, like a normal tap
      if (onTap != null) {
        onTap!();
      }
    }
    // Don’t forward to super if you don’t want child gestures at all
  }
}
