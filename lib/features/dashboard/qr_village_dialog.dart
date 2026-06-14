// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:html' as html;

class QrVillageDialog extends StatefulWidget {
  const QrVillageDialog({super.key});

  @override
  State<QrVillageDialog> createState() => _QrVillageDialogState();
}

class _QrVillageDialogState extends State<QrVillageDialog> {
  late String _villageUrl;

  @override
  void initState() {
    super.initState();
    // Use the current origin URL for the QR code
    _villageUrl = Uri.base.origin;
  }

  Future<void> _downloadQrCode() async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: _villageUrl,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode!;
        final painter = QrPainter.withQr(
          qr: qrCode,
          eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF000000)),
          dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF000000)),
          gapless: true,
        );
        
        final picData = await painter.toImageData(2048, format: ui.ImageByteFormat.png);
        if (picData != null) {
          final bytes = picData.buffer.asUint8List();
          final blob = html.Blob([bytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.AnchorElement(href: url)
            ..setAttribute('download', 'qrcode_desa_manisharjo.png')
            ..click();
          html.Url.revokeObjectUrl(url);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('QR Code berhasil diunduh'), backgroundColor: Colors.green),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunduh QR Code: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _copyUrl() {
    Clipboard.setData(ClipboardData(text: _villageUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URL berhasil disalin'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('QR Code Desa', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Scan QR Code ini untuk membuka website desa', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: QrImageView(
              data: _villageUrl,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _villageUrl, 
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton.icon(
          onPressed: _copyUrl,
          icon: const Icon(Icons.copy),
          label: const Text('Copy URL'),
        ),
        ElevatedButton.icon(
          onPressed: _downloadQrCode,
          icon: const Icon(Icons.download),
          label: const Text('Download QR'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F4C81),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
