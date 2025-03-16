import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String? qrCode;
  bool hasPermission = false;
  MobileScannerController controller = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      hasPermission = status.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: hasPermission
                ? MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final Barcode barcode = barcodes.first;
                  setState(() {
                    qrCode = barcode.rawValue;
                  });
                }
              },
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Permission de caméra non accordée'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _requestPermission,
                    child: const Text('Demander la permission'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: qrCode != null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Code scanné:'),
                  Text(
                    qrCode!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
                  : const Text('Scannez un code QR'),
            ),
          ),
        ],
      ),
    );
  }
}