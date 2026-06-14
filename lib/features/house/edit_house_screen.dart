import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/house_model.dart';
import '../../data/house_repository.dart';

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
  late TextEditingController _latController;
  late TextEditingController _longController;
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
    _latController = TextEditingController(text: widget.house.latitude?.toString() ?? '');
    _longController = TextEditingController(text: widget.house.longitude?.toString() ?? '');
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
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final repo = Provider.of<HouseRepository>(context, listen: false);
      final updatedHouse = HouseModel(
        id: widget.house.id,
        kodeRumah: _kodeController.text.trim(),
        nomorRumah: _nomorController.text.trim(),
        nama: _namaController.text.trim(),
        rt: _rtController.text.trim(),
        rw: _rwController.text.trim(),
        alamatTambahan: _alamatController.text.trim(),
        latitude: double.tryParse(_latController.text.trim()),
        longitude: double.tryParse(_longController.text.trim()),
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
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ubah Data Rumah', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: const Color(0xFF0F4C81), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latController,
                              decoration: const InputDecoration(labelText: 'Latitude (Opsional)', prefixIcon: Icon(Icons.location_searching)),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _longController,
                              decoration: const InputDecoration(labelText: 'Longitude (Opsional)', prefixIcon: Icon(Icons.location_searching)),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Status Aktif'),
                        subtitle: const Text('Rumah dihuni dan aktif dalam sistem'),
                        value: _aktif,
                        onChanged: (val) => setState(() => _aktif = val),
                        activeColor: const Color(0xFF0F4C81),
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
