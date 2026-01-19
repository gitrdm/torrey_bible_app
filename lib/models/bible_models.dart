/// Data models for the Torrey Bible App
/// These models represent the structure of our JSON data
library;

class Verse {
  final int verse;
  final String text;

  Verse({
    required this.verse,
    required this.text,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      verse: json['verse'] as int,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verse': verse,
      'text': text,
    };
  }
}

class Chapter {
  final int chapter;
  final List<Verse> verses;

  Chapter({
    required this.chapter,
    required this.verses,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapter: json['chapter'] as int,
      verses: (json['verses'] as List<dynamic>)
          .map((v) => Verse.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter': chapter,
      'verses': verses.map((v) => v.toJson()).toList(),
    };
  }
}

class BibleBook {
  final String book;
  final String bookCode;
  final List<Chapter> chapters;

  BibleBook({
    required this.book,
    required this.bookCode,
    required this.chapters,
  });

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    return BibleBook(
      book: json['book'] as String,
      bookCode: json['book_code'] as String? ?? '',
      chapters: (json['chapters'] as List<dynamic>)
          .map((c) => Chapter.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book': book,
      'book_code': bookCode,
      'chapters': chapters.map((c) => c.toJson()).toList(),
    };
  }

  /// Get total verse count for this book
  int get totalVerses {
    return chapters.fold(0, (total, chapter) => total + chapter.verses.length);
  }

  /// Find a specific verse by chapter and verse number
  Verse? findVerse(int chapterNum, int verseNum) {
    final chapter = chapters.firstWhere(
      (c) => c.chapter == chapterNum,
      orElse: () => Chapter(chapter: 0, verses: []),
    );

    if (chapter.chapter == 0) return null;

    try {
      return chapter.verses.firstWhere((v) => v.verse == verseNum);
    } catch (e) {
      return null;
    }
  }
}

class BibleData {
  final List<BibleBook> books;

  BibleData({required this.books});

  factory BibleData.fromJson(Map<String, dynamic> json) {
    return BibleData(
      books: (json['books'] as List<dynamic>)
          .map((b) => BibleBook.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'books': books.map((b) => b.toJson()).toList(),
    };
  }

  /// Find a book by name
  BibleBook? findBook(String bookName) {
    try {
      return books.firstWhere(
        (book) => book.book.toLowerCase() == bookName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get total verse count across all books
  int get totalVerses {
    return books.fold(0, (total, book) => total + book.totalVerses);
  }
}

class VerseReference {
  final String book;
  final int chapter;
  final int verse;
  final int? endChapter;
  final int? endVerse;
  final String reference;

  VerseReference({
    required this.book,
    required this.chapter,
    required this.verse,
    this.endChapter,
    this.endVerse,
    required this.reference,
  });

  factory VerseReference.fromJson(Map<String, dynamic> json) {
    return VerseReference(
      book: json['book'] as String,
      chapter: json['chapter'] as int,
      verse: json['verse'] as int,
      endChapter: json['end_chapter'] as int?,
      endVerse: json['end_verse'] as int?,
      reference: json['reference'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'end_chapter': endChapter,
      'end_verse': endVerse,
      'reference': reference,
    };
  }

  /// Get a formatted display string for this reference
  String get displayReference {
    if (endVerse != null && endVerse! > verse) {
      if (endChapter != null && endChapter! > chapter) {
        return '$book $chapter:$verse-$endChapter:$endVerse';
      } else {
        return '$book $chapter:$verse-$endVerse';
      }
    }
    return '$book $chapter:$verse';
  }
}

class Subtopic {
  final int id;
  final String title;
  final List<VerseReference> verses;

  Subtopic({
    required this.id,
    required this.title,
    required this.verses,
  });

  factory Subtopic.fromJson(Map<String, dynamic> json) {
    return Subtopic(
      id: json['id'] as int,
      title: json['title'] as String,
      verses: (json['verses'] as List<dynamic>)
          .map((v) => VerseReference.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'verses': verses.map((v) => v.toJson()).toList(),
    };
  }
}

class Topic {
  final int id;
  final String title;
  final List<Subtopic> subtopics;

  Topic({
    required this.id,
    required this.title,
    required this.subtopics,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as int,
      title: json['title'] as String,
      subtopics: (json['subtopics'] as List<dynamic>)
          .map((s) => Subtopic.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtopics': subtopics.map((s) => s.toJson()).toList(),
    };
  }

  /// Get total verse count for this topic
  int get totalVerses {
    return subtopics.fold(
        0, (total, subtopic) => total + subtopic.verses.length);
  }
}

class TorreyData {
  final String title;
  final String description;
  final List<Topic> topics;

  TorreyData({
    required this.title,
    required this.description,
    required this.topics,
  });

  factory TorreyData.fromJson(Map<String, dynamic> json) {
    return TorreyData(
      title: json['title'] as String,
      description: json['description'] as String,
      topics: (json['topics'] as List<dynamic>)
          .map((t) => Topic.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'topics': topics.map((t) => t.toJson()).toList(),
    };
  }

  /// Find a topic by ID
  Topic? findTopic(int topicId) {
    try {
      return topics.firstWhere((topic) => topic.id == topicId);
    } catch (e) {
      return null;
    }
  }

  /// Search topics by title
  List<Topic> searchTopics(String query) {
    if (query.isEmpty) return topics;

    final lowerQuery = query.toLowerCase();
    return topics
        .where((topic) => topic.title.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get total verse count across all topics
  int get totalVerses {
    return topics.fold(0, (total, topic) => total + topic.totalVerses);
  }
}
