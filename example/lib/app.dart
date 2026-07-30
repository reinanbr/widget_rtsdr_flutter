import 'package:core_rtlsdr/core_rtlsdr.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:widget_rtlsdr/widget_rtlsdr.dart';

import 'home_screen.dart';

/// Composition root: wires `UsbState`/`UsbChannel` (USB permission
/// lifecycle) and a [NativeRtlSdrDriver] to the `core_rtlsdr` controllers —
/// the exact same shape as `core_rtlsdr`'s own example, since
/// `widget_rtlsdr` is the widget layer meant to sit on top of it on a real
/// Android device with an RTL-SDR dongle plugged in via USB-OTG.
///
/// Every widget in the package renders through [RtlSdrTheme], so this is
/// also the one place that would switch between [RtlSdrThemeData.dark] and
/// `.light`.
class WidgetRtlsdrExampleApp extends StatelessWidget {
  const WidgetRtlsdrExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsbState()),
        ProxyProvider<UsbState, UsbChannel>(
          update: (_, usbState, previous) =>
              previous ?? UsbChannel(state: usbState),
          dispose: (_, channel) => channel.dispose(),
        ),
        Provider<RtlSdrDriver>(
          create: (_) => NativeRtlSdrDriver(),
          dispose: (_, driver) => driver.dispose(),
        ),
        ChangeNotifierProvider(
          create: (context) => RadioController(context.read<RtlSdrDriver>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              RecordingController(context.read<RtlSdrDriver>()),
        ),
        ChangeNotifierProvider(create: (_) => ScanController()),
        ChangeNotifierProvider(
          create: (_) =>
              PresetsController(const SharedPreferencesPresetsRepository())
                ..load(),
        ),
      ],
      child: MaterialApp(
        title: 'widget_rtlsdr example',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: const Color(0xFF00E5D1),
          useMaterial3: true,
        ),
        home: RtlSdrTheme(
          data: RtlSdrThemeData.dark(),
          child: const HomeScreen(),
        ),
      ),
    );
  }
}
