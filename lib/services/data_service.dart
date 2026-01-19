import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/bible_models.dart';

/// Service class to handle loading and managing Bible and Torrey data
class DataService {
  static DataService? _instance;
  static DataService get instance => _instance ??= DataService._();

  DataService._();

  BibleData? _bibleData;
  TorreyData? _torreyData;
  Map<String, List<int>>? _crossReference;

  bool _isLoading = false;
  bool _isLoaded = false;

  /// Check if data is currently loading
  bool get isLoading => _isLoading;

  /// Check if data has been loaded
  bool get isLoaded => _isLoaded;

  /// Get the Bible data (loads if not already loaded)
  Future<BibleData> getBibleData() async {
    if (_bibleData != null) return _bibleData!;

    await _loadData();
    return _bibleData!;
  }

  /// Get the Torrey data (loads if not already loaded)
  Future<TorreyData> getTorreyData() async {
    if (_torreyData != null) return _torreyData!;

    await _loadData();
    return _torreyData!;
  }

  /// Get the cross-reference data (loads if not already loaded)
  Future<Map<String, List<int>>> getCrossReference() async {
    if (_crossReference != null) return _crossReference!;

    await _loadData();
    return _crossReference!;
  }

  /// Load all data from JSON assets
  Future<void> _loadData() async {
    if (_isLoading || _isLoaded) return;

    _isLoading = true;

    try {
      print('Loading Bible and Torrey data...');

      // Load Bible data
      final bibleJsonString =
          await rootBundle.loadString('assets/data/web_bible_complete.json');
      final bibleJson = json.decode(bibleJsonString) as Map<String, dynamic>;
      _bibleData = BibleData.fromJson(bibleJson);
      print('Loaded ${_bibleData!.books.length} Bible books');

      // Load Torrey data
      final torreyJsonString = await rootBundle
          .loadString('assets/data/torrey_topics_complete.json');
      final torreyJson = json.decode(torreyJsonString) as Map<String, dynamic>;
      _torreyData = TorreyData.fromJson(torreyJson);
      print('Loaded ${_torreyData!.topics.length} Torrey topics');

      // Load cross-reference data
      final crossRefJsonString = await rootBundle
          .loadString('assets/data/torrey_cross_reference.json');
      final crossRefJson =
          json.decode(crossRefJsonString) as Map<String, dynamic>;

      // Convert the cross-reference data to the expected format
      _crossReference = <String, List<int>>{};
      final verseToTopics =
          crossRefJson['verse_to_topics'] as Map<String, dynamic>? ?? {};

      for (final entry in verseToTopics.entries) {
        final verseKey = entry.key;
        final topicIds = (entry.value as List<dynamic>).cast<int>();
        _crossReference![verseKey] = topicIds;
      }

      print('Loaded cross-references for ${_crossReference!.length} verses');

      _isLoaded = true;
      print('All data loaded successfully');
    } catch (e, stackTrace) {
      print('Error loading data: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  /// Force reload all data
  Future<void> reloadData() async {
    _bibleData = null;
    _torreyData = null;
    _crossReference = null;
    _isLoaded = false;

    await _loadData();
  }

  /// Find a specific Bible verse
  Future<Verse?> findVerse(String bookName, int chapter, int verse) async {
    final bibleData = await getBibleData();
    final book = bibleData.findBook(bookName);
    return book?.findVerse(chapter, verse);
  }

  /// Find verses for a verse reference
  Future<List<Verse>> findVerses(VerseReference ref) async {
    final bibleData = await getBibleData();
    final book = bibleData.findBook(ref.book);

    if (book == null) return [];

    final verses = <Verse>[];
    final startChapter = ref.chapter;
    final endChapter = ref.endChapter ?? ref.chapter;
    final startVerse = ref.verse;
    final endVerse = ref.endVerse ?? ref.verse;

    for (int chapterNum = startChapter;
        chapterNum <= endChapter;
        chapterNum++) {
      final chapter = book.chapters.firstWhere(
        (c) => c.chapter == chapterNum,
        orElse: () => Chapter(chapter: 0, verses: []),
      );

      if (chapter.chapter == 0) continue;

      final verseStart = chapterNum == startChapter ? startVerse : 1;
      final verseEnd =
          chapterNum == endChapter ? endVerse : chapter.verses.length;

      for (final verse in chapter.verses) {
        if (verse.verse >= verseStart && verse.verse <= verseEnd) {
          verses.add(verse);
        }
      }
    }

    return verses;
  }

  /// Search Bible verses by text content
  Future<List<({BibleBook book, Chapter chapter, Verse verse})>> searchBible(
      String query) async {
    if (query.length < 3) return [];

    final bibleData = await getBibleData();
    final results = <({BibleBook book, Chapter chapter, Verse verse})>[];
    final lowerQuery = query.toLowerCase();

    for (final book in bibleData.books) {
      for (final chapter in book.chapters) {
        for (final verse in chapter.verses) {
          if (verse.text.toLowerCase().contains(lowerQuery)) {
            results.add((book: book, chapter: chapter, verse: verse));

            // Limit results to avoid performance issues
            if (results.length >= 100) {
              return results;
            }
          }
        }
      }
    }

    return results;
  }

  /// Get topics that reference a specific verse
  Future<List<Topic>> getTopicsForVerse(
      String bookName, int chapter, int verse) async {
    final crossRef = await getCrossReference();
    final torreyData = await getTorreyData();

    final verseKey = '$bookName $chapter:$verse';
    final topicIds = crossRef[verseKey] ?? [];

    final topics = <Topic>[];
    for (final topicId in topicIds) {
      final topic = torreyData.findTopic(topicId);
      if (topic != null) {
        topics.add(topic);
      }
    }

    return topics;
  }

  /// Get app statistics
  Future<Map<String, int>> getStatistics() async {
    final bibleData = await getBibleData();
    final torreyData = await getTorreyData();
    final crossRef = await getCrossReference();

    return {
      'bibleBooks': bibleData.books.length,
      'bibleChapters': bibleData.books
          .fold(0, (total, book) => total + book.chapters.length),
      'bibleVerses': bibleData.totalVerses,
      'torreyTopics': torreyData.topics.length,
      'torreySubtopics': torreyData.topics
          .fold(0, (total, topic) => total + topic.subtopics.length),
      'torreyReferences': torreyData.totalVerses,
      'crossReferences': crossRef.length,
    };
  }
}
