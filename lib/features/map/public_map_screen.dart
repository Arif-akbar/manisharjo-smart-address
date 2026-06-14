import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/village_map_repository.dart';

class PublicMapScreen extends StatelessWidget {
  const PublicMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Denah Desa Manisharjo'),
      ),
      body: Consumer<VillageMapRepository>(
        builder: (context, repo, child) {
          if (repo.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (repo.latestMap == null) {
            return const Center(
              child: Text(
                'Denah desa belum tersedia.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.5,
              maxScale: 5.0,
              child: Image.network(
                repo.latestMap!.imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Text(
                    'Gagal memuat gambar',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gunakan scroll mouse, cubit layar, atau double-tap untuk Zoom In/Out'),
              duration: Duration(seconds: 4),
            ),
          );
        },
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        elevation: 0,
        child: const Icon(Icons.help_outline),
      ),
    );
  }
}
