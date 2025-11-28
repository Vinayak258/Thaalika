# Thaalika – Smart Subscription-Based Mess App

> A comprehensive Flutter application connecting mess owners with students for seamless meal subscriptions, orders, and digital payments.

## Overview

Thaalika is a modern mess management platform built with Flutter and Firebase that bridges the gap between mess service providers and students. The app enables mess owners to manage their operations digitally while providing students with an intuitive interface to discover nearby messes, subscribe to meal plans, and place orders for extras.

Key highlights:
- **Location-aware**: GPS-based mess discovery with 5km radius filtering
- **Real-time updates**: Live order tracking and menu updates via Firestore
- **Secure architecture**: Environment-based API key management
- **Digital wallet**: Integrated payment system with coupon support
- **Role-based access**: Separate interfaces for students and mess owners

## Features

### For Students
- ✅ **OTP Authentication** - Secure phone-based login (UI ready, backend coming soon)
- ✅ **GPS-Based Mess Discovery** - Automatically find messes within 5km radius
- ✅ **Smart Filtering** - Filter by mess type (Veg/Non-Veg/Both) and sort by distance
- ✅ **Meal Subscriptions** - Subscribe to daily meal plans
- ✅ **Order Extras** - Place orders for fast food and additional items
- ✅ **Digital Wallet** - Manage balance and view transaction history
- ✅ **Coupon System** - Use mess-specific coupons for discounts
- ✅ **Order Tracking** - Real-time order status updates
- ✅ **Distance Display** - See exact distance to each mess (e.g., "2.3 km away")

### For Mess Owners
- ✅ **Profile Management** - Create and edit mess profile with Google Places autocomplete
- ✅ **Automatic Location** - Latitude and longitude extracted automatically from selected address
- ✅ **Menu Management** - Update daily lunch and dinner menus
- ✅ **Extras Management** - Add and manage fast food items with pricing
- ✅ **Order Dashboard** - View and process incoming orders
- ✅ **Revenue Tracking** - Daily summary of orders, coupons used, and wallet revenue
- ✅ **Quick Updates** - Fast menu editing with dialog-based interface

### Security & Architecture
- ✅ **Environment Variables** - API keys managed via `--dart-define`
- ✅ **Protected Secrets** - Firebase configs and signing keys excluded from repository
- ✅ **Secure .gitignore** - Comprehensive protection for sensitive files
- ✅ **No Hardcoded Credentials** - All secrets externalized for production safety

## Screenshots
Soon....

## Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.0+ |
| **Language** | Dart 3.0+ |
| **Backend** | Firebase (Auth, Firestore, Storage, Messaging) |
| **State Management** | Provider |
| **Navigation** | GoRouter |
| **Location Services** | Geolocator, Geocoding |
| **Maps Integration** | Google Places API |
| **Permissions** | Permission Handler |
| **Image Handling** | Image Picker |

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio or VS Code
- Firebase account
- Google Cloud Platform account (for Maps/Places API)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/thaalika_app.git
   cd thaalika_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   
   a. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   
   b. Add an Android app to your Firebase project
   
   c. Download `google-services.json`
   
   d. Place it in the project:
      ```
      android/app/google-services.json
      ```
   
   e. Enable these services in Firebase Console:
      - Authentication (Email/Password)
      - Cloud Firestore
      - Cloud Storage
      - Cloud Messaging

