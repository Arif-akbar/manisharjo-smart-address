import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'house_model.dart';

class SearchProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final String _tableName = 'houses';

  List<HouseModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentQuery = '';

  Timer? _debounceTimer;

  List<HouseModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentQuery => _currentQuery;

  void search(String query) {
    _currentQuery = query;
    
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    if (query.isEmpty) {
      _searchResults = [];
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .or('nama.ilike.%$query%,nomor_rumah.ilike.%$query%')
          .limit(20);

      _searchResults = (response as List).map((e) => HouseModel.fromJson(e)).toList();
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat mencari: $e';
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _currentQuery = '';
    _searchResults = [];
    _isLoading = false;
    _errorMessage = null;
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    notifyListeners();
  }
}
