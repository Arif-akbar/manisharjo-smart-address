import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../data/village_map_repository.dart';

class AdminMapScreen extends StatefulWidget {
  const AdminMapScreen({super.key});

  @override
  State<AdminMapScreen> createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends State<AdminMapScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadNewMap() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    if (!mounted) return;
    
    // Add title prompt
    String? title = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Nama Denah'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Contoh: Denah Manisharjo 2026'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Upload'),
            ),
          ],
        );
      },
    );

    if (title == null || title.trim().isEmpty) title = 'Denah Desa';

    if (!mounted) return;
    try {
      final bytes = await image.readAsBytes();
      await Provider.of<VillageMapRepository>(context, listen: false)
          .uploadMap(title, bytes, image.name);
          
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Denah berhasil diunggah!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteMap(int id, String imageUrl) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Denah?'),
        content: const Text('Denah ini akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await Provider.of<VillageMapRepository>(context, listen: false).deleteMap(id, imageUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Denah berhasil dihapus!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Denah Desa'),
      ),
      body: Consumer<VillageMapRepository>(
        builder: (context, repo, child) {
          if (repo.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (repo.latestMap == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Belum ada denah desa yang diunggah.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _uploadNewMap,
                    icon: const Icon(Icons.upload),
                    label: const Text('Unggah Denah Pertama'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F4C81),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          final mapData = repo.latestMap!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Denah Aktif',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F4C81),
                                  ),
                                ),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _uploadNewMap,
                                      icon: const Icon(Icons.update),
                                      label: const Text('Ganti Denah'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0F4C81),
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => _deleteMap(mapData.id, mapData.imageUrl),
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                      tooltip: 'Hapus Denah',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 32),
                            Text('Judul: ${mapData.title}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Diupload pada: ${mapData.createdAt.toLocal().toString().split('.')[0]}', style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 24),
                            Container(
                              height: 400,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: InteractiveViewer(
                                  panEnabled: true,
                                  boundaryMargin: const EdgeInsets.all(20),
                                  minScale: 0.5,
                                  maxScale: 4,
                                  child: Image.network(
                                    mapData.imageUrl,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(child: CircularProgressIndicator());
                                    },
                                    errorBuilder: (context, error, stackTrace) => const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error_outline, color: Colors.red, size: 40),
                                          SizedBox(height: 8),
                                          Text('Gagal memuat gambar', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Center(
                              child: Text(
                                'Gunakan scroll mouse atau cubit layar untuk Zoom In / Zoom Out',
                                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
