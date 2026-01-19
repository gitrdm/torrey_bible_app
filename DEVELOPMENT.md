# Development Documentation

## Project Overview

The Torrey Bible Study App is a Flutter application that combines R.A. Torrey's New Topical Textbook with the World English Bible translation to create an intuitive Bible study experience.

## Architecture Details

### State Management
The app uses the Provider pattern for state management:

- **AppProvider**: Main application state manager
- **DataService**: Singleton service for data operations
- **BibleData/TorreyData**: Data model containers

### Navigation System
GoRouter provides declarative routing with deep linking support:

```dart
Routes:
/ - Topics screen (main)
/topic/:topicId - Subtopics for a specific topic
/topics/:topicId/subtopic/:subtopicTitle - Verses for a subtopic
/bible/:bookName/:chapter/:verse - Bible reader with verse highlighting
```

### Data Models

#### Core Models
- **BibleBook**: Represents a book of the Bible with chapters
- **Chapter**: Contains verses for a specific chapter
- **Verse**: Individual Bible verse with text and metadata
- **Topic**: Torrey topic with subtopics and verse references
- **Subtopic**: Topic subdivision with specific verse references
- **VerseReference**: Connection between topics and Bible verses

#### Data Flow
```
JSON Files → DataService → Provider → UI Components
    ↑
Assets Loading → Parsing → Caching → State Management
```

## Code Organization

### lib/models/bible_models.dart
Contains all data models with JSON serialization:
- BibleBook, Chapter, Verse
- Topic, Subtopic, VerseReference
- BibleData, TorreyData containers

### lib/services/data_service.dart
Singleton service handling:
- JSON file loading from assets
- Data parsing and validation
- Caching and search operations
- Cross-reference lookups

### lib/providers/app_provider.dart
State management with ChangeNotifier:
- Data loading status
- Error handling
- Search operations
- Navigation state

### lib/screens/
UI components for different app screens:
- **topics_screen.dart**: Main topics list with search
- **subtopics_screen.dart**: Topic subtopics with navigation
- **subtopic_verses_screen.dart**: All verses for a subtopic
- **bible_reader_screen.dart**: Bible text with verse highlighting

### lib/router/app_router.dart
Navigation configuration:
- Route definitions
- Parameter handling
- Deep linking support
- Error pages

## Development Workflow

### Adding New Features

1. **Data Models**: Update models in `bible_models.dart`
2. **Data Service**: Add data processing methods
3. **Provider**: Update state management
4. **UI**: Create/update screen components
5. **Navigation**: Update router if needed

### Testing Strategy

#### Unit Tests
- Model serialization/deserialization
- Data service operations
- Provider state changes
- Utility functions

#### Integration Tests
- Navigation flows
- Data loading
- Search functionality
- Cross-platform compatibility

#### Widget Tests
- Screen rendering
- User interactions
- State updates
- Error handling

### Performance Considerations

#### Data Loading
- Large JSON files (12.6MB total) loaded asynchronously
- Data cached in memory after first load
- Lazy loading for optimal startup performance

#### Memory Management
- Efficient data structures
- Image and resource optimization
- Proper disposal of controllers

#### Platform Optimization
- Responsive design for different screen sizes
- Platform-specific UI adaptations
- Performance monitoring and optimization

## Debugging and Troubleshooting

### Common Issues

#### Data Loading Errors
- Check asset paths in pubspec.yaml
- Verify JSON file integrity
- Monitor memory usage for large files

#### Navigation Problems
- Validate route parameters
- Check URL encoding for special characters
- Test deep linking scenarios

#### Performance Issues
- Profile app startup time
- Monitor memory consumption
- Optimize widget rebuilds

### Debugging Tools
- Flutter Inspector for UI debugging
- DevTools for performance analysis
- Debug logging for data operations
- Hot reload for rapid iteration

## Deployment Considerations

### Asset Management
- Large JSON files included in app bundle
- Consider server-side loading for updates
- Optimize file sizes where possible

### Platform-Specific Setup
- Linux: GTK dependencies
- Android: Minimum SDK requirements
- iOS: Deployment certificates
- Web: CORS and loading considerations

### Performance Optimization
- Code splitting for web
- APK size optimization for Android
- Memory optimization for all platforms