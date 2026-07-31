// Integration test: runs on a real Android device/emulator (unlike the
// tests in this package's test/, which run on the host against
// FakeRtlSdrDriver). Proves the widget_rtlsdr <- core_rtlsdr <-
// driver_rtlsdr chain reaches libnative_rtlsdr.so on this device (right
// ABI, Oboe/librtlsdr/libusb resolved) and that the immersive UI actually
// renders against a real (dongle-less) NativeRtlSdrDriver instance without
// crashing — not just against FakeRtlSdrDriver as this package's own
// test/ does. Doesn't need an RTL-SDR dongle physically connected.
import 'package:core_rtlsdr/core_rtlsdr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:widget_rtlsdr/widget_rtlsdr.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('NativeRtlSdrDriver reaches the native core via an FFI call', (
    tester,
  ) async {
    final driver = NativeRtlSdrDriver();
    addTearDown(driver.dispose);

    // isOpen alone would already fail here (dlopen/link error surfacing as
    // an exception) if libnative_rtlsdr.so hadn't been packaged for this
    // device's ABI. Safe to call with no dongle connected — always false in
    // that state.
    expect(driver.isOpen, isFalse);

    // getStats() exercises the calloc<ShimStats>() buffer and the FFI call
    // that fills it — a fuller round-trip than a status-only call.
    final stats = driver.getStats();
    expect(stats, isNotNull);
  });

  testWidgets(
    'RtlSdrImmersiveScreen renders against a real NativeRtlSdrDriver with no dongle',
    (tester) async {
      final driver = NativeRtlSdrDriver();
      addTearDown(driver.dispose);
      final radio = RadioController(driver);
      addTearDown(radio.dispose);

      await tester.pumpWidget(
        MaterialApp(home: RtlSdrImmersiveScreen(radio: radio)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RtlSdrImmersiveScreen), findsOneWidget);
    },
  );
}
