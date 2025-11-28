# 🔐 Security Policy

## Overview

This document outlines security best practices for the Thaalika app to protect sensitive data and credentials.

## 🚨 Critical Security Rules

### 1. Never Commit Credentials

**NEVER** commit the following to version control:

#### Firebase Configuration
- ❌ `android/app/google-services.json`
- ❌ `ios/Runner/GoogleService-Info.plist`
- ❌ `lib/firebase_options.dart` (if contains keys)
- ❌ `functions/.runtimeconfig.json`
- ❌ `functions/service-account.json`

#### API Keys
- ❌ Google Maps/Places API keys
- ❌ Payment gateway keys (Razorpay, Stripe, etc.)
- ❌ Backend API URLs with embedded tokens
- ❌ Any `.env` files

#### Signing Keys (Android)
- ❌ `*.jks` files
- ❌ `*.keystore` files
- ❌ `upload-keystore.jks`
- ❌ `key.properties`
- ❌ `android/gradle.properties` (if contains passwords)

#### iOS Signing
- ❌ Provisioning profiles with embedded certificates
- ❌ `.p12` certificate files

### 2. Use Environment Variables

Instead of hardcoding secrets, use `--dart-define`:

```dart
// ❌ BAD - Hardcoded
const apiKey = "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXX";

// ✅ GOOD - Environment variable
const apiKey = String.fromEnvironment('GOOGLE_API_KEY');
```

Run app with:
```bash
flutter run --dart-define=GOOGLE_API_KEY=your_actual_key
```

### 3. Verify .gitignore

Before committing, ensure `.gitignore` includes:

```gitignore
# Firebase
android/app/google-services.json
ios/Runner/GoogleService-Info.plist

# API Keys
lib/keys.dart
.env*

# Signing
*.jks
*.keystore
key.properties
```

### 4. Check Before Pushing

Before `git push`, run:

```bash
# Check what will be committed
git status

# Verify no secrets in staged files
git diff --cached

# Search for potential secrets
git grep -i "api.*key"
git grep -i "password"
```

## 🛡️ Security Checklist

Before making repository public:

- [ ] All API keys use `String.fromEnvironment()`
- [ ] `google-services.json` is in `.gitignore`
- [ ] No `.jks` or `.keystore` files committed
- [ ] No hardcoded passwords or tokens
- [ ] `key.properties` is in `.gitignore`
- [ ] Firebase rules are properly configured
- [ ] No debug logs with sensitive data
- [ ] README includes security setup instructions

## 🔍 What to Do If Secrets Are Exposed

If you accidentally commit secrets:

1. **Immediately revoke/regenerate** the exposed credentials
2. **Remove from Git history** using:
   ```bash
   git filter-branch --force --index-filter \
   "git rm --cached --ignore-unmatch path/to/secret/file" \
   --prune-empty --tag-name-filter cat -- --all
   ```
3. **Force push** to remote (if already pushed)
4. **Update** all team members

## 📱 Firebase Security

### Firestore Rules

Ensure Firestore rules are restrictive:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Messes are public read, owner write
    match /messes/{messId} {
      allow read: if true;
      allow write: if request.auth != null && 
                     resource.data.ownerUid == request.auth.uid;
    }
  }
}
```

### Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /mess_logos/{messId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## 🔑 API Key Restrictions

### Google Maps API Key

Restrict your API key in Google Cloud Console:

1. **Application restrictions**: Android apps
2. **Package name**: `com.example.thaalika_app`
3. **SHA-1 fingerprint**: Your app's signing certificate
4. **API restrictions**: 
   - Places API
   - Geocoding API
   - Maps SDK for Android

## 📞 Reporting Security Issues

If you discover a security vulnerability:

1. **DO NOT** open a public issue
2. Email: security@yourcompany.com
3. Include:
   - Description of vulnerability
   - Steps to reproduce
   - Potential impact

## 📚 Additional Resources

- [Firebase Security Best Practices](https://firebase.google.com/docs/rules/best-practices)
- [Flutter Security](https://docs.flutter.dev/security)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)

---

**Remember:** Security is everyone's responsibility. When in doubt, ask!
