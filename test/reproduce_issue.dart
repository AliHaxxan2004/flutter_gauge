import 'dart:math';

void main() {
  // Mock values
  double shortestSide = 300;
  double thickness = 20;
  double radiusFactor = 1.0;
  double startAngleDeg = 0;
  double endAngleDeg = 180;
  double value = 50;
  double gaugeStart = 0;
  double gaugeEnd = 100;

  // Track Logic (from RenderRadialGaugeContainer)
  double trackRadius = (shortestSide / 2.0) * radiusFactor;
  print('Track Radius: $trackRadius');

  // Pointer Logic (UPDATED)
  double pointerRadius = (shortestSide / 2) * radiusFactor;
  print('Pointer Radius: $pointerRadius');

  print('Diff: ${trackRadius - pointerRadius}');

  if ((trackRadius - pointerRadius).abs() < 0.001) {
    print('SUCCESS: Pointer radius matches track radius.');
  } else {
    print('FAILURE: Pointer radius does not match track radius.');
  }
}
