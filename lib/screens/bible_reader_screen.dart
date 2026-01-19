import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/bible_models.dart';
import '../providers/app_provider.dart';

class BibleReaderScreen extends StatefulWidget {
  final String bookName;
  final int chapter;
  final int? highlightVerse;
  final String? topicTitle;
  final String? subtopicTitle;

  const BibleReaderScreen({
    super.key,
    required this.bookName,
    required this.chapter,
    this.highlightVerse,
    this.topicTitle,
    this.subtopicTitle,
  });

  @override
  State<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends State<BibleReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _highlightKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Scroll to highlighted verse after the widget is built
    if (widget.highlightVerse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToHighlightedVerse();
      });
    }
  }

  void _scrollToHighlightedVerse() {
    if (_highlightKey.currentContext != null) {
      Scrollable.ensureVisible(
        _highlightKey.currentContext!,
        alignment: 0.3,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        // Debug information
        print('BibleReaderScreen: Looking for book "${widget.bookName}"');
        print(
            'BibleReaderScreen: Provider has ${provider.bibleData?.books.length ?? 0} books');
        print('BibleReaderScreen: Provider isLoading: ${provider.isLoading}');

        if (provider.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Loading...'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final book = provider.findBook(widget.bookName);
        print('BibleReaderScreen: Found book: ${book?.book}');

        if (book == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Book Not Found'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                      'The requested book "${widget.bookName}" could not be found.'),
                  const SizedBox(height: 16),
                  Text(
                      'Available books: ${provider.bibleData?.books.length ?? 0}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Back to Topics'),
                  ),
                ],
              ),
            ),
          );
        }

        final chapterData = book.chapters.firstWhere(
          (c) => c.chapter == widget.chapter,
          orElse: () => Chapter(chapter: 0, verses: []),
        );

        print(
            'BibleReaderScreen: Looking for chapter ${widget.chapter} in ${book.book}');
        print('BibleReaderScreen: Book has ${book.chapters.length} chapters');
        print(
            'BibleReaderScreen: Found chapter with ${chapterData.verses.length} verses');

        if (chapterData.chapter == 0) {
          return Scaffold(
            appBar: AppBar(
              title: Text('${widget.bookName} ${widget.chapter}'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                      'Chapter ${widget.chapter} not found in ${widget.bookName}.'),
                  const SizedBox(height: 8),
                  Text(
                      'Available chapters: ${book.chapters.map((c) => c.chapter).join(", ")}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .go('/bible/${Uri.encodeComponent(widget.bookName)}/1'),
                    child: const Text('Go to Chapter 1'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('${widget.bookName} ${widget.chapter}'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              if (widget.topicTitle != null)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'back_to_topics') {
                      context.go('/');
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'back_to_topics',
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back),
                          SizedBox(width: 8),
                          Text('Back to Topics'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: Column(
            children: [
              // Context header if coming from a topic
              if (widget.topicTitle != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.topic,
                            size: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Topic: ${widget.topicTitle}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.subtopicTitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Subtopic: ${widget.subtopicTitle}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer
                                .withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Navigation bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Previous chapter
                    IconButton(
                      onPressed: widget.chapter > 1
                          ? () {
                              context.go(
                                  '/bible/${Uri.encodeComponent(widget.bookName)}/${widget.chapter - 1}');
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      tooltip: 'Previous Chapter',
                    ),

                    // Chapter info
                    Expanded(
                      child: Text(
                        '${book.book} Chapter ${widget.chapter}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    // Next chapter
                    IconButton(
                      onPressed: widget.chapter < book.chapters.length
                          ? () {
                              context.go(
                                  '/bible/${Uri.encodeComponent(widget.bookName)}/${widget.chapter + 1}');
                            }
                          : null,
                      icon: const Icon(Icons.chevron_right),
                      tooltip: 'Next Chapter',
                    ),
                  ],
                ),
              ),

              // Verses
              Expanded(
                child: chapterData.verses.isEmpty
                    ? const Center(
                        child: Text(
                          'No verses found in this chapter',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: chapterData.verses.length,
                        itemBuilder: (context, index) {
                          final verse = chapterData.verses[index];
                          final isHighlighted =
                              widget.highlightVerse == verse.verse;

                          // Debug output for verse rendering
                          if (index < 3) {
                            final previewLength =
                                verse.text.length > 50 ? 50 : verse.text.length;
                            print(
                                'BibleReaderScreen: Rendering verse ${verse.verse}: ${verse.text.substring(0, previewLength)}...');
                          }

                          return VerseWidget(
                            key: isHighlighted ? _highlightKey : null,
                            verse: verse,
                            bookName: widget.bookName,
                            chapter: widget.chapter,
                            isHighlighted: isHighlighted,
                          );
                        },
                      ),
              ),
            ],
          ),

          // Bottom navigation
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Back to Topics button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.home, size: 20),
                    label: const Text('Topics'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Back to Subtopic button (if coming from subtopic)
                if (widget.topicTitle != null &&
                    widget.subtopicTitle != null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Extract topic ID from topic title - this is a workaround
                        // In a real app, you'd pass the topic ID as a parameter
                        final provider =
                            Provider.of<AppProvider>(context, listen: false);
                        final topic = provider.torreyData?.topics.firstWhere(
                          (t) => t.title == widget.topicTitle,
                          orElse: () => Topic(id: 0, title: '', subtopics: []),
                        );
                        if (topic != null && topic.id > 0) {
                          context.go(
                              '/topics/${topic.id}/subtopic/${Uri.encodeComponent(widget.subtopicTitle!)}');
                        }
                      },
                      icon: const Icon(Icons.arrow_back, size: 20),
                      label: const Text('Subtopic'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Select Chapter button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showChapterSelector(context, book),
                    icon: const Icon(Icons.menu_book, size: 20),
                    label: const Text('Chapter'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChapterSelector(BuildContext context, BibleBook book) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Chapter - ${book.book}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: book.chapters.length,
                itemBuilder: (context, index) {
                  final chapterNum = book.chapters[index].chapter;
                  final isCurrent = chapterNum == widget.chapter;

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      if (!isCurrent) {
                        context.go(
                            '/bible/${Uri.encodeComponent(widget.bookName)}/$chapterNum');
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          chapterNum.toString(),
                          style: TextStyle(
                            color: isCurrent
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VerseWidget extends StatelessWidget {
  final Verse verse;
  final String bookName;
  final int chapter;
  final bool isHighlighted;

  const VerseWidget({
    super.key,
    required this.verse,
    required this.bookName,
    required this.chapter,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : null,
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verse number
          Container(
            width: 32,
            height: 24,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                verse.verse.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isHighlighted
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Verse text
          Expanded(
            child: Text(
              verse.text,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
