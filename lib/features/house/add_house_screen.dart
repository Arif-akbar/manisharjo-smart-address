import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/house_model.dart';
import '../../data/house_repository.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/location_picker_map.dart';

class AddHouseScreen extends StatefulWidget {
  const AddHouseScreen({super.key});

  @override
  State<AddHouseScreen> createState() => _AddHouseScreenState();
}

class _AddHouseScreenState extends State<AddHouseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kodeController = TextEditingController();
  final _nomorController = TextEditingController();
  final _namaController = TextEditingController();
  final _rtController = TextEditingController();
  final _rwController = TextEditingController();
  final _alamatController = TextEditingController();
  LatLng? _selectedLocation;
  bool _aktif = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _kodeController.dispose();
    _nomorController.dispose();
    _namaController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi pada peta wajib dipilih!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = Provider.of<HouseRepository>(context, listen: false);
      final newHouse = HouseModel(
        id: '', // Id is auto generated in DB
        kodeRumah: _kodeController.text.trim(),
        nomorRumah: _nomorController.text.trim(),
        nama: _namaController.text.trim(),
        rt: _rtController.text.trim(),
        rw: _rwController.text.trim(),
        alamatTambahan: _alamatController.text.trim(),
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        aktif: _aktif,
        createdAt: DateTime.now(), // Will be ignored by DB if default is set
      );
      
      await repo.addHouse(newHouse);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data rumah berhasil ditambahkan'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Rumah'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Informasi Rumah', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _kodeController,
                              decoration: const InputDecoration(labelText: 'Kode Rumah', prefixIcon: Icon(Icons.code)),
                              validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _nomorController,
                              decoration: const InputDecoration(labelText: 'Nomor Rumah', prefixIcon: Icon(Icons.numbers)),
                              validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _namaController,
                        decoration: const InputDecoration(labelText: 'Nama Pemilik / Penghuni', prefixIcon: Icon(Icons.person)),
                        validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _rtController,
                              decoration: const InputDecoration(labelText: 'RT', prefixIcon: Icon(Icons.map)),
                              validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _rwController,
                              decoration: const InputDecoration(labelText: 'RW', prefixIcon: Icon(Icons.map)),
                              validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _alamatController,
                        decoration: const InputDecoration(labelText: 'Alamat Tambahan (Opsional)', prefixIcon: Icon(Icons.location_on)),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pilih Lokasi Rumah pada Peta (Wajib)',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      const SizedBox(height: 12),
                      LocationPickerMap(
                        onLocationSelected: (location) {
                          setState(() {
                            _selectedLocation = location;
                          });
                        },
                      ),
                      if (_selectedLocation != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Koordinat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold),
                          ),
                        ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Status Aktif'),
                        subtitle: const Text('Rumah dihuni dan aktif dalam sistem'),
                        value: _aktif,
                        onChanged: (val) => setState(() => _aktif = val),
                        activeThumbColor: const Color(0xFF22C55E),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          child: _isSaving 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Simpan Data'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
