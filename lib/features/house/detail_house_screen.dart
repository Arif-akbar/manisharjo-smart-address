import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/auth_repository.dart';
import '../../data/house_model.dart';
import '../../widgets/custom_map_viewer.dart';

class DetailHouseScreen extends StatefulWidget {
  final HouseModel house;

  const DetailHouseScreen({super.key, required this.house});

  @override
  State<DetailHouseScreen> createState() => _DetailHouseScreenState();
}

class _DetailHouseScreenState extends State<DetailHouseScreen> {
  bool _isNavigating = false;

  Future<void> _openGoogleMaps() async {
    final lat = widget.house.latitude;
    final lng = widget.house.longitude;

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Koordinat lokasi tidak valid!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    final urlString = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final Uri url = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka Google Maps'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final house = widget.house;

    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Rumah'),
        actions: [
          Consumer<AuthRepository>(
            builder: (context, auth, child) {
              if (auth.isAuthenticated) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Rumah',
                  onPressed: () {
                    context.push('/edit-house', extra: house);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Icon(Icons.home_work, color: theme.colorScheme.primary, size: 32),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    house.nama,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: house.aktif ? const Color(0xFF22C55E).withValues(alpha: 0.1) : const Color(0xFFEF4444).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      house.aktif ? 'Status: Aktif' : 'Status: Tidak Aktif',
                                      style: TextStyle(
                                        color: house.aktif ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final bool isSmallScreen = constraints.maxWidth < 450;
                            final double itemWidth = isSmallScreen ? double.infinity : (constraints.maxWidth - 24) / 2;
                            return Wrap(
                              spacing: 24,
                              runSpacing: 20,
                              children: [
                                SizedBox(
                                  width: itemWidth,
                                  child: _buildInfoRow(context, Icons.numbers, 'Nomor Rumah', house.nomorRumah),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: _buildInfoRow(context, Icons.code, 'Kode Rumah', house.kodeRumah),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: _buildInfoRow(context, Icons.map, 'RT / RW', 'RT ${house.rt.toString().padLeft(2, '0')} / RW ${house.rw.toString().padLeft(2, '0')}'),
                                ),
                                if (house.alamatTambahan != null && house.alamatTambahan!.isNotEmpty)
                                  SizedBox(
                                    width: itemWidth,
                                    child: _buildInfoRow(context, Icons.location_on, 'Alamat Tambahan', house.alamatTambahan!),
                                  ),
                              ],
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Map Card
                if (house.latitude != null && house.longitude != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.map_outlined, color: theme.colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Lokasi Peta',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: _isNavigating ? null : _openGoogleMaps,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                icon: _isNavigating
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.navigation),
                                label: const Text('Arahkan ke Lokasi'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          CustomMapViewer(
                            latitude: house.latitude!,
                            longitude: house.longitude!,
                            markerLabel: house.nama,
                            height: 300,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    elevation: 0,
                    color: Colors.orange.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.orange.shade200),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Icon(Icons.location_off, color: Colors.orange),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Koordinat lokasi (Latitude/Longitude) belum diatur untuk rumah ini. Edit rumah untuk menambahkan koordinat.',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                
                // Foto Rumah Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.photo_camera, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Foto Rumah',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Gunakan foto di bawah ini untuk memastikan bentuk fisik rumah atau lokasi yang dituju.'),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: 250,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.dividerColor),
                            image: house.fotoRumah != null && house.fotoRumah!.isNotEmpty
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(house.fotoRumah!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (house.fotoRumah == null || house.fotoRumah!.isEmpty)
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image_not_supported, size: 64, color: theme.unselectedWidgetColor),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Belum ada foto rumah yang diunggah.',
                                        style: TextStyle(color: theme.unselectedWidgetColor, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Theme.of(context).iconTheme.color),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
