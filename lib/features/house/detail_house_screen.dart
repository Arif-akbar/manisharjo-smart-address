import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F4C81).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(Icons.home_work, color: Color(0xFF0F4C81), size: 32),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    house.nama,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0F4C81),
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Status: ${house.aktif ? 'Aktif' : 'Tidak Aktif'}',
                                    style: TextStyle(
                                      color: house.aktif ? Colors.green.shade700 : Colors.red.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        _buildInfoRow(Icons.numbers, 'Nomor Rumah', house.nomorRumah),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.code, 'Kode Rumah', house.kodeRumah),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.map, 'RT / RW', '${house.rt} / ${house.rw}'),
                        if (house.alamatTambahan != null && house.alamatTambahan!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildInfoRow(Icons.location_on, 'Alamat Tambahan', house.alamatTambahan!),
                        ]
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Map Card
                if (house.latitude != null && house.longitude != null)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.map_outlined, color: Color(0xFF0F4C81)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Lokasi Peta',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0F4C81),
                                        ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: _isNavigating ? null : _openGoogleMaps,
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F4C81),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomMapViewer(
                            latitude: house.latitude!,
                            longitude: house.longitude!,
                            markerLabel: house.nama,
                            height: 350,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
