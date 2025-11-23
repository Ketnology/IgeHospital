# Deployment Guide

> **Document Version:** 1.0.0
> **Last Updated:** November 2024

## Overview

IGE Hospital can be deployed to multiple platforms: Web, Android, iOS, macOS, Windows, and Linux. This guide covers build and deployment procedures for each platform.

---

## Pre-Deployment Checklist

- [ ] All tests passing
- [ ] Code analyzed with no issues
- [ ] API endpoints configured correctly
- [ ] Version number updated
- [ ] Environment-specific configs set
- [ ] Assets and icons configured
- [ ] Build signing configured (mobile)

---

## Web Deployment

### Build for Web

```bash
# Clean build
flutter clean
flutter pub get

# Build release
flutter build web --release

# Build with base href (for subdirectory hosting)
flutter build web --release --base-href="/app/"
```

### Build Output

```
build/web/
├── assets/
├── icons/
├── index.html
├── main.dart.js
├── flutter.js
├── flutter_service_worker.js
└── manifest.json
```

### Hosting Options

#### 1. Static Hosting (Recommended)

- **Firebase Hosting**
- **Netlify**
- **Vercel**
- **AWS S3 + CloudFront**
- **GitHub Pages**

#### 2. Firebase Hosting Example

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize project
firebase init hosting

# Configure firebase.json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}

# Deploy
firebase deploy
```

#### 3. Nginx Configuration

```nginx
server {
    listen 80;
    server_name hospital.example.com;

    root /var/www/igehospital;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;

    # Static asset caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # SPA routing
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

---

## Android Deployment

### Setup Signing

1. **Generate Keystore**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **Configure key.properties**
```properties
# android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

3. **Update build.gradle**
```gradle
// android/app/build.gradle
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
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
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

### Build APK

```bash
# Clean and build
flutter clean
flutter pub get

# Build APK
flutter build apk --release

# Build split APKs (recommended for smaller size)
flutter build apk --release --split-per-abi

# Output
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
```

### Build App Bundle (for Play Store)

```bash
flutter build appbundle --release

# Output
# build/app/outputs/bundle/release/app-release.aab
```

### Play Store Submission

1. Create app in Google Play Console
2. Upload AAB file
3. Complete store listing
4. Submit for review

---

## iOS Deployment

### Prerequisites

- macOS with Xcode installed
- Apple Developer account
- Provisioning profiles configured

### Configure Signing

1. Open Xcode
```bash
open ios/Runner.xcworkspace
```

2. Select Runner target
3. Configure Signing & Capabilities
4. Select team and provisioning profile

### Build for iOS

```bash
# Clean and build
flutter clean
flutter pub get

# Build iOS
flutter build ios --release

# Build IPA for distribution
flutter build ipa --release

# Output
# build/ios/archive/Runner.xcarchive
# build/ios/ipa/igehospital.ipa
```

### App Store Submission

1. Open Xcode Organizer
2. Select archive
3. Distribute App → App Store Connect
4. Upload to App Store Connect
5. Submit for review in App Store Connect

---

## macOS Deployment

### Build for macOS

```bash
flutter build macos --release

# Output
# build/macos/Build/Products/Release/IgeHospital.app
```

### Create DMG for Distribution

```bash
# Create DMG
create-dmg \
  --volname "IGE Hospital" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "IgeHospital.app" 200 190 \
  --hide-extension "IgeHospital.app" \
  --app-drop-link 600 185 \
  "IGEHospital.dmg" \
  "build/macos/Build/Products/Release/IgeHospital.app"
```

### Mac App Store

1. Configure App Sandbox entitlements
2. Enable Hardened Runtime
3. Notarize the app
4. Submit via Transporter

---

## Environment Configuration

### API Base URL

The API URL is hardcoded in `lib/constants/api_endpoints.dart`:

```dart
static const String baseUrl = 'https://api.igehospital.com/api';
```

For different environments, consider:

1. **Compile-time variables**
```bash
flutter build web --dart-define=API_URL=https://staging.api.igehospital.com
```

```dart
const String apiUrl = String.fromEnvironment('API_URL',
  defaultValue: 'https://api.igehospital.com/api');
```

2. **Flutter flavors** (for mobile)

---

## Version Management

### Update Version

Edit `pubspec.yaml`:

```yaml
version: 1.0.0+1
# format: major.minor.patch+buildNumber
```

### Semantic Versioning

- **Major**: Breaking changes
- **Minor**: New features (backwards compatible)
- **Patch**: Bug fixes

---

## CI/CD Pipeline

### GitHub Actions Example

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  build-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze
        run: flutter analyze

      - name: Test
        run: flutter test

      - name: Build web
        run: flutter build web --release

      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: igehospital

  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Build APK
        run: flutter build apk --release

      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

---

## Post-Deployment

### Monitoring

- Set up error tracking (e.g., Sentry, Firebase Crashlytics)
- Configure analytics
- Set up uptime monitoring

### Rollback Plan

- Keep previous deployment artifacts
- Document rollback procedure
- Test rollback process

---

## Deployment Checklist by Platform

### Web
- [ ] Build completed successfully
- [ ] Assets loading correctly
- [ ] API connectivity verified
- [ ] CORS configured on server
- [ ] SSL certificate valid
- [ ] Caching headers configured

### Android
- [ ] App signed with release keystore
- [ ] Permissions declared correctly
- [ ] ProGuard configured
- [ ] App tested on multiple devices
- [ ] Store listing prepared

### iOS
- [ ] Provisioning profile valid
- [ ] Entitlements configured
- [ ] App reviewed on physical device
- [ ] Store screenshots prepared
- [ ] Privacy policy URL set
