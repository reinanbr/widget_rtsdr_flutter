## 0.2.0

- `FrequencyReadout`: each digit now has a small up/down arrow button
  above/below it (in addition to the existing drag/scroll gesture) to step
  that digit's place value by ±1 — easier to hit precisely on a
  touchscreen than a drag gesture.
- Bumped the `core_rtlsdr` dependency to `^0.2.0` for its new
  Downloads/MediaStore recording and share API.
- `RecordingPanel` now records into the real, shared Downloads folder by
  default (via `RecordingController.startRecordingToDownloads`/
  `startIqRecordingToDownloads`, falling back automatically to the previous
  app-specific-storage default on Android below API 29) — passing
  `buildFilePath`/`buildIqFilePath` still records to exactly that path
  instead, unchanged. Each completed recording also gets a share button
  (Android's native share sheet).

## 0.1.0

- Bumped the `core_rtlsdr` dependency from `^0.0.2` to `^0.1.0` — the tight
  caret constraint on a `0.0.x` version could never resolve past `0.0.x` at
  all (the same class of bug `core_rtlsdr`'s own changelog documents
  happening to it with `driver_rtlsdr`), so this package was silently stuck
  behind every `core_rtlsdr` release since its own `0.0.1`.
- Added raw I/Q recording controls to `RecordingPanel`, alongside the
  existing PCM ones (independent — both can run at once), using
  `core_rtlsdr` 0.1.0's `RecordingController.startIqRecording`/
  `stopIqRecording`/`isIqRecording` + `defaultIqRecordingPath`. Both PCM and
  I/Q rows now also show live bytes-written
  (`RadioController.recordingBytesWritten`/`iqRecordingBytesWritten`).
- Added `SpectrumTuner`: a gqrx/CubicSDR-style combined scope + waterfall
  driven by one shared gesture surface — tap/drag anywhere to retune, drag
  either edge of the shaded passband band to resize the demod filter width
  live, pinch to zoom the visible span. Replaces the separately-tuned
  `SpectrumScope`/`WaterfallView` pair inside `RtlSdrImmersiveScreen` (both
  widgets are still exported and usable standalone for apps that want
  independent scope/waterfall tuning instead).
- `RtlSdrImmersiveScreen.tuneStepHz` (previously accepted but never applied)
  is now actually used: `SpectrumTuner`'s tune gesture rounds to the
  nearest step before calling `RadioController.setFrequencyHz`.
- Extracted `frequencyAtFraction`/`fractionForFrequency` (internal) so the
  frequency↔pixel math is shared between `SpectrumScope` and `SpectrumTuner`
  instead of duplicated.

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
