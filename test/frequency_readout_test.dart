import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_rtlsdr/widget_rtlsdr.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('renders grouped digits for a tuned frequency', (tester) async {
    await tester.pumpWidget(
      wrap(FrequencyReadout(frequencyHz: 91900000, onChanged: (_) {})),
    );

    // 91900000 padded to 10 digits is "0091900000" — '9' appears twice
    // (the 10-million and 100-thousand places).
    expect(find.text('9'), findsNWidgets(2));
    expect(find.text('1'), findsOneWidget);
    expect(find.text('.'), findsNWidgets(3));
  });

  testWidgets('dragging a digit upward reports an increased frequency', (
    tester,
  ) async {
    int? changed;
    await tester.pumpWidget(
      wrap(
        FrequencyReadout(
          frequencyHz: 91900000,
          onChanged: (hz) => changed = hz,
        ),
      ),
    );

    // Drag the rightmost (1 Hz place) digit upward — a drag-up should
    // increase the value at that place.
    final lastDigit = find.text('0').last;
    await tester.drag(lastDigit, const Offset(0, -40));
    await tester.pumpAndSettle();

    expect(changed, isNotNull);
    expect(changed! > 91900000, isTrue);
  });

  testWidgets('clamps to minHz/maxHz', (tester) async {
    int? changed;
    await tester.pumpWidget(
      wrap(
        FrequencyReadout(
          frequencyHz: 24000000,
          minHz: 24000000,
          maxHz: 1766000000,
          onChanged: (hz) => changed = hz,
        ),
      ),
    );

    final firstDigit = find.text('0').first;
    await tester.drag(firstDigit, const Offset(0, 400));
    await tester.pumpAndSettle();

    expect(changed, 24000000);
  });
}
