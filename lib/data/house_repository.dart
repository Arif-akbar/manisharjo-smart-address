import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'house_model.dart';

class HouseRepository extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final String _tableName = 'houses';
  
  // Specific columns to prevent SELECT *
  final String _selectColumns = 'id, kode_rumah, nomor_rumah, nama, rt, rw, alamat_tambahan, latitude, longitude, aktif, created_at';

  List<HouseModel> _houses = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _totalHouses = 0;
  int _activeHouses = 0;

  List<HouseModel> get houses => _houses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalHouses => _totalHouses;
  int get activeHouses => _activeHouses;

  HouseRepository() {
    fetchHouses();
  }

  Future<void> fetchHouses({bool forceRefresh = false}) async {
    if (!forceRefresh && _houses.isNotEmpty) return; // Cached locally

    _setLoading(true);
    try {
      final response = await _supabase
          .from(_tableName)
          .select(_selectColumns)
          .order('created_at', ascending: false);
          
      _houses = (response as List).map((e) => HouseModel.fromJson(e)).toList();
      _totalHouses = _houses.length;
      _activeHouses = _houses.where((h) => h.aktif).length;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<HouseModel?> getHouseByKode(String kode) async {
    // Try to get from local cache first
    try {
      final localHouse = _houses.firstWhere((h) => h.kodeRumah == kode);
      return localHouse;
    } catch (_) {
      // Not found in cache, fetch from network
    }

    try {
      final response = await _supabase
          .from(_tableName)
          .select(_selectColumns)
          .eq('kode_rumah', kode)
          .maybeSingle();
          
      if (response != null) {
        return HouseModel.fromJson(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> addHouse(HouseModel house) async {
    _setLoading(true);
    try {
      await _supabase.from(_tableName).insert(house.toJson());
      await fetchHouses(forceRefresh: true);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> updateHouse(String id, HouseModel house) async {
    _setLoading(true);
    try {
      await _supabase.from(_tableName).update(house.toJson()).eq('id', id);
      await fetchHouses(forceRefresh: true);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> deleteHouse(String id) async {
    _setLoading(true);
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
      await fetchHouses(forceRefresh: true);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return; // Prevent unnecessary notifyListeners
    _isLoading = value;
    notifyListeners();
  }
}
