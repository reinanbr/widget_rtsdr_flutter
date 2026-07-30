# widget_rtlsdr_example

Fully working example app for the `widget_rtlsdr` package: the same
`UsbState`/`UsbChannel` USB permission flow and `NativeRtlSdrDriver`
composition root as `core_rtlsdr`'s own example (see `lib/app.dart`), but
rendered through `RtlSdrImmersiveScreen` and this package's themed panels
instead of plain Material widgets.

## Running

```bash
flutter pub get
flutter run
```

Needs an Android device (`minSdk = 26`) — this is an Android-only app, same
as `core_rtlsdr`'s and `driver_rtlsdr`'s own examples (RTL-SDR access here
is a USB-OTG/Android-specific driver, not something a browser or desktop
build can exercise). Connect an RTL-SDR dongle via a USB-OTG cable to see
the full instrument screen; without one, the app shows the USB "no device
detected" state (`UsbStatusBanner`) instead.

## Tests

```bash
flutter test
```

Widget test of the initial (no-device) USB state — everything else
(`GainPanel`, `SquelchPanel`, `ModeSelector`, ...) is exercised host-side in
the parent package's own `test/` against `FakeRtlSdrDriver`/`UsbState`
instead, since those don't need an Android device to test meaningfully.
