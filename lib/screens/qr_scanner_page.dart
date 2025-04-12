import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String? qrCode;
  bool hasPermission = false;
  bool showQRScanner = true; // Pour basculer entre QR scanner et AR scanner
  MobileScannerController controller = MobileScannerController();

  // AR managers
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;
  ARLocationManager? arLocationManager;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final cameraStatus = await Permission.camera.request();
    setState(() {
      hasPermission = cameraStatus.isGranted;
    });
  }

  // Méthode pour basculer vers la vue AR
  void _openARScanner() {
    setState(() {
      showQRScanner = false;
    });
  }

  // Méthode pour revenir au scanner QR
  void _openQRScanner() {
    setState(() {
      showQRScanner = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showQRScanner ? 'Scanner QR Code' : 'Scanner AR'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: hasPermission
                ? showQRScanner
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
                : ARView(
              onARViewCreated: onARViewCreated,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  showQRScanner && qrCode != null
                      ? Column(
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
                      : showQRScanner
                      ? const Text('Scannez un code QR')
                      : const Text('Utilisez la caméra pour la réalité augmentée'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _openQRScanner,
                        icon: const Icon(Icons.qr_code),
                        label: const Text('QR Scanner'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: showQRScanner ? Colors.blue : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: _openARScanner,
                        icon: const Icon(Icons.view_in_ar),
                        label: const Text('AR Scanner'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !showQRScanner ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;
    this.arLocationManager = arLocationManager;

    this.arSessionManager!.onInitialize(
      showFeaturePoints: true,
      showPlanes: true,
      customPlaneTexturePath: "assets/triangle.png",
      showWorldOrigin: true,
    );
    this.arObjectManager!.onInitialize();
  }

  @override
  void dispose() {
    controller.dispose();
    arSessionManager?.dispose();
    super.dispose();
  }
}