///
/// Utility helpers for common Radial Gauge math operations.
///

/// Normalizes a value to a 0–1 factor based on the provided gauge range.
///
/// Returns 0 when the range is zero or when the computed factor is not finite.
/// Values outside the range are clamped so pointers never overshoot the track.
double normalizeGaugeValue(double value, double gaugeStart, double gaugeEnd) {
  final double span = gaugeEnd - gaugeStart;
  if (span == 0) {
    return 0;
  }

  final double normalized = (value - gaugeStart) / span;
  if (!normalized.isFinite) {
    return 0;
  }

  return normalized.clamp(0.0, 1.0);
}

