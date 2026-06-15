import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const AppErrorWidget({super.key, required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64.0,
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Opps! Terjadi Kesalahan',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Maaf, aplikasi mengalami masalah teknis sementara. Silakan coba muat ulang atau hubungi administrator.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 32.0),
                ElevatedButton.icon(
                  onPressed: () {
                    // Simple refresh attempt - pop the error context or restart depending on routing setup
                    // Since it's a global error widget, we just give a generic action or let them know.
                    Navigator.of(context).maybePop();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Kembali'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C81),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
