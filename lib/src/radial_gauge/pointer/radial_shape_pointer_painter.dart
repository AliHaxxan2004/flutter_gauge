import 'dart:math';

import 'package:flutter/material.dart';

import '../../../geekyants_flutter_gauges.dart';
import '../utils/radial_gauge_math.dart';

class RenderRadialShapePointer extends RenderBox {
  RenderRadialShapePointer({
    required double value,
    required Color color,
    required double height,
    required ValueChanged<double>? onChanged,
    required double width,
    required bool isInteractive,
    required PointerShape shape,
    required RadialGauge radialGauge,
    required double? valueBarProgress,
  })  : _value = value,
        _color = color,
        _height = height,
        _onChanged = onChanged,
        _isInteractive = isInteractive,
        _width = width,
        _shape = shape,
        _radialGauge = radialGauge,
        _valueBarProgress = valueBarProgress;

  double _value;
  Color _color;
  double _height;
  double _width;
  PointerShape _shape;
  RadialGauge _radialGauge;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.constrain(constraints.biggest);
  }

  @override
  void performLayout() {
    size = Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  bool hitTestSelf(Offset position) {
    Offset calculatedPosition = localToGlobal(position);

    if (pointerRect.contains(calculatedPosition)) {
      return true;
    } else if (pointerRect.contains(position)) {
      return true;
    } else {
      return false;
    }
  }

  ValueChanged<double>? get onChanged => _onChanged;
  ValueChanged<double>? _onChanged;
  set onChanged(ValueChanged<double>? value) {
    if (value == _onChanged) {
      return;
    }
    _onChanged = value;
  }

  // Sets the Interaction for [RenderNeedlePointer].
  set setIsInteractive(bool value) {
    if (value == _isInteractive) {
      return;
    }

    _isInteractive = value;
    markNeedsPaint();
  }

  // Gets the Interaction assigned to [RenderNeedlePointer].
  bool get isInteractive => _isInteractive;
  bool _isInteractive;

  set setValue(double value) {
    if (_value == value) {
      return;
    }
    _value = value;
    markNeedsPaint();
  }

  set setColor(Color color) {
    if (_color == color) {
      return;
    }
    _color = color;
    markNeedsPaint();
  }

  set setHeight(double height) {
    if (_height == height) {
      return;
    }
    _height = height;
    markNeedsPaint();
  }

  set setWidth(double width) {
    if (_width == width) {
      return;
    }
    _width = width;
    markNeedsPaint();
  }

  set setShape(PointerShape shape) {
    if (_shape == shape) {
      return;
    }
    _shape = shape;
    markNeedsPaint();
  }

  set setRadialGauge(RadialGauge radialGauge) {
    if (_radialGauge == radialGauge) {
      return;
    }
    _radialGauge = radialGauge;
    markNeedsPaint();
  }

  double? _valueBarProgress;
  set valueBarProgress(double? progress) {
    if (_valueBarProgress == progress) {
      return;
    }
    _valueBarProgress = progress;
    markNeedsPaint();
  }

  late Rect pointerRect;

  @override
  void paint(PaintingContext context, Offset offset) {
    final double visibility = _visibilityFactor;
    if (visibility <= 0) {
      return;
    }
    final canvas = context.canvas;

    double gaugeStart = _radialGauge.track.start;
    double gaugeEnd = _radialGauge.track.end;
    // final center = Offset(offset.dx, offset.dy);

    final center = Offset(
        size.width * _radialGauge.xCenterCoordinate + offset.dx,
        size.height * _radialGauge.yCenterCoordinate + offset.dy);

    final double normalizedValue =
        normalizeGaugeValue(_value, gaugeStart, gaugeEnd);
    double startAngle = (_radialGauge.track.startAngle - 180) * (pi / 180);
    double endAngle = (_radialGauge.track.endAngle - 180) * (pi / 180);

    final double angle =
        startAngle + normalizedValue * (endAngle - startAngle);

    double needleLength = 30;
    double needleWidth = 10;
    final pointerPath = Path();

    // double pointerOffset = 430 + 0;
    double pointerOffset =
        (size.shortestSide / 2 - _radialGauge.track.thickness) *
            _radialGauge.radiusFactor;

    double circlePointerOffset =
        (size.shortestSide / 2 - _radialGauge.track.thickness) *
            _radialGauge.radiusFactor;

    double pointerEndX = center.dx + pointerOffset * cos(angle);
    double pointerEndY = center.dy + pointerOffset * sin(angle);

    double circlePointerEndX = center.dx + circlePointerOffset * cos(angle);
    double circlePointerEndY = center.dy + circlePointerOffset * sin(angle);

    pointerPath.moveTo(pointerEndX, pointerEndY);
    pointerPath.lineTo(
      pointerEndX - needleWidth * cos(angle + pi / 2),
      pointerEndY - needleWidth * sin(angle + pi / 2),
    );
    pointerPath.lineTo(
      pointerEndX - (needleLength - needleWidth) * cos(angle),
      pointerEndY - (needleLength - needleWidth) * sin(angle),
    );
    pointerPath.lineTo(
      pointerEndX + needleWidth * cos(angle + pi / 2),
      pointerEndY + needleWidth * sin(angle + pi / 2),
    );
    pointerPath.close();

    pointerRect = Rect.fromCircle(
        center: Offset(pointerEndX, pointerEndY), radius: _width);

    // canvas.drawRect(pointerRect, Paint()..color = _color);
    canvas.drawCircle(
      Offset(circlePointerEndX, circlePointerEndY),
      _width,
      Paint()..color = _color.withOpacity(visibility.clamp(0.0, 1.0)),
    );
    // canvas.drawPath(pointerPath, Paint()..color = _color);
  }

  double get _visibilityFactor {
    final double? progress = _valueBarProgress;
    if (progress == null) {
      return 1.0;
    }
    if (progress < _value) {
      return 0.0;
    }

    final double span =
        (_radialGauge.track.end - _radialGauge.track.start).abs();
    final double fadeSpan = span == 0 ? 1.0 : span * 0.05;
    if (fadeSpan <= 0) {
      return 1.0;
    }
    final double delta = progress - _value;
    return (delta / fadeSpan).clamp(0.0, 1.0);
  }
}
