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
      id: json['id'] as int,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
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