4. **Google Maps API Setup**
   
   a. Go to [Google Cloud Console](https://console.cloud.google.com/)
   
   b. Enable the following APIs:
      - Places API
      - Geocoding API
      - Maps SDK for Android
   
   c. Create an API key and restrict it to your app's package name and SHA-1 fingerprint

5. **Run the app**
   ```bash
   flutter run --dart-define=GOOGLE_API_KEY=your_google_api_key_here
   ```

### Building for Release

**APK (for testing)**
```bash
flutter build apk --release --dart-define=GOOGLE_API_KEY=your_api_key
```

**App Bundle (for Play Store)**
```bash
flutter build appbundle --release --dart-define=GOOGLE_API_KEY=your_api_key
```

### VS Code Configuration

Create `.vscode/launch.json` for easier development:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Thaalika (Debug)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=GOOGLE_API_KEY=your_google_api_key_here"
      ]
    }
  ]
}
```

**Note:** Add this file to `.gitignore` if it contains actual API keys.

## Project Structure

```
lib/
├── core/
│   ├── constants/           # App-wide constants
│   └── router/              # Navigation configuration
├── models/                  # Data models
│   ├── user_model.dart
│   ├── mess_model.dart
│   ├── order_model.dart
│   ├── menu_item_model.dart
│   └── extra_item_model.dart
├── providers/               # State management
│   ├── auth_provider.dart
│   ├── mess_provider.dart
│   ├── order_provider.dart
│   ├── wallet_provider.dart
│   └── user_provider.dart
├── screens/                 # UI screens
│   ├── auth/               # Login, Register, OTP
│   ├── owner/              # Mess owner screens
│   │   ├── owner_dashboard_screen.dart
│   │   ├── create_mess_profile_screen.dart
│   │   ├── edit_mess_profile_screen.dart
│   │   ├── menu_management_screen.dart
│   │   └── order_management_screen.dart
│   └── student/            # Student screens
│       ├── student_dashboard_screen.dart
│       ├── mess_detail_screen.dart
│       ├── cart_screen.dart
│       ├── wallet_screen.dart
│       └── subscription_screen.dart
├── services/                # Business logic
│   ├── auth_service.dart
│   ├── mess_service.dart
│   ├── order_service.dart
│   ├── menu_service.dart
│   └── wallet_service.dart
├── utils/                   # Helper functions
│   └── validators.dart
└── main.dart               # App entry point
```

## Security

### Important Security Notes

This repository intentionally **does not include** sensitive credentials or API keys. This is a security best practice for open-source projects.

**Protected Files (not in repository):**
- `android/app/google-services.json` - Firebase Android configuration
- `ios/Runner/GoogleService-Info.plist` - Firebase iOS configuration
- `*.jks` - Android signing keystores
- `key.properties` - Keystore passwords
- `.env` files - Environment variables

**How API Keys Are Managed:**

All API keys are passed via command-line arguments using `--dart-define`:

```dart
// In code
const apiKey = String.fromEnvironment('GOOGLE_API_KEY');

// When running
flutter run --dart-define=GOOGLE_API_KEY=your_actual_key
```

**For Contributors:**

1. Never commit `google-services.json` or any `.jks` files
2. Use `--dart-define` for all secrets
3. Check `.gitignore` before committing
4. Review `SECURITY_POLICY.md` for detailed guidelines

## Contributing

Contributions are welcome! Please follow these steps:

1. **Fork the repository**

2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make your changes**
   - Follow the existing code style
   - Add comments for complex logic
   - Update documentation if needed

4. **Test your changes**
   ```bash
   flutter test
   flutter analyze
   ```

5. **Commit your changes**
   ```bash
   git commit -m "Add amazing feature"
   ```

6. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```

7. **Open a Pull Request**
   - Describe your changes clearly
   - Reference any related issues
   - Ensure all checks pass

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Keep functions small and focused
- Add comments for non-obvious logic
- Run `flutter analyze` before committing

### Reporting Issues

Found a bug or have a feature request? Please open an issue with:
- Clear description of the problem/feature
- Steps to reproduce (for bugs)
- Expected vs actual behavior
- Screenshots if applicable

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Thaalika App Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Acknowledgments

- **Flutter Team** - For the amazing cross-platform framework
- **Firebase** - For comprehensive backend services
- **Google Maps Platform** - For location and mapping services
- **Open Source Community** - For inspiration and support

## Contact & Support

- **Author**: Vinayak Ojha
- **Project Repository**: [https://github.com/yourusername/thaalika_app](https://github.com/yourusername/thaalika_app)
- **Issues**: [https://github.com/yourusername/thaalika_app/issues](https://github.com/yourusername/thaalika_app/issues)

For detailed setup instructions, see [SETUP_ENVIRONMENT.md](SETUP_ENVIRONMENT.md)

For security guidelines, see [SECURITY_POLICY.md](SECURITY_POLICY.md)

---

**Built with ❤️ using Flutter**
