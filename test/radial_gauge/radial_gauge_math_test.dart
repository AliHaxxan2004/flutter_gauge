import 'package:flutter_test/flutter_test.dart';
import 'package:geekyants_flutter_gauges/src/radial_gauge/utils/radial_gauge_math.dart';

void main() {
  group('normalizeGaugeValue', () {
    test('returns expected factor for in-range values', () {
      expect(normalizeGaugeValue(50, 0, 100), 0.5);
    });

    test('clamps values below the start of the range', () {
      expect(normalizeGaugeValue(-10, 0, 100), 0.0);
    });

    test('clamps values above the end of the range', () {
      expect(normalizeGaugeValue(150, 0, 100), 1.0);
    });

    test('handles reversed ranges', () {
      expect(normalizeGaugeValue(150, 200, 100), 0.5);
      expect(normalizeGaugeValue(50, 200, 100), 1.0);
      expect(normalizeGaugeValue(250, 200, 100), 0.0);
    });

    test('returns zero when start and end are equal', () {
      expect(normalizeGaugeValue(10, 100, 100), 0.0);
    });

    test('returns zero when normalization is not finite', () {
      expect(normalizeGaugeValue(double.nan, 0, 100), 0.0);
    });
  });
}

