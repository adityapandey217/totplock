import 'package:image_picker/image_picker.dart';
import 'package:totplock/providers/totp_provider.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class QrCodeScannerScreen extends StatefulWidget {
  const QrCodeScannerScreen({super.key});

  @override
  State<QrCodeScannerScreen> createState() => _QrCodeScannerScreenState();
}

class _QrCodeScannerScreenState extends State<QrCodeScannerScreen> {
  Barcode? _barcode;
  bool _isScanning = true;
  final MobileScannerController _controller = MobileScannerController();

  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted) {
      setState(() {
        _barcode = barcodes.barcodes.firstOrNull;
        _isScanning = false;
      });
    }
  }

  Future<void> _analyzeImageFromFile() async {

    
    try {

      final XFile? file =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (!mounted) {
        return;
      }

      if (file == null) {
        setState(() {
          _barcode = null;
        });
        return;
      }



      final BarcodeCapture? barcodeCapture =
          await _controller.analyzeImage(file.path);

      if (mounted) {
        setState(() {
          _barcode = barcodeCapture?.barcodes.firstOrNull;
          _isScanning = false;
        });
      }
    } catch (_) {}
  }

  List<Map> _getData(String url) {
    final Uri uri = Uri.parse(url);
    final parts =
        uri.pathSegments.isNotEmpty ? uri.pathSegments.last.split(':') : [];
    final name = parts.length > 1 ? Uri.decodeComponent(parts[1]) : 'Unknown';
    final issuer = uri.queryParameters['issuer'] ?? 'Unknown';
    return [
      {
        'totpUri': url,
        'secret': uri.queryParameters['secret'] ?? '',
        'name': name,
        'issuer': issuer,
      }
    ];
  }

  bool _isValidTotpUri(String uri) {
    try {
      final Uri parsedUri = Uri.parse(uri);
      if (parsedUri.scheme == 'otpauth' && parsedUri.host == 'totp') {
        final String? secret = parsedUri.queryParameters['secret'];
        return secret != null && secret.isNotEmpty;
      }
    } catch (_) {
      return false;
    }
    return false;

  }

  void _resetScanner() {
    setState(() {
      _barcode = null;
      _isScanning = true;
    });
  }

  void _addTotpEntry() {
    final totpProvider = Provider.of<TotpProvider>(context, listen: false);
    final uri = _barcode!.displayValue!;
    bool isDub = totpProvider.checkTotpEntry(uri);
    if (isDub) {
      const snackBar = SnackBar(
        content: Text('This account is already added.'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      _isScanning = true;
      _barcode = null;
      return;
    }
    final parsedUri = Uri.parse(uri);
    final secret = parsedUri.queryParameters['secret'] ?? '';
    totpProvider.addTotpEntry(uri, secret);
    Navigator.pop(context, uri);
  }

  Widget _buildOverlay() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _barcode == null
                ? const Column(
                    children: [
                      Text(
                        'Align QR code within the frame to scan.',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(height: 12),
                      CircularProgressIndicator(
                        color: Colors.white70,
                        strokeWidth: 3,
                      ),
                    ],
                  )
                : _isValidTotpUri(_barcode!.displayValue!)
                    ? Column(
                        children: [
                          const Text(
                            'Scan Successful!',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Name: ${_getData(_barcode!.displayValue!).first['name']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Issuer: ${_getData(_barcode!.displayValue!).first['issuer']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Invalid QR code. Please scan a valid QR code.',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 18,
                        ),
                      ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_barcode != null &&
                    _isValidTotpUri(_barcode!.displayValue!))
                  ElevatedButton.icon(
                    onPressed: () {
                      // final uri = _barcode!.displayValue!;
                      // final parsedUri = Uri.parse(uri);
                      // final secret = parsedUri.queryParameters['secret'] ?? '';
                      // totpProvider.addTotpEntry(uri, secret);
                      // Navigator.pop(context, _barcode!.displayValue);
                      _addTotpEntry();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: Colors.greenAccent.withOpacity(0.4),
                      elevation: 5,
                    ),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      'Use This Code',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                // select image from gallery
                if (_barcode == null)
                  ElevatedButton.icon(
                    onPressed: () {
                          if (kIsWeb) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'This feature is not available on web.',
                                ),
                              ),
                            );

                          } else {
                            _analyzeImageFromFile();
                          }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: Colors.indigoAccent.withOpacity(0.4),
                      elevation: 5,
                    ),
                    icon: const Icon(Icons.image, color: Colors.white),
                    label: const Text(
                      'Select Image',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                ElevatedButton.icon(
                  onPressed: _barcode == null
                      ? () => Navigator.pop(context, "No barcode detected")
                      : _resetScanner,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: Colors.redAccent.withOpacity(0.4),
                    elevation: 5,
                  ),
                  icon: Icon(
                    _barcode == null ? Icons.close : Icons.refresh,
                    color: Colors.white,
                  ),
                  label: Text(
                    _barcode == null ? 'Cancel' : 'Rescan',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _isScanning ? _handleBarcode : null,
          ),
          _buildOverlay(),
        ],
      ),
    );
  }
}
