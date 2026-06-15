// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
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
          eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF000000)),
          dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF000000)),
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

  static Future<void> printQrSticker(String url, String kodeRumah, String nama, String nomorRumah) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: url,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      if (qrValidationResult.status == QrValidationStatus.valid) {
        final painter = QrPainter.withQr(
          qr: qrValidationResult.qrCode!,
          eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF000000)),
          dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF000000)),
          gapless: true,
        );
        final picData = await painter.toImageData(1024, format: ui.ImageByteFormat.png);
        if (picData != null) {
          final bytes = picData.buffer.asUint8List();
          final base64String = base64Encode(bytes);
          final dataUrl = 'data:image/png;base64,$base64String';
          
          final printWindow = html.window.open('', 'Print QR');
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
                    font-family: 'Inter', Arial, sans-serif;
                    background-color: #f8f9fa;
                  }
                  .sticker {
                    width: 10cm;
                    height: 14cm;
                    border: 2px solid #0F4C81;
                    border-radius: 16px;
                    padding: 1cm;
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    justify-content: flex-start;
                    text-align: center;
                    box-sizing: border-box;
                    background-color: #ffffff;
                  }
                  .header {
                    font-size: 18pt;
                    font-weight: 800;
                    color: #0F4C81;
                    margin-bottom: 0.2cm;
                    text-transform: uppercase;
                    letter-spacing: 1px;
                  }
                  .sub-header {
                    font-size: 12pt;
                    color: #5C6470;
                    margin-bottom: 1cm;
                    font-weight: 500;
                  }
                  img {
                    width: 7cm;
                    height: 7cm;
                    margin-bottom: 1cm;
                    padding: 0.5cm;
                    border: 1px dashed #ccc;
                    border-radius: 8px;
                  }
                  .info-container {
                    width: 100%;
                    border-top: 1px solid #E4E7EC;
                    padding-top: 0.8cm;
                  }
                  .info-label {
                    font-size: 10pt;
                    color: #5C6470;
                    margin: 0;
                    text-transform: uppercase;
                  }
                  .info-value {
                    font-size: 16pt;
                    font-weight: bold;
                    color: #1A1A1A;
                    margin: 0 0 0.5cm 0;
                  }
                  .footer {
                    margin-top: auto;
                    font-size: 9pt;
                    color: #A0AABF;
                  }
                  @media print {
                    body { background-color: #ffffff; }
                    .sticker { border: 2px solid #000; border-radius: 0; }
                  }
                </style>
              </head>
              <body>
                <div class="sticker">
                  <div class="header">DESA MANISHARJO</div>
                  <div class="sub-header">SMART ADDRESS SYSTEM</div>
                  
                  <img src="$dataUrl" alt="QR Code" />
                  
                  <div class="info-container">
                    <p class="info-label">NAMA WARGA</p>
                    <p class="info-value">$nama</p>
                    
                    <p class="info-label">NOMOR RUMAH</p>
                    <p class="info-value">$nomorRumah</p>
                  </div>
                  
                  <div class="footer">ID: $kodeRumah</div>
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ]
              ),
              child: QrImageView(
                data: url,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(url, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 0.5), textAlign: TextAlign.center),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
