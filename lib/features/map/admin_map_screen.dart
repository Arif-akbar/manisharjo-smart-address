import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/house_repository.dart';
import '../../data/house_model.dart';

class AdminMapScreen extends StatefulWidget {
  const AdminMapScreen({super.key});

  @override
  State<AdminMapScreen> createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends State<AdminMapScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HouseRepository>(context, listen: false).fetchHouses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Digital Desa (Admin)'),
      ),
      body: Consumer<HouseRepository>(
        builder: (context, repo, child) {
          if (repo.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final housesWithLocation = repo.houses.where((h) => h.latitude != null && h.longitude != null).toList();

          if (housesWithLocation.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Belum ada data rumah dengan koordinat lokasi.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/admin'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C81), foregroundColor: Colors.white),
                    child: const Text('Kembali ke Dashboard'),
                  ),
                ],
              ),
            );
          }

          double sumLat = 0;
          double sumLng = 0;
          for (var h in housesWithLocation) {
            sumLat += h.latitude!;
            sumLng += h.longitude!;
          }
          final center = LatLng(sumLat / housesWithLocation.length, sumLng / housesWithLocation.length);

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.manisharjo.smart_address',
              ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(50),
                  maxZoom: 15,
                  markers: housesWithLocation.map((house) {
                    return Marker(
                      point: LatLng(house.latitude!, house.longitude!),
                      width: 50,
                      height: 50,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) => _buildHouseInfoCard(context, house),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                house.nomorRumah,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  builder: (context, markers) {
                    final theme = Theme.of(context);
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: theme.colorScheme.primary,
                        border: Border.all(color: theme.colorScheme.surface, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          markers.length.toString(),
                          style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHouseInfoCard(BuildContext context, HouseModel house) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  house.nama,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: house.aktif ? const Color(0xFF22C55E).withValues(alpha: 0.1) : const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  house.aktif ? 'Aktif' : 'Kosong',
                  style: TextStyle(
                    color: house.aktif ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Kode: ${house.kodeRumah}',
            style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.home, color: theme.iconTheme.color, size: 20),
              const SizedBox(width: 8),
              Text('Nomor: ${house.nomorRumah}', style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.map, color: theme.iconTheme.color, size: 20),
              const SizedBox(width: 8),
              Text('RT ${house.rt} / RW ${house.rw}', style: const TextStyle(fontSize: 16)),
            ],
          ),
          if (house.alamatTambahan != null && house.alamatTambahan!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: theme.iconTheme.color, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(house.alamatTambahan!, style: const TextStyle(fontSize: 16))),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pop(context); // Close bottom sheet
                    context.push('/edit-house', extra: house); // Navigate to edit
                  },
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.visibility),
                  onPressed: () {
                    Navigator.pop(context); // Close bottom sheet
                    context.push('/detail-house', extra: house); // Navigate to admin detail
                  },
                  label: const Text('Detail'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
