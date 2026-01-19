import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../screens/topics_screen.dart';
import '../screens/subtopics_screen.dart';
import '../screens/subtopic_verses_screen.dart';
import '../screens/bible_reader_screen.dart';

/// App routing configuration using GoRouter
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Main topics screen
    GoRoute(
      path: '/',
      name: 'topics',
      builder: (context, state) => const TopicsScreen(),
    ),

    // Subtopics screen for a specific topic
    GoRoute(
      path: '/topic/:topicId',
      name: 'subtopics',
      builder: (context, state) {
        final topicIdStr = state.pathParameters['topicId']!;
        final topicId = int.tryParse(topicIdStr);

        if (topicId == null) {
          return const Scaffold(
            body: Center(
              child: Text('Invalid topic ID'),
            ),
          );
        }

        return SubtopicsScreen(topicId: topicId);
      },
    ),

    // Subtopic verses screen
    GoRoute(
      path: '/topics/:topicId/subtopic/:subtopicTitle',
      name: 'subtopic-verses',
      builder: (context, state) {
        final topicId = state.pathParameters['topicId']!;
        String subtopicTitle;

        try {
          subtopicTitle =
              Uri.decodeComponent(state.pathParameters['subtopicTitle']!);
        } catch (e) {
          // If decoding fails, use the raw parameter
          subtopicTitle = state.pathParameters['subtopicTitle']!;
        }

        return SubtopicVersesScreen(
          topicId: topicId,
          subtopicTitle: subtopicTitle,
        );
      },
    ),

    // Bible reader screen
    GoRoute(
      path: '/bible/:bookName/:chapter/:verse',
      name: 'bible-verse',
      builder: (context, state) {
        final bookName = Uri.decodeComponent(state.pathParameters['bookName']!);
        final chapterStr = state.pathParameters['chapter']!;
        final verseStr = state.pathParameters['verse']!;

        final chapter = int.tryParse(chapterStr);
        final verse = int.tryParse(verseStr);

        if (chapter == null || verse == null) {
          return const Scaffold(
            body: Center(
              child: Text('Invalid chapter or verse number'),
            ),
          );
        }

        // Get optional query parameters for topic context
        final topicTitle = state.uri.queryParameters['topic'];
        final subtopicTitle = state.uri.queryParameters['subtopic'];

        return BibleReaderScreen(
          bookName: bookName,
          chapter: chapter,
          highlightVerse: verse,
          topicTitle: topicTitle,
          subtopicTitle: subtopicTitle,
        );
      },
    ),

    // Bible reader screen (chapter only)
    GoRoute(
      path: '/bible/:bookName/:chapter',
      name: 'bible-chapter',
      builder: (context, state) {
        final bookName = Uri.decodeComponent(state.pathParameters['bookName']!);
        final chapterStr = state.pathParameters['chapter']!;

        final chapter = int.tryParse(chapterStr);

        if (chapter == null) {
          return const Scaffold(
            body: Center(
              child: Text('Invalid chapter number'),
            ),
          );
        }

        return BibleReaderScreen(
          bookName: bookName,
          chapter: chapter,
        );
      },
    ),
  ],

  // Error handling
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(
      title: const Text('Page Not Found'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Page Not Found',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'The page you requested could not be found.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);
