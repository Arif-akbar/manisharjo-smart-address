import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/auth_repository.dart';
import '../../data/house_repository.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HouseRepository>(context, listen: false).fetchHouses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isAuthenticated = Provider.of<AuthRepository>(context).isAuthenticated;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Smart Address Manisharjo', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F4C81),
        elevation: 0,
        actions: [
          if (isAuthenticated)
            TextButton.icon(
              icon: const Icon(Icons.dashboard),
              label: const Text('Dashboard Admin'),
              onPressed: () => context.push('/admin'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF0F4C81)),
            )
          else
            TextButton.icon(
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Login Admin'),
              onPressed: () => context.push('/login'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF0F4C81)),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF0F4C81),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.account_balance, size: 80, color: Colors.white),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Sistem Alamat Digital\nDesa Manisharjo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Kemudahan akses informasi letak geospasial rumah, navigasi, dan data statistik warga yang terintegrasi secara digital.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Mock Search Bar to redirect to Search Screen
                      GestureDetector(
                        onTap: () => context.push('/search'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 16),
                              Text(
                                'Cari nama warga atau nomor rumah...',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F4C81),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Cari',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

            // Statistics Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    children: [
                      Consumer<HouseRepository>(
                        builder: (context, repo, child) {
                          return Wrap(
                            spacing: 24,
                            runSpacing: 24,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildStatCard(
                                context,
                                title: 'Total Rumah Terdaftar',
                                count: repo.isLoading ? '...' : repo.totalHouses.toString(),
                                icon: Icons.home_work_outlined,
                                color: Colors.blue,
                              ),
                              _buildStatCard(
                                context,
                                title: 'Rumah Berpenghuni',
                                count: repo.isLoading ? '...' : repo.activeHouses.toString(),
                                icon: Icons.family_restroom,
                                color: Colors.green,
                              ),
                              _buildStatCard(
                                context,
                                title: 'Cakupan Pemetaan',
                                count: repo.isLoading ? '...' : '${(repo.totalHouses > 0 ? (repo.activeHouses / repo.totalHouses * 100).toInt() : 0)}%',
                                icon: Icons.map_outlined,
                                color: Colors.orange,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 60),
                      // Public Map Button
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F4C81).withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF0F4C81).withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.map, size: 60, color: Color(0xFF0F4C81)),
                            const SizedBox(height: 16),
                            const Text(
                              'Eksplorasi Denah Desa Manisharjo',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F4C81),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Lihat denah lengkap desa dari layar Anda. Fitur zoom interaktif tersedia.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => context.push('/public-map'),
                              icon: const Icon(Icons.fullscreen),
                              label: const Text('Lihat Denah Desa', style: TextStyle(fontSize: 18)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F4C81),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              color: Colors.white,
              child: Column(
                children: [
                  const Text(
                    '© 2026 Pemerintah Desa Manisharjo.',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mewujudkan Desa Digital yang Transparan dan Terintegrasi.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String count, required IconData icon, required MaterialColor color}) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: color.shade700),
          ),
          const SizedBox(height: 24),
          Text(
            count,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: color.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
