class HouseModel {
  final int id;
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
      id: json['id'],
      kodeRumah: json['kode_rumah'],
      nomorRumah: json['nomor_rumah'],
      nama: json['nama'],
      rt: json['rt'],
      rw: json['rw'],
      alamatTambahan: json['alamat_tambahan'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      aktif: json['aktif'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
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
