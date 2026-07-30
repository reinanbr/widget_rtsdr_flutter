## 0.0.1

- Initial release: an immersive, gqrx/CubicSDR-inspired widget library for
  Android, built entirely on top of `core_rtlsdr`'s `ChangeNotifier`
  controllers (never on `driver_rtlsdr`/`dart:ffi` directly) — for use on a
  real device with an RTL-SDR dongle plugged in via USB-OTG.
- Display widgets: `FrequencyReadout` (odometer-style digit tuner — drag or
  scroll a digit to change just that place), `SpectrumScope` (FFT line/
  fill plot with a bottom frequency axis and a shaded demod-passband
  overlay, tap/drag to retune), `WaterfallView` (scrolling spectrogram
  rendered as a single `drawVertices` mesh, same passband/cursor overlay
  as the scope), `SignalMeter` (dBFS bar with a squelch tick),
  `ModeSelector` (iterates `DemodMode.values`, so it stays correct as
  driver_rtlsdr adds modes).
- `defaultPassbandHzFor(DemodMode)`: default filter-bandwidth-per-mode
  (WFM/NFM/AM/USB/LSB) backing the passband overlay.
- Control panels, one per `core_rtlsdr` controller: `GainPanel`,
  `SquelchPanel`, `StereoRdsPanel`, `RecordingPanel`, `ScanPanel`,
  `PresetsPanel`, `StatsPanel`, `UsbStatusBanner` — each a self-contained
  `RtlSdrPanel` section, usable standalone.
- Theming via `RtlSdrTheme`/`RtlSdrThemeData` (`.dark`/`.light`), including
  a configurable waterfall colormap (`defaultWaterfallColormap`).
- `RtlSdrImmersiveScreen`: the full instrument view (meter + tuner + scope
  + waterfall), with an adaptive settings button/side panel.
- Distributed settings navigation: `RtlSdrSettingsSection` (a
  navigation-agnostic id/title/icon/builder unit) + `RtlSdrSettingsScreen`
  (drill-down subscreens on phones, master-detail split on wide screens)
  + `RtlSdrSettingSectionScreen`/`RtlSdrSettingsSection.pageRoute` for a
  host app that wants to place a section in its own navigation instead.
- `example/`: a real Android app — the same `UsbState`/`UsbChannel`
  permission flow and `NativeRtlSdrDriver` wiring as `core_rtlsdr`'s own
  example, just rendered through this package's widgets instead of plain
  Material ones. Requires a device and a dongle to see streaming; the
  package's own `test/` suite covers every widget host-side against
  `FakeRtlSdrDriver`/`UsbState` instead (no hardware needed for that).
- CI (`flutter analyze`/`flutter test` for the package and example app, a
  debug APK build) and a tag-triggered release workflow that also publishes
  to pub.dev.
