import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/house_model.dart';
import '../../data/house_repository.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/location_picker_map.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class EditHouseScreen extends StatefulWidget {
  final HouseModel house;
  const EditHouseScreen({super.key, required this.house});

  @override
  State<EditHouseScreen> createState() => _EditHouseScreenState();
}

class _EditHouseScreenState extends State<EditHouseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _kodeController;
  late TextEditingController _nomorController;
  late TextEditingController _namaController;
  late TextEditingController _rtController;
  late TextEditingController _rwController;
  late TextEditingController _alamatController;
  LatLng? _selectedLocation;
  Uint8List? _fotoBytes;
  String? _fotoFileName;
  String? _existingFotoUrl;
  late bool _aktif;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _kodeController = TextEditingController(text: widget.house.kodeRumah);
    _nomorController = TextEditingController(text: widget.house.nomorRumah);
    _namaController = TextEditingController(text: widget.house.nama);
    _rtController = TextEditingController(text: widget.house.rt);
    _rwController = TextEditingController(text: widget.house.rw);
    _alamatController = TextEditingController(text: widget.house.alamatTambahan);
    if (widget.house.latitude != null && widget.house.longitude != null) {
      _selectedLocation = LatLng(widget.house.latitude!, widget.house.longitude!);
    }
    _existingFotoUrl = widget.house.fotoRumah;
    _aktif = widget.house.aktif;
  }

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _fotoBytes = bytes;
          _fotoFileName = image.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e'), backgroundColor: Colors.red),
        );
      }
    }
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

      String? uploadedFotoUrl = _existingFotoUrl;
      if (_fotoBytes != null && _fotoFileName != null) {
        uploadedFotoUrl = await repo.uploadHousePhoto(_fotoBytes!, _fotoFileName!);
      }

      final updatedHouse = HouseModel(
        id: widget.house.id,
        kodeRumah: _kodeController.text.trim().toUpperCase(),
        nomorRumah: _nomorController.text.trim(),
        nama: _namaController.text.trim(),
        rt: _rtController.text.trim().padLeft(2, '0'),
        rw: _rwController.text.trim().padLeft(2, '0'),
        alamatTambahan: _alamatController.text.trim(),
        fotoRumah: uploadedFotoUrl,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        aktif: _aktif,
        createdAt: widget.house.createdAt,
      );
      
      await repo.updateHouse(widget.house.id, updatedHouse);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data rumah berhasil diperbarui'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui: $e'), backgroundColor: Colors.red),
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
        title: const Text('Edit Rumah'),
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
                      Text('Ubah Data Rumah', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
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
                      const SizedBox(height: 24),
                      Text(
                        'Foto Rumah (Opsional)',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            image: _fotoBytes != null
                                ? DecorationImage(
                                    image: MemoryImage(_fotoBytes!),
                                    fit: BoxFit.cover,
                                  )
                                : (_existingFotoUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(_existingFotoUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                          ),
                          child: (_fotoBytes == null && _existingFotoUrl == null)
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Tap untuk mengubah foto rumah', style: TextStyle(color: Colors.grey)),
                                  ],
                                )
                              : null,
                        ),
                      ),
                      if (_fotoBytes != null || _existingFotoUrl != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _fotoBytes = null;
                                _existingFotoUrl = null;
                              });
                            },
                            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                            label: const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Text(
                        'Pilih Lokasi Rumah pada Peta (Wajib)',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      const SizedBox(height: 12),
                      LocationPickerMap(
                        initialLocation: _selectedLocation,
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
                            : const Text('Simpan Perubahan'),
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
