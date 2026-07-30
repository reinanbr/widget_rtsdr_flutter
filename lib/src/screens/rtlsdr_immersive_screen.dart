import 'package:core_rtlsdr/core_rtlsdr.dart';
import 'package:flutter/material.dart';

import '../demod_bandwidth.dart';
import '../navigation/rtlsdr_settings_section.dart';
import '../theme/rtlsdr_theme.dart';
import '../widgets/frequency_readout.dart';
import '../widgets/mode_selector.dart';
import '../widgets/signal_meter.dart';
import '../widgets/spectrum_scope.dart';
import '../widgets/waterfall_view.dart';
import 'rtlsdr_settings_screen.dart';

/// The full gqrx-style instrument screen: signal meter, big digit-tuner,
/// FFT scope and waterfall filling the whole screen, with a settings
/// button opening [RtlSdrSettingsScreen] (or, on a wide window, a
/// side-by-side settings panel next to the scope instead of a separate
/// screen — see [sideSettingsBreakpoint]).
///
/// This screen only depends on [RadioController] (and, through it,
/// `radio.spectrumController`) — it never touches `UsbState`/`UsbChannel`
/// itself; show [UsbStatusBanner] ahead of this screen while the dongle
/// isn't `deviceReady` yet, the same order the `core_rtlsdr` example uses.
class RtlSdrImmersiveScreen extends StatelessWidget {
  const RtlSdrImmersiveScreen({
    super.key,
    required this.radio,
    this.settingsSections = const [],
    this.settingsTitle = 'Settings',
    this.minDb = -100,
    this.maxDb = -10,
    this.sideSettingsBreakpoint = 1100,
    this.tuneStepHz = 1000,
  });

  final RadioController radio;

  /// Sections shown behind the settings button (gain, squelch, stereo/RDS,
  /// recording, scan, presets, …) — build these with the host app's own
  /// controllers; see [RtlSdrSettingsSection].
  final List<RtlSdrSettingsSection> settingsSections;
  final String settingsTitle;

  final double minDb;
  final double maxDb;

  /// Above this window width, settings render as a fixed side panel next
  /// to the scope instead of behind a button — an immersive screen this
  /// wide has the room to show both at once, same spirit as
  /// [RtlSdrSettingsScreen]'s own master-detail breakpoint.
  final double sideSettingsBreakpoint;

  /// Frequency step (Hz) applied by the tap-to-tune gesture on the scope.
  final int tuneStepHz;

  @override
  Widget build(BuildContext context) {
    final theme = RtlSdrTheme.of(context);
    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showSidePanel =
                settingsSections.isNotEmpty &&
                constraints.maxWidth >= sideSettingsBreakpoint;
            return Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _Scope(
                      radio: radio,
                      minDb: minDb,
                      maxDb: maxDb,
                      showSettingsButton:
                          settingsSections.isNotEmpty && !showSidePanel,
                      settingsSections: settingsSections,
                      settingsTitle: settingsTitle,
                    ),
                  ),
                ),
                if (showSidePanel)
                  SizedBox(
                    width: 360,
                    child: RtlSdrSettingsScreen(
                      sections: settingsSections,
                      layout: RtlSdrSettingsLayout.drillDown,
                      title: settingsTitle,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Scope extends StatelessWidget {
  const _Scope({
    required this.radio,
    required this.minDb,
    required this.maxDb,
    required this.showSettingsButton,
    required this.settingsSections,
    required this.settingsTitle,
  });

  final RadioController radio;
  final double minDb;
  final double maxDb;
  final bool showSettingsButton;
  final List<RtlSdrSettingsSection> settingsSections;
  final String settingsTitle;

  @override
  Widget build(BuildContext context) {
    final theme = RtlSdrTheme.of(context);
    return ListenableBuilder(
      listenable: radio,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SignalMeter(
              valueDb: radio.rfLevelDbfs,
              minDb: minDb,
              maxDb: maxDb,
              squelchDb: radio.demodMode.supportsSquelch
                  ? radio.squelchThresholdDb
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: FrequencyReadout(
                      frequencyHz: radio.frequencyHz,
                      onChanged: radio.setFrequencyHz,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _StreamButton(radio: radio),
                if (showSettingsButton) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.settings, color: theme.textSecondary),
                    tooltip: settingsTitle,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RtlSdrSettingsScreen(
                          sections: settingsSections,
                          title: settingsTitle,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            ModeSelector(radio: radio),
            const SizedBox(height: 12),
            Expanded(
              flex: 4,
              child: SpectrumScope(
                spectrum: radio.spectrumController,
                centerFrequencyHz: radio.frequencyHz,
                spanHz: radio.sampleRateHz,
                passbandHz: defaultPassbandHzFor(radio.demodMode),
                minDb: minDb,
                maxDb: maxDb,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              flex: 5,
              child: WaterfallView(
                spectrum: radio.spectrumController,
                spanHz: radio.sampleRateHz,
                passbandHz: defaultPassbandHzFor(radio.demodMode),
                minDb: minDb,
                maxDb: maxDb,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StreamButton extends StatelessWidget {
  const _StreamButton({required this.radio});

  final RadioController radio;

  @override
  Widget build(BuildContext context) {
    final theme = RtlSdrTheme.of(context);
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: radio.isStreaming ? theme.meterHot : theme.accent,
        foregroundColor: theme.background,
      ),
      onPressed: radio.isStreaming ? radio.stopStreaming : radio.startStreaming,
      icon: Icon(radio.isStreaming ? Icons.stop : Icons.play_arrow),
      label: Text(radio.isStreaming ? 'Stop' : 'Start'),
    );
  }
}
