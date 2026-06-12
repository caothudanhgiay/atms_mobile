import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loadweb/Util/common_util.dart';
import 'package:loadweb/config/constants.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../config/images.dart';
import '../../l10n/app_localizations.dart';

class VoiceTextPage extends StatefulWidget {
  const VoiceTextPage(this.textFromJs, {super.key});
  final String textFromJs;

  @override
  State<VoiceTextPage> createState() => _VoiceTextPageState();
}

class _VoiceTextPageState extends State<VoiceTextPage> with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  late TextEditingController _textController;
  late AnimationController _micController;

  bool _isListening = false;
  String _lastRecognized = "";
  String localeLang = Constants.LANG_VOICE_DEFAULT;

  Timer? _silenceTimer;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _textController = TextEditingController();
    _micController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    if (widget.textFromJs.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _textController.text = widget.textFromJs;
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: widget.textFromJs.length),
        );
      });
    }

    _initSpeech();
  }

  Future<void> _initSpeech() async {
    localeLang = await CommonUtil.getLocale();

    final available = await _speech.initialize(
      onError: (e) => debugPrint("Speech error: $e"),
      onStatus: (status) => debugPrint("Speech status: $status"),
    );

    if (!mounted) return;

    if (available) {
      setState(() {});
      // await _startListening(); // bật mic mặc định khi mở dialog
    } else {
      debugPrint("❌ Speech not available");
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    String localeVoice = await CommonUtil.getLocaleVoice();

    if (_speech.isListening) {
      await _speech.stop();
    }

    _lastRecognized = ""; // RESET trước mỗi lần listen

    setState(() => _isListening = true);
    _micController.repeat(reverse: true);

    await _speech.listen(
      localeId: localeVoice,
      listenMode: stt.ListenMode.search,
      onResult: (result) async {
        if (!mounted) return;

        // Reset silence timer mỗi khi có data
        _silenceTimer?.cancel();
        _silenceTimer = Timer(const Duration(seconds: 1), () {
          if (mounted && _isListening) {
            _stopListening(); // Tự tắt mic sau 1 giây im lặng
          }
        });

        final text = result.recognizedWords.trim();
        if (text.isNotEmpty && text != _lastRecognized) {
          final diff = text.replaceFirst(_lastRecognized, "").trim();
          if (diff.isNotEmpty) _insertAtCursor(diff);
          _lastRecognized = text;
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    _silenceTimer?.cancel(); // stop timer
    _micController.stop();
    _micController.reset();
    setState(() => _isListening = false);
  }

  void _insertAtCursor(String newText) {
    final currentText = _textController.text;
    final selection = _textController.selection;
    final pos = selection.isValid ? selection.baseOffset : currentText.length;
    final updated = currentText.replaceRange(pos, pos, "$newText ");
    _textController.text = updated;
    _textController.selection = TextSelection.fromPosition(TextPosition(offset: pos + newText.length + 1));
  }

  void _clearText() => _textController.clear();

  void _submit() => Navigator.pop(context, _textController.text.trim());

  void _handleTapOutside() {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    if (keyboardOpen) {
      // ẩn bàn phím
      FocusScope.of(context).unfocus();
    } else {
      // đóng dialog
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _micController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _handleTapOutside,
          child: Center(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Image.asset(
                            Images.ATMS_ICON_BACK,
                            width: 20,
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.speak_or_type,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 26),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          expands: true,
                          keyboardType: TextInputType.multiline,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.hint_content,
                            contentPadding: const EdgeInsets.all(12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0DCE4),
                                width: 0.7,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0DCE4),
                                width: 0.7,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _toggleListening,
                      child: _isListening
                          ? AnimatedBuilder(
                              animation: _micController,
                              builder: (_, __) => Icon(
                                Icons.mic,
                                size: 55 + (_micController.value * 18),
                                color: Colors.blue,
                              ),
                            )
                          : const Icon(
                              Icons.mic,
                              size: 55,
                              color: Colors.grey,
                            ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _clearText,
                          icon: const Icon(Icons.delete),
                          label: Text(AppLocalizations.of(context)!.btn_delete),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFF0F0),
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF2EAFE),
                            foregroundColor: const Color(0xFF5C3BCE),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(AppLocalizations.of(context)!.btn_ok),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
