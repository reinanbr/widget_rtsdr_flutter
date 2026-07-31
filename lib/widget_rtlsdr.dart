/// Immersive, gqrx-inspired widget library for RTL-SDR on Flutter, built
/// entirely on top of `core_rtlsdr`'s `ChangeNotifier` controllers — never
/// on `driver_rtlsdr`/`dart:ffi` directly, so every widget here also works
/// against `core_rtlsdr/testing.dart`'s `FakeRtlSdrDriver` with no Android
/// device or dongle at all (see this package's `example/`).
///
/// ## Building blocks
///
/// - Display widgets: [FrequencyReadout] (odometer-style digit tuner —
///   drag or scroll a digit to change just that place), [SpectrumScope]
///   (FFT line/fill plot, tap/drag to retune), [WaterfallView] (scrolling
///   spectrogram), [SpectrumTuner] (gqrx/CubicSDR-style combined scope +
///   waterfall — one shared tune gesture, drag the passband edges to
///   resize filter width, pinch to zoom span), [SignalMeter] (dBFS bar
///   with a squelch tick).
/// - Control panels, one per `core_rtlsdr` controller: [GainPanel],
///   [SquelchPanel], [StereoRdsPanel], [RecordingPanel], [ScanPanel],
///   [PresetsPanel], [StatsPanel], [UsbStatusBanner]. Each is a
///   self-contained [RtlSdrPanel] section usable standalone.
/// - Theming: wrap a screen in [RtlSdrTheme] (data: [RtlSdrThemeData.dark]
///   or `.light`) to restyle every widget above at once; everything falls
///   back to `.dark` when used without one.
///
/// ## Screens and distributed settings
///
/// [RtlSdrImmersiveScreen] is the full instrument view (meter + tuner +
/// scope + waterfall). Settings are modeled as [RtlSdrSettingsSection]s —
/// plain `(id, title, icon, builder)` records — so the *same* section list
/// can be distributed three ways without touching the panels themselves:
///
/// 1. behind the immersive screen's settings button, via
///    [RtlSdrSettingsScreen] (drill-down list on phones, master-detail
///    split on wide screens — see [RtlSdrSettingsLayout]);
/// 2. as a fixed side panel next to the scope on very wide windows
///    (automatic in [RtlSdrImmersiveScreen] above
///    `sideSettingsBreakpoint`);
/// 3. individually, anywhere in a host app's own navigation, via
///    [RtlSdrSettingsSection.pageRoute] / [RtlSdrSettingSectionScreen].
library;

export 'src/demod_bandwidth.dart';
export 'src/navigation/rtlsdr_settings_section.dart';
export 'src/panels/gain_panel.dart';
export 'src/panels/presets_panel.dart';
export 'src/panels/recording_panel.dart';
export 'src/panels/scan_panel.dart';
export 'src/panels/squelch_panel.dart';
export 'src/panels/stats_panel.dart';
export 'src/panels/stereo_rds_panel.dart';
export 'src/panels/usb_status_banner.dart';
export 'src/screens/rtlsdr_immersive_screen.dart';
export 'src/screens/rtlsdr_setting_section_screen.dart';
export 'src/screens/rtlsdr_settings_screen.dart';
export 'src/theme/rtlsdr_theme.dart';
export 'src/theme/rtlsdr_theme_data.dart';
export 'src/widgets/frequency_readout.dart';
export 'src/widgets/mode_selector.dart';
export 'src/widgets/rtlsdr_panel.dart';
export 'src/widgets/signal_meter.dart';
export 'src/widgets/spectrum_scope.dart';
export 'src/widgets/spectrum_tuner.dart';
export 'src/widgets/waterfall_view.dart';
