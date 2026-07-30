# widget_rtlsdr

[![pub package](https://img.shields.io/pub/v/widget_rtlsdr.svg)](https://pub.dev/packages/widget_rtlsdr)
[![pub points](https://img.shields.io/pub/points/widget_rtlsdr)](https://pub.dev/packages/widget_rtlsdr/score)
[![CI](https://github.com/reinanbr/widget_rtsdr_flutter/actions/workflows/ci.yml/badge.svg)](https://github.com/reinanbr/widget_rtsdr_flutter/actions/workflows/ci.yml)
[![License: GPL v2 or later](https://img.shields.io/badge/license-GPLv2--or--later-blue.svg)](LICENSE)

Immersive, [gqrx](https://gqrx.dk/)/[CubicSDR](https://cubicsdr.com/)-inspired
widget library for RTL-SDR on Android/Flutter, built on top of
[`core_rtlsdr`](https://pub.dev/packages/core_rtlsdr)
([source](https://github.com/reinanbr/core_rtlsdr_flutter)), which is
itself built on [`driver_rtlsdr`](https://pub.dev/packages/driver_rtlsdr)
([source](https://github.com/reinanbr/driver_rtlsdr_flutter)).

`core_rtlsdr` gives you tuning/streaming/demod/gain/squelch/stereo/RDS/
spectrum/recording/scan/presets as plain `ChangeNotifier` controllers, but
deliberately ships **no UI** — its own `example/` is intentionally minimal
Material widgets, just enough to prove the controllers are sufficient on
their own. `widget_rtlsdr` is that UI layer: a big digit frequency readout,
an FFT scope and waterfall styled like a real receiver, themed control
panels, and a settings navigation that adapts from a phone to a tablet —
all driven by the same controllers, so this package never touches
`driver_rtlsdr` or `dart:ffi` directly either.

## What this package provides

- **Display widgets**: `FrequencyReadout` (odometer-style digit tuner — drag
  or scroll a digit to change just that place, carries cascade into
  neighbors automatically, same interaction as gqrx's tuning display),
  `SpectrumScope` (FFT line/fill plot with a bottom frequency axis and a
  shaded demod-passband overlay around the tuned frequency, tap/drag to
  retune), `WaterfallView` (scrolling spectrogram — rendered as a single
  `Canvas.drawVertices` mesh regardless of how many bins/rows are on
  screen, so it stays smooth at the spectrum controller's ~25 fps default),
  `SignalMeter` (dBFS bar with a squelch threshold tick), `ModeSelector`
  (iterates `DemodMode.values`, so it stays correct as `driver_rtlsdr` adds
  demodulation modes).
- **Control panels**, one per `core_rtlsdr` controller — each a
  self-contained, independently usable `RtlSdrPanel` section: `GainPanel`,
  `SquelchPanel`, `StereoRdsPanel`, `RecordingPanel`, `ScanPanel`,
  `PresetsPanel`, `StatsPanel`, `UsbStatusBanner`.
- **Theming**: `RtlSdrTheme`/`RtlSdrThemeData` (`.dark`/`.light`) — a
  near-black "receiver bezel" palette plus a configurable waterfall
  colormap (`defaultWaterfallColormap`, a gqrx-style dark-blue→cyan→green→
  yellow→red ramp). Every widget falls back to `.dark` if used without an
  ancestor `RtlSdrTheme`.
- **`RtlSdrImmersiveScreen`**: the full instrument view — meter, tuner,
  scope, waterfall — filling the screen.
- **Distributed settings navigation** — the piece that answers "where do
  gain/squelch/scan/presets/etc. actually live in my app?":
  `RtlSdrSettingsSection` is a plain, navigation-agnostic
  `(id, title, icon, builder)` unit. The *same* section list can be shown:
  1. behind `RtlSdrImmersiveScreen`'s settings button via
     `RtlSdrSettingsScreen` — a drill-down list pushing each section as its
     own full-screen subscreen on a phone, or a master-detail split (list +
     content, no navigation) on a tablet/wide window, switching
     automatically at a configurable breakpoint;
  2. as a fixed side panel next to the scope on very wide windows
     (automatic in `RtlSdrImmersiveScreen` above `sideSettingsBreakpoint`);
  3. individually, anywhere in a host app's own navigation/router, via
     `RtlSdrSettingsSection.pageRoute()` / `RtlSdrSettingSectionScreen`.

## What this package deliberately does NOT provide

- **A DI/state-management framework**: every widget takes its controller
  (`RadioController`, `ScanController`, ...) as a plain constructor
  parameter — wire them up with `provider`, `riverpod`, or nothing at all,
  same stance `core_rtlsdr` takes on `RtlSdrDriver`. `example/` uses
  `provider`, but that's the example's choice, not a requirement.
- **FFI or Android-platform code of its own**: it depends only on
  `core_rtlsdr`'s controllers. `NativeRtlSdrDriver` (the real, Android-only
  driver) and the `UsbState`/`UsbChannel` permission flow are
  `core_rtlsdr`/`driver_rtlsdr` concerns — see their docs.

## Installation

```yaml
dependencies:
  widget_rtlsdr: ^0.0.1
```

`widget_rtlsdr` depends on [`core_rtlsdr`](https://pub.dev/packages/core_rtlsdr)
(pulled in transitively), which itself depends on
[`driver_rtlsdr`](https://pub.dev/packages/driver_rtlsdr), which is
Android-only. See `core_rtlsdr`'s README for the two things your app needs
beyond `pubspec.yaml` (a `minSdk = 26` bump and a USB auto-open intent
filter) — nothing extra is needed for this package on top of that.

## Usage

```dart
import 'package:core_rtlsdr/core_rtlsdr.dart';
import 'package:widget_rtlsdr/widget_rtlsdr.dart';
```

### Minimal: just the immersive screen

Once you have a `RadioController` (see `core_rtlsdr`'s README for the USB
permission flow + `NativeRtlSdrDriver` wiring):

```dart
RtlSdrTheme(
  data: RtlSdrThemeData.dark(),
  child: RtlSdrImmersiveScreen(radio: radio),
)
```

### With distributed settings

```dart
RtlSdrImmersiveScreen(
  radio: radio,
  settingsSections: [
    RtlSdrSettingsSection(
      id: 'gain',
      title: 'Gain',
      icon: Icons.tune,
      builder: (context) => GainPanel(radio: radio),
    ),
    if (radio.demodMode.supportsSquelch)
      RtlSdrSettingsSection(
        id: 'squelch',
        title: 'Squelch',
        icon: Icons.volume_off,
        builder: (context) => SquelchPanel(radio: radio),
      ),
    RtlSdrSettingsSection(
      id: 'scan',
      title: 'Band scan',
      icon: Icons.search,
      builder: (context) => ScanPanel(radio: radio, scan: scan, presets: presets),
    ),
    // ...PresetsPanel, RecordingPanel, StereoRdsPanel, StatsPanel
  ],
)
```

Resize the window (or run on a tablet vs. a phone) to see the same section
list switch between a drill-down list of full-screen subscreens and a
side-by-side master-detail split — no extra code either way.

### A section on its own, in your app's own navigation

```dart
Navigator.of(context).push(gainSection.pageRoute());
```

See `example/` for a complete, runnable app: the same `UsbState`/
`UsbChannel` permission flow and `NativeRtlSdrDriver` composition root as
`core_rtlsdr`'s own example, rendered through this package's widgets.

## Testing without hardware

Every widget here takes a controller, not a driver — so build/test them
against `core_rtlsdr`'s `FakeRtlSdrDriver`
(`package:core_rtlsdr/testing.dart`) exactly like `core_rtlsdr`'s own test
suite does, no dongle/emulator/Android device needed:

```dart
final radio = RadioController(FakeRtlSdrDriver());
await tester.pumpWidget(MaterialApp(home: Scaffold(body: GainPanel(radio: radio))));
```

See this package's own `test/` for the full pattern, including
`UsbStatusBanner` exercised against every `UsbState`/`UsbConnectionStatus`
value (`UsbState` is plain Dart with no FFI, so it's host-testable too).

## License

GPLv2-or-later — see [LICENSE](LICENSE). `driver_rtlsdr` links `librtlsdr`
(GPLv2), which requires any software using it to be distributed under the
GPL; this package (and `core_rtlsdr`) inherit that requirement down the
dependency chain.
