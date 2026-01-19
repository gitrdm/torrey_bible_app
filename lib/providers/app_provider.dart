import 'package:flutter/foundation.dart';
import '../models/bible_models.dart';
import '../services/data_service.dart';

/// Provider class to manage app state using Provider pattern
class AppProvider extends ChangeNotifier {
  final DataService _dataService = DataService.instance;

  BibleData? _bibleData;
  TorreyData? _torreyData;
  String? _error;
  bool _isLoading = false;

  // Getters
  BibleData? get bibleData => _bibleData;
  TorreyData? get torreyData => _torreyData;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isDataLoaded => _bibleData != null && _torreyData != null;

  /// Load all data
  Future<void> loadData() async {
    if (_isLoading) return;

    _setLoading(true);
    _setError(null);

    try {
      _bibleData = await _dataService.getBibleData();
      _torreyData = await _dataService.getTorreyData();

      debugPrint('Data loaded successfully');
      debugPrint('Bible books: ${_bibleData!.books.length}');
      debugPrint('Torrey topics: ${_torreyData!.topics.length}');
    } catch (e, stackTrace) {
      debugPrint('Error loading data: $e');
      debugPrint('Stack trace: $stackTrace');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Get app statistics
  Future<Map<String, int>> getStatistics() async {
    return await _dataService.getStatistics();
  }

  /// Find a specific Bible verse
  Future<Verse?> findVerse(String bookName, int chapter, int verse) async {
    return await _dataService.findVerse(bookName, chapter, verse);
  }

  /// Find verses for a verse reference
  Future<List<Verse>> findVerses(VerseReference ref) async {
    return await _dataService.findVerses(ref);
  }

  /// Search Bible verses by text content
  Future<List<({BibleBook book, Chapter chapter, Verse verse})>> searchBible(
      String query) async {
    return await _dataService.searchBible(query);
  }

  /// Get topics that reference a specific verse
  Future<List<Topic>> getTopicsForVerse(
      String bookName, int chapter, int verse) async {
    return await _dataService.getTopicsForVerse(bookName, chapter, verse);
  }

  /// Find a specific topic by ID
  Topic? findTopic(int topicId) {
    return _torreyData?.findTopic(topicId);
  }

  /// Find a specific Bible book by name
  BibleBook? findBook(String bookName) {
    return _bibleData?.findBook(bookName);
  }

  /// Reload all data
  Future<void> reloadData() async {
    _bibleData = null;
    _torreyData = null;
    await _dataService.reloadData();
    await loadData();
  }

  /// Private methods to update state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
