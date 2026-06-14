class HouseModel {
  final String id;
  final String kodeRumah;
  final String nomorRumah;
  final String nama;
  final String rt;
  final String rw;
  final String? alamatTambahan;
  final double? latitude;
  final double? longitude;
  final bool aktif;
  final DateTime createdAt;

  HouseModel({
    required this.id,
    required this.kodeRumah,
    required this.nomorRumah,
    required this.nama,
    required this.rt,
    required this.rw,
    this.alamatTambahan,
    this.latitude,
    this.longitude,
    required this.aktif,
    required this.createdAt,
  });

  factory HouseModel.fromJson(Map<String, dynamic> json) {
    return HouseModel(
      id: json['id']?.toString() ?? '',
      kodeRumah: json['kode_rumah']?.toString() ?? '',
      nomorRumah: json['nomor_rumah']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      rt: json['rt']?.toString() ?? '',
      rw: json['rw']?.toString() ?? '',
      alamatTambahan: json['alamat_tambahan']?.toString(),
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      aktif: json['aktif'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kode_rumah': kodeRumah,
      'nomor_rumah': nomorRumah,
      'nama': nama,
      'rt': rt,
      'rw': rw,
      'alamat_tambahan': alamatTambahan,
      'latitude': latitude,
      'longitude': longitude,
      'aktif': aktif,
      // 'created_at' and 'id' are managed by Supabase usually
    };
  }
}
