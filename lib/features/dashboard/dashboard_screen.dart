import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/auth_repository.dart';
import '../../data/house_model.dart';
import '../../data/house_repository.dart';
import 'qr_village_dialog.dart';
import 'dashboard_charts.dart';
import '../../widgets/skeleton_loader.dart';

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
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
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
            const SnackBar(content: Text('Data berhasil dihapus'), backgroundColor: Color(0xFF22C55E)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: const Color(0xFFEF4444)),
          );
        }
      }
    }
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.1);
    final titleColor = isDark ? Colors.grey.shade400 : Theme.of(context).textTheme.bodyMedium?.color;
    final valueColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: titleColor, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: valueColor),
                  ),
                ],
              ),
            ),
          ],
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
            tooltip: 'Lihat Peta Digital',
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
              if (context.mounted) {
                context.go('/');
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-house'),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Rumah'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Consumer<HouseRepository>(
        builder: (context, repository, child) {
          if (repository.isLoading && repository.houses.isEmpty) {
            return const DashboardSkeleton();
          }

          if (repository.errorMessage != null && repository.houses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
                  const SizedBox(height: 16),
                  Text(repository.errorMessage!, style: const TextStyle(color: Color(0xFFEF4444))),
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
                    Text('Dashboard Statistik', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 1;
                        if (constraints.maxWidth >= 1024) {
                          crossAxisCount = 4;
                        } else if (constraints.maxWidth >= 600) {
                          crossAxisCount = 2;
                        }
                        
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          childAspectRatio: constraints.maxWidth >= 1024 ? 2.5 : 2.0,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildStatCard(context, 'Total Rumah', '${houses.length}', Icons.home_work, Theme.of(context).colorScheme.primary),
                            _buildStatCard(context, 'Rumah Aktif', '${repository.activeHouses}', Icons.check_circle, const Color(0xFF22C55E)),
                            _buildStatCard(context, 'Total RT', '$totalRT', Icons.map, const Color(0xFFF59E0B)),
                            _buildStatCard(context, 'Total RW', '$totalRW', Icons.map_outlined, const Color(0xFFEF4444)),
                          ],
                        );
                      }
                    ),
                    const SizedBox(height: 24),
                    
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Progress Pemetaan Lokasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
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
                    const SizedBox(height: 24),
                    DashboardCharts(houses: houses),
                    const SizedBox(height: 32),

                    Text('Daftar Rumah', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.resolveWith((states) => Theme.of(context).colorScheme.surface),
                            dataRowColor: WidgetStateProperty.resolveWith((states) => Theme.of(context).cardTheme.color),
                            dividerThickness: 1,
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
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: house.aktif ? const Color(0xFF22C55E).withValues(alpha: 0.1) : const Color(0xFFEF4444).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          house.aktif ? 'Aktif' : 'Tidak',
                                          style: TextStyle(
                                            color: house.aktif ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
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
                                          icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
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