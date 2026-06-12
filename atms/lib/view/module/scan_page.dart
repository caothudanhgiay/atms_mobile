import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// Scan barcode
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanCompleted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Scan barcode
  ///
  /// Params: BarcodeCapture[capture]
  ///
  /// Return type[void]
  void _onDetect(BarcodeCapture capture) async {
    if (_isScanCompleted) return;

    final barcode = capture.barcodes.first.rawValue;
    if (barcode != null && barcode.isNotEmpty) {
      _isScanCompleted = true;

      // stop camera to avoid black screen
      await _controller.stop();

      // back page
      if (mounted) {
        Navigator.pop(context, barcode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR/Barcode"),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
      ),
    );
  }
}
