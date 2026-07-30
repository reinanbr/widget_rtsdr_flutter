import 'package:core_rtlsdr/core_rtlsdr.dart';
import 'package:flutter/material.dart';

import '../painters/spectrum_painter.dart';
import '../theme/rtlsdr_theme.dart';

/// Live FFT view (gqrx's top "Hist" plot) driven directly by a
/// [SpectrumController] — listens to it internally, so just drop this in
/// and it updates itself at the controller's polling rate.
///
/// Drag horizontally to retune: [onFrequencyChanged] receives the
/// frequency under the pointer, computed from [centerFrequencyHz] and
/// [spanHz] (pass `radio.frequencyHz` and `radio.sampleRateHz`). Pass
/// [passbandHz] (see [defaultPassbandHzFor]) to shade the current demod
/// filter's passband around the tuned frequency, the same cue gqrx/
/// CubicSDR both show.
class SpectrumScope extends StatelessWidget {
  const SpectrumScope({
    super.key,
    required this.spectrum,
    required this.centerFrequencyHz,
    required this.spanHz,
    this.passbandHz,
    this.minDb = -100,
    this.maxDb = -10,
    this.showCursor = true,
    this.showGridLabels = true,
    this.showFrequencyAxis = true,
    this.onFrequencyChanged,
  });

  final SpectrumController spectrum;
  final int centerFrequencyHz;
  final int spanHz;
  final int? passbandHz;
  final double minDb;
  final double maxDb;
  final bool showCursor;
  final bool showGridLabels;
  final bool showFrequencyAxis;
  final ValueChanged<int>? onFrequencyChanged;

  int _frequencyAt(double dx, double width) {
    final fraction = (dx / width).clamp(0.0, 1.0);
    final startHz = centerFrequencyHz - spanHz ~/ 2;
    return startHz + (fraction * spanHz).round();
  }

  @override
  Widget build(BuildContext context) {
    final theme = RtlSdrTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapUp: onFrequencyChanged == null
              ? null
              : (details) => onFrequencyChanged!(
                  _frequencyAt(details.localPosition.dx, constraints.maxWidth),
                ),
          onHorizontalDragUpdate: onFrequencyChanged == null
              ? null
              : (details) => onFrequencyChanged!(
                  _frequencyAt(details.localPosition.dx, constraints.maxWidth),
                ),
          child: ListenableBuilder(
            listenable: spectrum,
            builder: (context, _) {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: SpectrumPainter(
                  bins: spectrum.bins,
                  minDb: minDb,
                  maxDb: maxDb,
                  theme: theme,
                  centerFrequencyHz: centerFrequencyHz,
                  spanHz: spanHz,
                  passbandHz: passbandHz,
                  cursorFraction: showCursor ? 0.5 : null,
                  showGridLabels: showGridLabels,
                  showFrequencyAxis: showFrequencyAxis,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
