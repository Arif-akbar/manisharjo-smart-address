import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/house_model.dart';
import '../../data/house_repository.dart';
import 'detail_house_screen.dart';

class PublicDetailHouseScreen extends StatefulWidget {
  final String kodeRumah;
  const PublicDetailHouseScreen({super.key, required this.kodeRumah});

  @override
  State<PublicDetailHouseScreen> createState() => _PublicDetailHouseScreenState();
}

class _PublicDetailHouseScreenState extends State<PublicDetailHouseScreen> {
  HouseModel? _house;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHouse();
  }

  Future<void> _fetchHouse() async {
    try {
      final repo = Provider.of<HouseRepository>(context, listen: false);
      final house = await repo.getHouseByKode(widget.kodeRumah);
      if (mounted) {
        setState(() {
          _house = house;
          _isLoading = false;
          if (house == null) {
            _error = 'Data rumah tidak ditemukan.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat data rumah.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null || _house == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Smart Address')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Rumah tidak ditemukan',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return DetailHouseScreen(house: _house!);
  }
}
