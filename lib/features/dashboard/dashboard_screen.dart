import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/auth_repository.dart';
import '../../data/house_model.dart';
import '../../data/house_repository.dart';
import 'qr_village_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh data when dashboard is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HouseRepository>(context, listen: false).fetchHouses();
    });
  }

  Future<void> _confirmDelete(BuildContext context, HouseModel house) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Rumah'),
          content: Text('Apakah Anda yakin ingin menghapus data rumah ${house.nama} (${house.kodeRumah})?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      try {
        await Provider.of<HouseRepository>(context, listen: false).deleteHouse(house.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil dihapus'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Rumah Manisharjo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            tooltip: 'QR Code Desa',
            onPressed: () {
              showDialog(context: context, builder: (_) => const QrVillageDialog());
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Cari Warga/Rumah',
            onPressed: () {
              context.push('/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang',
            onPressed: () {
              Provider.of<HouseRepository>(context, listen: false).fetchHouses();
            },
          ),
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Kelola Denah Desa',
            onPressed: () {
              context.push('/admin-map');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () async {
              final authRepo = Provider.of<AuthRepository>(context, listen: false);
              await authRepo.logout();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-house'),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Rumah'),
        backgroundColor: const Color(0xFF0F4C81),
        foregroundColor: Colors.white,
      ),
      body: Consumer<HouseRepository>(
        builder: (context, repository, child) {
          if (repository.isLoading && repository.houses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (repository.errorMessage != null && repository.houses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(repository.errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => repository.fetchHouses(),
                    child: const Text('Coba Lagi'),
                  )
                ],
              ),
            );
          }

          if (repository.houses.isEmpty) {
            return const Center(
              child: Text('Belum ada data rumah.'),
            );
          }

          final houses = repository.houses;
          final totalRT = houses.map((h) => h.rt).where((rt) => rt.isNotEmpty).toSet().length;
          final totalRW = houses.map((h) => h.rw).where((rw) => rw.isNotEmpty).toSet().length;
          final belumLengkap = houses.where((h) => h.latitude == null || h.longitude == null).length;
          final lokasiLengkap = houses.length - belumLengkap;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Dashboard Statistik', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF0F4C81))),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.start,
                      children: [
                        _buildStatCard('Total Rumah', '${houses.length}', Icons.home_work, const Color(0xFF2980B9)),
                        _buildStatCard('Total RT', '$totalRT', Icons.map, const Color(0xFFE67E22)),
                        _buildStatCard('Total RW', '$totalRW', Icons.map_outlined, const Color(0xFFD35400)),
                        _buildStatCard('Rumah Aktif', '${repository.activeHouses}', Icons.check_circle, const Color(0xFF27AE60)),
                        _buildStatCard('Belum Lengkap', '$belumLengkap', Icons.location_off, const Color(0xFFE74C3C)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Progress Pemetaan Lokasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade800)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text('$lokasiLengkap Lengkap', style: const TextStyle(color: Color(0xFF27AE60), fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Text('$belumLengkap Belum', style: const TextStyle(color: Color(0xFFE74C3C), fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: houses.isEmpty ? 0 : lokasiLengkap / houses.length,
                                minHeight: 12,
                                backgroundColor: const Color(0xFFFADBD8), // Soft red background
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF27AE60)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text('Daftar Rumah', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF0F4C81))),
                    const SizedBox(height: 16),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey.shade100),
                            columns: const [
                              DataColumn(label: Text('Kode', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('No. Rumah', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Pemilik / Penghuni', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('RT/RW', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: repository.houses.map((house) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(house.kodeRumah)),
                                  DataCell(Text(house.nomorRumah)),
                                  DataCell(Text(house.nama)),
                                  DataCell(Text('${house.rt}/${house.rw}')),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: house.aktif ? Colors.green.shade100 : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        house.aktif ? 'Aktif' : 'Tidak Aktif',
                                        style: TextStyle(
                                          color: house.aktif ? Colors.green.shade800 : Colors.red.shade800,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.visibility, color: Colors.teal),
                                          tooltip: 'Detail',
                                          onPressed: () => context.push('/detail-house', extra: house),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          tooltip: 'Edit',
                                          onPressed: () => context.push('/edit-house', extra: house),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          tooltip: 'Hapus',
                                          onPressed: () => _confirmDelete(context, house),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
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