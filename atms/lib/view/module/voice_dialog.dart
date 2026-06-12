import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loadweb/config/constants.dart';
import 'package:loadweb/util/common_util.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../l10n/app_localizations.dart';

// Voice search
class VoiceDialog extends StatefulWidget {
  const VoiceDialog({super.key});

  @override
  State<VoiceDialog> createState() => _VoiceDialogState();
}

class _VoiceDialogState extends State<VoiceDialog>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  String localeLang = Constants.LANG_VOICE_DEFAULT;
  String _recognizedText = "";
  Timer? _finishTimer;
  bool _isListening = false;
  bool _finishedListening = false;

  late AnimationController _micController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _micController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1700))
      ..repeat();
    _initVoice();
  }

  /// init voice .
  ///
  /// Return [Future<void>]
  Future<void> _initVoice() async {
    localeLang = await CommonUtil.getLocale();
    setState(() {});
    _startListening();
  }

  /// Start listening.
  ///
  /// Return [Future<void>]
  Future<void> _startListening() async {
    String localeVoice = await CommonUtil.getLocaleVoice();
    bool available = await _speech.initialize(
      onError: (e) => debugPrint("Speech Error: $e"),
      onStatus: (status) => debugPrint("STATUS: $status"),
    );

    if (!available) return;

    setState(() => _isListening = true);

    _speech.listen(
      localeId: localeVoice,
      onResult: (result) {
        setState(() => _recognizedText = result.recognizedWords);

        // reset timer 0.5s
        _resetFinishTimer();
      },
    );
  }

  /// Reset finish timer.
  ///
  /// Return [void]
  void _resetFinishTimer() {
    _finishTimer?.cancel();
    if (_recognizedText.isNotEmpty) {
      _finishTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) _finish();
      });
    }
  }

  /// Voice stop and back page.
  ///
  /// Return [void]
  void _finish() async {
    setState(() => _finishedListening = true); // check voice finish

    await Future.delayed(const Duration(milliseconds: 120));
    // waiting 1s to load frame.

    _speech.stop();

    // waiting 0.25s
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) Navigator.pop(context, _recognizedText.trim());
    });
  }

  @override
  void dispose() {
    _finishTimer?.cancel();
    _speech.stop();
    _micController.dispose();
    super.dispose();
  }

  /// Builds a ripple wave circle based on the given progress.
  ///
  /// The wave expands from 100 to 260 in size,
  /// while gradually fading out as it grows.
  Widget _wave(double progress) {
    // Calculate the circle size (from 100 → 260 as progress goes 0 → 1)
    final double size = 100 + (260 - 100) * progress;

    // Opacity decreases as the wave expands (1 → 0)
    final double opacity = (1 - progress).clamp(0.0, 1.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          // Border becomes more transparent as the circle grows
          color: Colors.grey.withOpacity(opacity * 0.5),
          width: 3,
        ),
      ),
    );
  }

  Widget _buildWaves() {
    return AnimatedBuilder(
      animation: _micController,
      builder: (context, child) {
        double progress = _micController.value;

        return Stack(
          alignment: Alignment.center,
          children: [
            _wave(progress),
            _wave((progress + 0.33) % 1),
            _wave((progress + 0.66) % 1),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// Nút X (góc trên trái)
          Positioned(
            top: 55,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.close, size: 28, color: Colors.grey[700]),
            ),
          ),

          /// Text "Bạn nói đi..."
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            child: Text(
              (!_finishedListening && _recognizedText.isEmpty)
                  ? AppLocalizations.of(context)!.let_say
                  : (_recognizedText.isEmpty ? "…" : _recognizedText),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey[700],
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          /// Mic ở dưới cùng
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Center(
              child: SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    /// Sóng âm lan ra
                    _buildWaves(),

                    /// Nút mic vàng, nền xanh
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF20A6FF), // nền xanh
                      ),
                      child: const Icon(Icons.mic,
                          color: Color(0xFFFFFF45), // icon vàng
                          size: 38),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
