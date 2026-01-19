# Torrey Bible Study App

A comprehensive cross-platform Bible study application built with Flutter, integrating the **Torrey New Topical Textbook** with the **World English Bible** translation. This app provides an intuitive way to explore biblical topics and their corresponding scripture references.

## 📱 Features

- **622 Bible Topics**: Complete integration of Torrey's New Topical Textbook
- **Cross-Platform**: Runs on Android, iOS, Web, and Linux desktop
- **38,000+ Bible Verses**: Full World English Bible translation with fast search
- **Intelligent Navigation**: Topic → Subtopic → Verses → Bible Reader workflow
- **10,552 Cross-References**: Direct links between topics and Bible passages
- **Modern UI**: Material Design 3 with beautiful, responsive interface
- **Verse Highlighting**: Automatic highlighting of selected verses
- **Chapter Navigation**: Easy navigation between Bible chapters
- **Context-Aware**: Smart navigation that remembers your study path

## 🏗️ Architecture

### Tech Stack
- **Framework**: Flutter 3.27.1
- **State Management**: Provider pattern
- **Navigation**: GoRouter with deep linking
- **Data Format**: Optimized JSON (12.6MB total)
- **UI Design**: Material Design 3
- **Platforms**: Android, iOS, Web, Linux Desktop

### Project Structure
```
lib/
├── models/           # Data models (BibleBook, Topic, Verse, etc.)
├── services/         # Data loading and caching services
├── providers/        # State management with Provider
├── screens/          # UI screens (Topics, Subtopics, Bible Reader)
├── router/           # Navigation routing configuration
└── main.dart         # App entry point

assets/data/
├── web_bible_complete.json    # Complete WEB Bible (7.8MB)
└── torrey_topics_complete.json # Torrey topics with cross-refs (4.8MB)
```

## 🚀 Getting Started

### Prerequisites
- Flutter 3.27.1 or later
- Dart SDK
- Platform-specific requirements:
  - **Linux**: GTK development libraries
  - **Android**: Android SDK
  - **iOS**: Xcode (macOS only)
  - **Web**: Chrome/Firefox for testing

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd torrey_bible_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Linux desktop
   flutter run -d linux
   
   # For web
   flutter run -d web-server --web-port 8080
   
   # For Android (with device/emulator connected)
   flutter run -d android
   
   # For iOS (macOS only)
   flutter run -d ios
   ```

## 📱 Android Installation

Pre-built Android APKs are available in `build/app/outputs/flutter-apk/`:

- **app-release.apk** (23.9MB) - Optimized production version
- **app-debug.apk** (89MB) - Development version with debugging

### Quick Install
```bash
# Copy to device and install manually
adb push build/app/outputs/flutter-apk/app-release.apk /sdcard/Download/

# Or install directly via ADB
adb install build/app/outputs/flutter-apk/app-release.apk
```

📋 See **[ANDROID_INSTALL.md](ANDROID_INSTALL.md)** for complete installation guide and troubleshooting.

## 📊 Data Processing

The app uses pre-processed JSON data created from:
- **World English Bible**: 1,402 individual chapter files processed into structured JSON
- **Torrey New Topical Textbook**: XML format converted to hierarchical JSON with cross-references

### Data Statistics
- **81 Bible Books**: Genesis to Revelation
- **622 Topics**: Complete Torrey classification system  
- **2,800+ Subtopics**: Detailed topic subdivisions
- **38,000+ Verses**: Full biblical text with metadata
- **10,552 Cross-References**: Topic-to-verse connections

## 🎯 User Experience

### Navigation Flow
1. **Topics Screen**: Browse 622 biblical topics with search functionality
2. **Subtopics Screen**: Explore detailed subtopic classifications
3. **Subtopic Verses Screen**: View all Bible verses related to a specific subtopic
4. **Bible Reader Screen**: Read full chapters with verse highlighting and navigation

### Key User Features
- **Search**: Find topics quickly with real-time search
- **Context Navigation**: Smart back buttons maintain your study context
- **Verse Highlighting**: Selected verses are automatically highlighted
- **Chapter Selection**: Quick navigation between Bible chapters
- **Responsive Design**: Works beautifully on all screen sizes

## 🔧 Development

### Hot Reload
The app supports Flutter's hot reload for rapid development:
```bash
# In running app terminal
r  # Hot reload
R  # Hot restart
```

### Adding New Features
1. **Models**: Add data structures in `lib/models/`
2. **Services**: Add data processing in `lib/services/`
3. **Screens**: Add UI components in `lib/screens/`
4. **Navigation**: Update routes in `lib/router/app_router.dart`

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable names
- Document complex functions
- Maintain consistent formatting

## 🚢 Deployment

### Web Deployment
```bash
flutter build web
# Deploy contents of build/web/ to your web server
```

### Android APK
```bash
flutter build apk --release
# APK will be in build/app/outputs/flutter-apk/
```

### Linux Desktop
```bash
flutter build linux --release
# Executable will be in build/linux/x64/release/bundle/
```

## 📚 Data Sources

- **World English Bible**: Public domain English Bible translation
- **Torrey's New Topical Textbook**: R.A. Torrey's systematic biblical topic classification
- **Cross-References**: Manually curated topic-to-scripture connections

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is open source. The Bible text (World English Bible) and Torrey's New Topical Textbook are in the public domain.

## 🙏 Acknowledgments

- **R.A. Torrey** for the original Topical Textbook
- **World English Bible** translators for the public domain Bible text
- **Flutter team** for the excellent cross-platform framework
- **Contributors** who helped build and improve this application

---

*Built with ❤️ for Bible study and spiritual growth*
