import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geekyants_flutter_gauges/src/radial_gauge/pointer/needle_pointer.dart';
import 'package:geekyants_flutter_gauges/src/radial_gauge/radial_gauge.dart';
import 'package:geekyants_flutter_gauges/src/radial_gauge/radial_track.dart';

class RadialGaugeState extends InheritedWidget {
  const RadialGaugeState({
    Key? key,
    required Widget child,
    required this.track,
    required this.rGauge,
    this.needlePointer,
    this.valueBarAnimationProgress,
    this.reportValueBarProgress,
    this.removeValueBarProgress,
  }) : super(key: key, child: child);

  final RadialGauge rGauge;
  final RadialTrack track;
  final NeedlePointer? needlePointer;
  final ValueListenable<double>? valueBarAnimationProgress;
  final void Function(Object identifier, double progress)? reportValueBarProgress;
  final void Function(Object identifier)? removeValueBarProgress;

// Radial Gauge scoppe method
  static RadialGaugeState of(BuildContext context) {
    late RadialGaugeState scope;

    final InheritedWidget widget = context
        .getElementForInheritedWidgetOfExactType<RadialGaugeState>()!
        .widget as InheritedWidget;

    if (widget is RadialGaugeState) {
      scope = widget;
    }
    return scope;
  }

  @override
  bool updateShouldNotify(RadialGaugeState oldWidget) {
    return track != oldWidget.rGauge.track;
  }
}
