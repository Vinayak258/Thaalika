# 🛠️ Environment Setup Guide

This guide explains how to set up the development environment for the Thaalika app with proper secret management.

## 📋 Prerequisites

- Flutter SDK 3.0.0+
- Android Studio or VS Code
- Firebase account
- Google Cloud Platform account

## 🔥 Firebase Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "Thaalika App"
4. Follow the setup wizard

### Step 2: Add Android App

1. In Firebase Console, click "Add app" → Android
2. Enter package name: `com.example.thaalika_app`
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

**IMPORTANT:** This file is in `.gitignore` and should NEVER be committed!

### Step 3: Enable Firebase Services

In Firebase Console, enable:

1. **Authentication**
   - Go to Authentication → Sign-in method
   - Enable "Email/Password"

2. **Cloud Firestore**
   - Go to Firestore Database
   - Create database in production mode
   - Set up security rules (see SECURITY_POLICY.md)

3. **Cloud Storage**
   - Go to Storage
   - Get started
   - Set up security rules

4. **Cloud Messaging**
   - Automatically enabled

## 🗺️ Google Maps API Setup

### Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project or select existing
3. Link to your Firebase project (optional)

### Step 2: Enable Required APIs

Enable these APIs:
- Places API
- Geocoding API
- Maps SDK for Android

### Step 3: Create API Key

1. Go to "Credentials" → "Create Credentials" → "API Key"
2. Copy the API key
3. Click "Restrict Key"

### Step 4: Restrict API Key (IMPORTANT!)

**Application restrictions:**
- Select "Android apps"
- Add package name: `com.example.thaalika_app`
- Add SHA-1 fingerprint:
  ```bash
  # Debug key
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  
  # Release key (when you have one)
  keytool -list -v -keystore path/to/your/keystore.jks -alias your_alias
  ```

**API restrictions:**
- Select "Restrict key"
- Choose:
  - Places API
  - Geocoding API
  - Maps SDK for Android

## 🔑 Environment Variables Setup

### Method 1: Command Line (Recommended for Development)

Run app with `--dart-define`:

```bash
flutter run --dart-define=GOOGLE_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXX
```

### Method 2: VS Code Launch Configuration

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "thaalika_app (Debug)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=GOOGLE_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXX"
      ]
    },
    {
      "name": "thaalika_app (Release)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "flutterMode": "release",
      "args": [
        "--dart-define=GOOGLE_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXX"
      ]
    }
  ]
}
```

**Note:** Add `.vscode/launch.json` to `.gitignore` if it contains secrets!

### Method 3: Android Studio Run Configuration

1. Run → Edit Configurations
2. Select your Flutter configuration
3. Add to "Additional run args":
   ```
   --dart-define=GOOGLE_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXX
   ```

## 📦 Install Dependencies

```bash
flutter pub get
```

## 🏃 Running the App

### Debug Mode

```bash
# With API key
flutter run --dart-define=GOOGLE_API_KEY=your_key_here

# On specific device
flutter run -d <device-id> --dart-define=GOOGLE_API_KEY=your_key_here
```

### Release Mode

```bash
flutter run --release --dart-define=GOOGLE_API_KEY=your_key_here
```

## 🔨 Building the App

### Debug APK

```bash
flutter build apk --debug --dart-define=GOOGLE_API_KEY=your_key_here
```

### Release APK

```bash
flutter build apk --release --dart-define=GOOGLE_API_KEY=your_key_here
```

### App Bundle (for Play Store)

```bash
flutter build appbundle --release --dart-define=GOOGLE_API_KEY=your_key_here
```

## 🔐 Android Signing Setup (For Release)

### Step 1: Generate Keystore

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Step 2: Create key.properties

Create `android/key.properties`:

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

**IMPORTANT:** This file is in `.gitignore`!

### Step 3: Update build.gradle

Already configured in `android/app/build.gradle`.

## 🧪 Testing

### Run Tests

```bash
flutter test
```

### Run with Coverage

```bash
flutter test --coverage
lcov --list coverage/lcov.info
```

## 🐛 Troubleshooting

### "Google API Key not found"

- Ensure you're running with `--dart-define=GOOGLE_API_KEY=...`
- Check that the key is correct
- Verify API is enabled in Google Cloud Console

### "google-services.json not found"

- Download from Firebase Console
- Place in `android/app/google-services.json`
- Run `flutter clean` and `flutter pub get`

### Location not working

- Check location permissions in `AndroidManifest.xml`
- Ensure GPS is enabled on device
- Verify Google Maps API key is valid

### Build fails

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## 📱 Minimum Requirements

- Android: API 21+ (Android 5.0)
- iOS: iOS 12.0+

## 🔄 Updating Dependencies

```bash
# Check for updates
flutter pub outdated

# Update all
flutter pub upgrade

# Update specific package
flutter pub upgrade package_name
```

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [Google Maps Platform](https://developers.google.com/maps/documentation)

---

**Need help?** Check the README.md or open an issue on GitHub.
