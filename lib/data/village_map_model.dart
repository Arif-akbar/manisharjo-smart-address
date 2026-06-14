class VillageMapModel {
  final int id;
  final String title;
  final String imageUrl;
  final DateTime createdAt;

  VillageMapModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.createdAt,
  });

  factory VillageMapModel.fromJson(Map<String, dynamic> json) {
    return VillageMapModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != 0) 'id': id,
      'title': title,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
