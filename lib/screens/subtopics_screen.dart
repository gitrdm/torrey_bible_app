import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/bible_models.dart';
import '../providers/app_provider.dart';

class SubtopicsScreen extends StatelessWidget {
  final int topicId;

  const SubtopicsScreen({
    super.key,
    required this.topicId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final topic = provider.findTopic(topicId);

        if (topic == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Topic Not Found'),
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('The requested topic could not be found.'),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              topic.title,
              style: const TextStyle(fontSize: 18),
            ),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Column(
            children: [
              // Topic summary header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
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
                    Text(
                      topic.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${topic.subtopics.length} subtopics • ${topic.totalVerses} verse references',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Subtopics list
              Expanded(
                child: topic.subtopics.isEmpty
                    ? const Center(
                        child: Text('No subtopics found for this topic.'),
                      )
                    : ListView.builder(
                        itemCount: topic.subtopics.length,
                        itemBuilder: (context, index) {
                          final subtopic = topic.subtopics[index];
                          return SubtopicCard(
                            subtopic: subtopic,
                            topicTitle: topic.title,
                            topicId: topicId,
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
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.arrow_back, size: 20),
              label: const Text('Back to Topics'),
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

class SubtopicCard extends StatefulWidget {
  final Subtopic subtopic;
  final String topicTitle;
  final int topicId;

  const SubtopicCard({
    super.key,
    required this.subtopic,
    required this.topicTitle,
    required this.topicId,
  });

  @override
  State<SubtopicCard> createState() => _SubtopicCardState();
}

class _SubtopicCardState extends State<SubtopicCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              widget.subtopic.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              '${widget.subtopic.verses.length} verse references',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon:
                      Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
            onTap: () {
              // Navigate to subtopic verses screen to show all verses
              context.go(
                  '/topics/${widget.topicId}/subtopic/${Uri.encodeComponent(widget.subtopic.title)}');
            },
          ),
          if (_isExpanded && widget.subtopic.verses.isNotEmpty) ...[
            const Divider(height: 1),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verse References:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.subtopic.verses.map((verse) {
                      return VerseReferenceChip(
                        verseRef: verse,
                        topicTitle: widget.topicTitle,
                        subtopicTitle: widget.subtopic.title,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class VerseReferenceChip extends StatelessWidget {
  final VerseReference verseRef;
  final String topicTitle;
  final String subtopicTitle;

  const VerseReferenceChip({
    super.key,
    required this.verseRef,
    required this.topicTitle,
    required this.subtopicTitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.go(
            '/bible/${Uri.encodeComponent(verseRef.book)}/${verseRef.chapter}/${verseRef.verse}?topic=${Uri.encodeComponent(topicTitle)}&subtopic=${Uri.encodeComponent(subtopicTitle)}');
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          verseRef.displayReference,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
