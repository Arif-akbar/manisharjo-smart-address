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
  late Widget _cachedQrWidget;

  @override
  void initState() {
    super.initState();
    // Use the current origin URL for the QR code
    _villageUrl = Uri.base.origin;
    // Cache the QR Image View so it is only generated once per session
    _cachedQrWidget = QrImageView(
      data: _villageUrl,
      version: QrVersions.auto,
      size: 200.0,
      backgroundColor: Colors.white,
    );
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
              const SnackBar(content: Text('QR Code berhasil diunduh'), backgroundColor: Color(0xFF22C55E)),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunduh QR Code: $e'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    }
  }

  void _copyUrl() {
    Clipboard.setData(ClipboardData(text: _villageUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URL berhasil disalin'), backgroundColor: Color(0xFF22C55E)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('QR Code Desa', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Scan QR Code ini untuk membuka website desa', 
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.4),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ]
            ),
            // Use the cached QR widget here
            child: _cachedQrWidget,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _villageUrl, 
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 0.5),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 16),
      actions: [
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _copyUrl,
              icon: const Icon(Icons.copy),
              label: const Text('Copy URL'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _downloadQrCode,
              icon: const Icon(Icons.download),
              label: const Text('Download QR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
