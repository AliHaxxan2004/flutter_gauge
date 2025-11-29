import 'dart:math';
import 'package:flutter/rendering.dart';
import '../../../geekyants_flutter_gauges.dart';
import '../utils/radial_gauge_math.dart';

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
    final RenderBox? pointerChild = child;
    if (pointerChild == null) return;

    final Offset pointerPosition = _resolvePointerPosition();
    final Offset childHalfSize =
        Offset(pointerChild.size.width / 2, pointerChild.size.height / 2);
    final Offset childCenterOffset = offset + pointerPosition - childHalfSize;

    context.paintChild(pointerChild, childCenterOffset);
  }

  VoidCallback? get onTap => _onTap;
  VoidCallback? _onTap;
  set onTap(VoidCallback? value) {
    if (value == _onTap) return;
    _onTap = value;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final RenderBox? pointerChild = child;
    if (pointerChild == null) return false;

    final Offset pointerPosition = _resolvePointerPosition();
    final Offset childHalfSize =
        Offset(pointerChild.size.width / 2, pointerChild.size.height / 2);
    final Offset childOrigin = pointerPosition - childHalfSize;
    final Offset localChildPos = position - childOrigin;

    if (pointerChild.hitTest(result, position: localChildPos)) {
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

  Offset _resolvePointerPosition() {
    final double gaugeStart = _radialGauge.track.start;
    final double gaugeEnd = _radialGauge.track.end;
    final double normalizedValue = normalizeGaugeValue(
      _value,
      gaugeStart,
      gaugeEnd,
    );

    final double startAngle =
        (_radialGauge.track.startAngle - 180) * (pi / 180);
    final double endAngle = (_radialGauge.track.endAngle - 180) * (pi / 180);
    final double angle =
        startAngle + normalizedValue * (endAngle - startAngle);

    final double pointerRadius =
        (size.shortestSide / 2.0 - _radialGauge.track.thickness) *
            _radialGauge.radiusFactor;

    final double centerX = size.width * _radialGauge.xCenterCoordinate;
    final double centerY = size.height * _radialGauge.yCenterCoordinate;

    return Offset(
      centerX + pointerRadius * cos(angle),
      centerY + pointerRadius * sin(angle),
    );
  }
}
