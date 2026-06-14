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

  void search(String query, List<HouseModel> allHouses) {
    _currentQuery = query;
    
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    if (query.isEmpty) {
      _searchResults = [];
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSmartSearch(query, allHouses);
    });
  }

  void _performSmartSearch(String query, List<HouseModel> allHouses) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = <_SearchResult>[];
      final searchTerms = query.toLowerCase().split(RegExp(r'\s+'));

      for (var house in allHouses) {
        double score = 0;
        final nama = house.nama.toLowerCase();
        final no = house.nomorRumah.toLowerCase();
        
        // Exact match
        if (nama == query.toLowerCase() || no == query.toLowerCase()) {
          score += 100;
        }

        // Substring match
        if (nama.contains(query.toLowerCase())) {
          score += 50;
        }
        if (no.contains(query.toLowerCase())) {
          score += 50;
        }

        // Partial & Typo tolerance on each term
        for (var term in searchTerms) {
          if (term.length < 2) continue;
          
          final words = nama.split(RegExp(r'\s+'));
          for (var word in words) {
            if (word.contains(term)) {
              score += 30; // Partial match inside a word
            } else {
              final dist = _levenshtein(term, word);
              if (dist <= 1 && term.length >= 3) {
                score += 20; // 1 typo allowed for >= 3 chars
              } else if (dist <= 2 && term.length >= 5) {
                score += 10; // 2 typos allowed for >= 5 chars
              }
            }
          }
        }

        if (score > 0) {
          results.add(_SearchResult(house, score));
        }
      }

      // Rank by score descending
      results.sort((a, b) => b.score.compareTo(a.score));

      _searchResults = results.take(20).map((e) => e.house).toList();
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat mencari: $e';
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.generate(t.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce((a, b) => a < b ? a : b);
      }
      for (int j = 0; j <= t.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[t.length];
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

class _SearchResult {
  final HouseModel house;
  final double score;
  _SearchResult(this.house, this.score);
}
