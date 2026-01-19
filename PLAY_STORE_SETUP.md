# Android Release Signing Guide

## Generate Release Keystore

```bash
keytool -genkey -v -keystore ~/torrey-bible-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias torrey-bible-key \
  -dname "CN=Torrey Bible Study, OU=Bible Apps, O=Your Organization, L=Your City, ST=Your State, C=US"
```

## Configure Signing

Create `android/key.properties`:
```properties
storePassword=your_keystore_password
keyPassword=your_key_password  
keyAlias=torrey-bible-key
storeFile=../torrey-bible-release-key.jks
```

Add to `android/app/build.gradle`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

## Build Signed Release

```bash
flutter build appbundle --release
```

**⚠️ Important**: Keep your keystore file secure and backed up!