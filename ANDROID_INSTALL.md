# Android Installation Guide

## 📱 Android APK Installation

Your Torrey Bible Study app has been successfully built for Android! Two APK versions are available:

### APK Files Location
```
build/app/outputs/flutter-apk/
├── app-debug.apk    (89MB) - Development version with debugging capabilities
└── app-release.apk  (23.9MB) - Optimized production version
```

## Installation Methods

### Method 1: Direct APK Installation (Recommended)

1. **Copy APK to Android Device**
   ```bash
   # Copy the release APK to your device
   adb push build/app/outputs/flutter-apk/app-release.apk /sdcard/Download/
   ```
   
   Or manually copy `app-release.apk` to your device using USB file transfer.

2. **Enable Unknown Sources**
   - Go to **Settings → Security → Unknown Sources** (or **Settings → Apps → Special Access → Install Unknown Apps**)
   - Enable installation from unknown sources for your file manager

3. **Install APK**
   - Open your file manager and navigate to the APK file
   - Tap the APK file to install
   - Follow the installation prompts

### Method 2: ADB Install (Development)

```bash
# Install debug version for development
adb install build/app/outputs/flutter-apk/app-debug.apk

# Or install release version
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Method 3: Flutter Run (Development Only)

```bash
# Run directly from development environment
flutter run --release
```

## App Information

- **Package Name**: `com.torreyapp.biblestudy`
- **App Name**: Torrey Bible Study
- **Version**: 1.0.0
- **Minimum Android**: API 21 (Android 5.0)
- **Target Android**: API 35 (Android 15)

## Features Available on Android

✅ **Full Cross-Platform Experience**
- All 622 biblical topics with subtopics
- Complete World English Bible (31,102+ verses)
- Seamless navigation between topics and verses
- Search functionality across topics and verses
- Deep linking support for bookmarking

✅ **Android-Optimized Features**
- Material Design 3 interface
- Responsive layout for phones and tablets  
- Hardware back button support
- Android system integration
- Offline functionality (no internet required)

## Troubleshooting

### Installation Issues
- **"App not installed"**: Ensure you have enough storage space (>100MB)
- **"Parse error"**: APK may be corrupted, re-download/rebuild
- **"Unknown sources blocked"**: Check security settings and enable unknown sources

### Runtime Issues
- **App crashes**: Check device has Android 5.0+ and sufficient RAM
- **Large app size**: Debug APK (89MB) includes debugging symbols, use release APK (23.9MB)
- **Performance**: App loads large Bible dataset on startup, initial load may take a few seconds

## Development Notes

### Building New APKs
```bash
# Clean and rebuild
flutter clean
flutter pub get

# Build debug APK (with debugging)
flutter build apk --debug

# Build release APK (optimized)
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release
```

### Android-Specific Configuration
- **Package Name**: Updated to `com.torreyapp.biblestudy`
- **Jetifier**: Disabled for Java 25 compatibility
- **AGP Version**: 8.2.1 for modern Java support
- **Target SDK**: 35 for latest Android features

## Next Steps

### Play Store Distribution (Optional)
To distribute via Google Play Store:

1. **Create Release Signing Key**
   ```bash
   keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
   ```

2. **Configure Signing in `android/app/build.gradle`**
   ```gradle
   android {
       signingConfigs {
           release {
               keyAlias 'release'
               keyPassword 'your-password'
               storeFile file('../../release-key.jks')
               storePassword 'your-password'
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

3. **Build App Bundle**
   ```bash
   flutter build appbundle --release
   ```

The current APKs are signed with debug keys and ready for sideloading and testing!