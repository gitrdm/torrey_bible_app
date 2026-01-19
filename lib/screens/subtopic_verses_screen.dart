import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/bible_models.dart';
import '../providers/app_provider.dart';

class SubtopicVersesScreen extends StatefulWidget {
  final String topicId;
  final String subtopicTitle;

  const SubtopicVersesScreen({
    super.key,
    required this.topicId,
    required this.subtopicTitle,
  });

  @override
  State<SubtopicVersesScreen> createState() => _SubtopicVersesScreenState();
}

class _SubtopicVersesScreenState extends State<SubtopicVersesScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final topic = provider.findTopic(int.parse(widget.topicId));
        if (topic == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Topic Not Found')),
            body: const Center(
                child: Text('The requested topic could not be found.')),
          );
        }

        final subtopic = topic.subtopics.firstWhere(
          (s) => s.title == widget.subtopicTitle,
          orElse: () => Subtopic(id: 0, title: '', verses: []),
        );

        if (subtopic.title.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Subtopic Not Found')),
            body: const Center(
                child: Text('The requested subtopic could not be found.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtopic.title,
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  topic.title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Column(
            children: [
              // Header with info
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
                          Icons.library_books,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Bible Verses for "${subtopic.title}"',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${subtopic.verses.length} verse references',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer
                            .withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Verses list
              Expanded(
                child: subtopic.verses.isEmpty
                    ? const Center(
                        child: Text(
                          'No verses found for this subtopic',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: subtopic.verses.length,
                        itemBuilder: (context, index) {
                          final verseRef = subtopic.verses[index];
                          return VerseCard(
                            verseReference: verseRef,
                            topicTitle: topic.title,
                            subtopicTitle: subtopic.title,
                          );
                        },
                      ),
              ),
            ],
          ),
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
            child: ElevatedButton.icon(
              onPressed: () => context.go('/topic/${widget.topicId}'),
              icon: const Icon(Icons.arrow_back, size: 20),
              label: const Text('Back to Subtopics'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        );
      },
    );
  }
}

class VerseCard extends StatelessWidget {
  final VerseReference verseReference;
  final String topicTitle;
  final String subtopicTitle;

  const VerseCard({
    super.key,
    required this.verseReference,
    required this.topicTitle,
    required this.subtopicTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.go(
            '/bible/${Uri.encodeComponent(verseReference.book)}/${verseReference.chapter}/${verseReference.verse}?topic=${Uri.encodeComponent(topicTitle)}&subtopic=${Uri.encodeComponent(subtopicTitle)}',
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verse reference header
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${verseReference.book} ${verseReference.chapter}:${verseReference.verse}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Verse text - using FutureBuilder for async data
              FutureBuilder<Verse?>(
                future:
                    Provider.of<AppProvider>(context, listen: false).findVerse(
                  verseReference.book,
                  verseReference.chapter,
                  verseReference.verse,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text(
                      'Loading verse...',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  }

                  if (snapshot.hasData && snapshot.data != null) {
                    return Text(
                      snapshot.data!.text,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    );
                  }

                  return Text(
                    'Verse not found',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
