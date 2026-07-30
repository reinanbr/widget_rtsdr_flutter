import 'package:flutter_test/flutter_test.dart';
import 'package:widget_rtlsdr_example/app.dart';

void main() {
  testWidgets('shows the USB permission flow until a dongle is ready', (
    tester,
  ) async {
    await tester.pumpWidget(const WidgetRtlsdrExampleApp());
    await tester.pump(const Duration(milliseconds: 100));

    // No dongle plugged in (the default, host-side `UsbState`) — the
    // immersive radio screen must stay hidden until `deviceReady`.
    expect(find.text('No RTL-SDR dongle detected'), findsOneWidget);
  });
}
