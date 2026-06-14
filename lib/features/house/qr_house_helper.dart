import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:html' as html;

class QrHouseHelper {
  static Future<void> downloadQr(BuildContext context, String url, String kodeRumah) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: url,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      if (qrValidationResult.status == QrValidationStatus.valid) {
        final painter = QrPainter.withQr(
          qr: qrValidationResult.qrCode!,
          color: const Color(0xFF000000),
          emptyColor: const Color(0xFFFFFFFF),
          gapless: true,
        );
        final picData = await painter.toImageData(2048, format: ui.ImageByteFormat.png);
        if (picData != null) {
          final bytes = picData.buffer.asUint8List();
          final blob = html.Blob([bytes]);
          final objectUrl = html.Url.createObjectUrlFromBlob(blob);
          html.AnchorElement(href: objectUrl)
            ..setAttribute('download', 'QR_$kodeRumah.png')
            ..click();
          html.Url.revokeObjectUrl(objectUrl);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('QR Code berhasil diunduh'), backgroundColor: Colors.green),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunduh: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  static Future<void> printQrSticker(String url, String kodeRumah, String nama) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: url,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      if (qrValidationResult.status == QrValidationStatus.valid) {
        final painter = QrPainter.withQr(
          qr: qrValidationResult.qrCode!,
          color: const Color(0xFF000000),
          emptyColor: const Color(0xFFFFFFFF),
          gapless: true,
        );
        final picData = await painter.toImageData(1024, format: ui.ImageByteFormat.png);
        if (picData != null) {
          final bytes = picData.buffer.asUint8List();
          final base64String = base64Encode(bytes);
          final dataUrl = 'data:image/png;base64,$base64String';
          
          final printWindow = html.window.open('', 'Print QR');
          if (printWindow != null) {
            final dynamic win = printWindow;
            win.document.write('''
              <html>
                <head>
                  <title>Cetak QR - $kodeRumah</title>
                  <style>
                    body {
                      display: flex;
                      justify-content: center;
                      align-items: center;
                      height: 100vh;
                      margin: 0;
                      font-family: Arial, sans-serif;
                    }
                    .sticker {
                      width: 8cm;
                      height: 8cm;
                      border: 2px dashed #ccc;
                      padding: 1cm;
                      display: flex;
                      flex-direction: column;
                      align-items: center;
                      justify-content: center;
                      text-align: center;
                      box-sizing: border-box;
                    }
                    img {
                      width: 5cm;
                      height: 5cm;
                      margin-bottom: 0.5cm;
                    }
                    .title {
                      font-size: 16pt;
                      font-weight: bold;
                      margin: 0;
                    }
                    .subtitle {
                      font-size: 12pt;
                      color: #555;
                      margin-top: 4px;
                    }
                    @media print {
                      .sticker { border: none; }
                    }
                  </style>
                </head>
                <body>
                  <div class="sticker">
                    <img src="$dataUrl" />
                    <p class="title">SMART ADDRESS</p>
                    <p class="subtitle">Rumah $nama ($kodeRumah)</p>
                  </div>
                  <script>
                    window.onload = function() {
                      setTimeout(function() {
                        window.print();
                        window.close();
                      }, 500);
                    };
                  </script>
                </body>
              </html>
            ''');
            win.document.close();
          }
        }
      }
    } catch (e) {
      // Ignore
    }
  }

  static void showQrDialog(BuildContext context, String url, String kodeRumah) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('QR Code - $kodeRumah', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: QrImageView(
                data: url,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(url, style: const TextStyle(color: Colors.blue), textAlign: TextAlign.center),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
