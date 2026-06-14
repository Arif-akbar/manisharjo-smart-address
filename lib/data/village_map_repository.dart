import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'village_map_model.dart';

class VillageMapRepository extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final String _tableName = 'village_maps';
  final String _bucketName = 'maps';

  VillageMapModel? _latestMap;
  bool _isLoading = false;
  String? _errorMessage;

  VillageMapModel? get latestMap => _latestMap;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  VillageMapRepository() {
    fetchLatestMap();
  }

  Future<void> fetchLatestMap() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        _latestMap = VillageMapModel.fromJson(response.first);
      } else {
        _latestMap = null;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadMap(String title, Uint8List imageBytes, String fileName) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Upload to storage
      final fileExtension = fileName.split('.').last;
      final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final path = 'village_maps/$uniqueFileName';

      await _supabase.storage.from(_bucketName).uploadBinary(
            path,
            imageBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // 2. Get public URL
      final imageUrl = _supabase.storage.from(_bucketName).getPublicUrl(path);

      // 3. Insert into database
      final newMap = VillageMapModel(
        id: 0,
        title: title,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await _supabase.from(_tableName).insert(newMap.toJson());
      
      // Refresh
      await fetchLatestMap();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteMap(int id, String imageUrl) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Delete from storage
      final pathSegments = Uri.parse(imageUrl).pathSegments;
      // Extract the path after bucket name
      // URL format: .../storage/v1/object/public/maps/village_maps/12345.png
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex != -1 && pathSegments.length > bucketIndex + 1) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _supabase.storage.from(_bucketName).remove([filePath]);
      }

      // 2. Delete from DB
      await _supabase.from(_tableName).delete().eq('id', id);

      // Refresh
      await fetchLatestMap();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
