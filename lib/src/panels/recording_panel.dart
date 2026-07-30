import 'package:core_rtlsdr/core_rtlsdr.dart';
import 'package:flutter/material.dart';

import '../theme/rtlsdr_theme.dart';
import '../widgets/rtlsdr_panel.dart';

/// WAV recording subscreen over [RecordingController] — uses
/// [defaultRecordingPath] (app-specific external storage, no runtime
/// permission needed) unless [buildFilePath] is given.
class RecordingPanel extends StatelessWidget {
  const RecordingPanel({
    super.key,
    required this.radio,
    required this.recording,
    this.buildFilePath,
  });

  final RadioController radio;
  final RecordingController recording;
  final Future<String> Function()? buildFilePath;

  @override
  Widget build(BuildContext context) {
    final theme = RtlSdrTheme.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([radio, recording]),
      builder: (context, _) {
        return RtlSdrPanel(
          title: 'RECORDING',
          icon: Icons.fiber_manual_record,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: recording.isRecording
                      ? theme.meterHot
                      : theme.accent,
                  foregroundColor: theme.background,
                ),
                onPressed: !radio.isStreaming
                    ? null
                    : recording.isRecording
                    ? recording.stopRecording
                    : _start,
                icon: Icon(
                  recording.isRecording
                      ? Icons.stop
                      : Icons.fiber_manual_record,
                ),
                label: Text(
                  recording.isRecording ? 'Stop recording' : 'Start recording',
                ),
              ),
              if (recording.isRecording &&
                  recording.currentFilePath != null) ...[
                const SizedBox(height: 8),
                Text(
                  recording.currentFilePath!,
                  style: TextStyle(color: theme.textSecondary, fontSize: 12),
                ),
              ],
              if (!recording.isRecording &&
                  recording.lastRecordingPath != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Saved: ${recording.lastRecordingPath}',
                  style: TextStyle(color: theme.textSecondary, fontSize: 12),
                ),
              ],
              if (recording.lastError != null) ...[
                const SizedBox(height: 8),
                Text(
                  recording.lastError!,
                  style: TextStyle(color: theme.meterHot),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _start() async {
    final path = buildFilePath != null
        ? await buildFilePath!()
        : await defaultRecordingPath(
            frequencyHz: radio.frequencyHz,
            mode: radio.demodMode,
          );
    await recording.startRecording(path);
  }
}
