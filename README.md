# Thaalika – Mess Subscription App

> A Flutter-based platform connecting mess owners with students for meal subscriptions and digital payments.

## Overview

Thaalika is a mobile application built with Flutter and Firebase that simplifies mess management for both service providers and students. The app enables mess owners to manage their operations digitally while providing students with an intuitive interface to discover nearby messes, subscribe to meal plans, and manage orders.

## Features

### For Students

| Feature | Status | Description |
|---------|--------|-------------|
| ✔️ Email/Password Login | Available | Secure authentication with Firebase Auth |
| ✔️ GPS-Based Mess Discovery | Available | Find messes within 5km radius using device location |
| ✔️ Distance Display | Available | See exact distance to each mess (e.g., "2.3 km away") |
| ✔️ Mess Type Filtering | Available | Filter by Veg/Non-Veg/Both |
| ✔️ Nearest First Sorting | Available | Messes automatically sorted by distance |
| ✔️ Browse Mess Details | Available | View menus, pricing, and contact information |
| ✔️ Digital Wallet | Available | View wallet balance and transaction history |
| ✔️ Order Tracking | Available | Track order status in real-time |
| ✔️ Subscription Management | Available | Subscribe to daily meal plans |

### For Mess Owners

| Feature | Status | Description |
|---------|--------|-------------|
| ✔️ Email/Password Login | Available | Secure authentication with Firebase Auth |
| ✔️ Create Mess Profile | Available | Set up mess with Google Places autocomplete |
| ✔️ Auto Location Extraction | Available | Latitude/longitude extracted automatically from address |
| ✔️ Edit Mess Profile | Available | Update mess details, menus, and pricing |
| ✔️ Menu Management | Available | Add and manage menu items with availability toggle |
| ✔️ Daily Menu Updates | Available | Quick update for lunch and dinner menus |
| ✔️ Extras Management | Available | Manage fast food items and pricing |
| ✔️ Order Dashboard | Available | View and process incoming orders |
| ✔️ Revenue Tracking | Available | Daily summary of orders and wallet revenue |

## Coming Soon

🔜 **OTP-Based Authentication** - Phone number login with SMS verification  
🔜 **Wallet Top-Up** - Add money to wallet via payment gateway  
🔜 **Push Notifications** - Real-time order updates and announcements  
🔜 **Rating & Reviews** - Student feedback system for messe
🔜 **Advanced Analytics** - Detailed revenue reports for owners  

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.0+ |
| Language | Dart 3.0+ |
| Backend | Firebase (Auth, Firestore, Storage, Messaging) |
| State Management | Provider |
| Navigation | GoRouter |
| Location Services | Geolocator, Geocoding |
| Maps Integration | Google Places API |
| Permissions | Permission Handler |

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0+
- Dart SDK 3.0.0+
- Firebase account
- Google Cloud Platform account (for Places API)

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

3. **Add Firebase configuration**
   
   Download `google-services.json` from your Firebase project and place it in:
   ```
   android/app/google-services.json
   ```

4. **Run the app**
   ```bash
   flutter run --dart-define=GOOGLE_API_KEY=your_google_api_key
   ```

### Building for Release

```bash
# APK
flutter build apk --release --dart-define=GOOGLE_API_KEY=your_api_key

# App Bundle
flutter build appbundle --release --dart-define=GOOGLE_API_KEY=your_api_key
```

## Security Notes

⚠️ **Important:** This repository does not include sensitive credentials.

**Files NOT in repository:**
- `android/app/google-services.json` - Firebase configuration
- `*.jks` - Android signing keys
- `key.properties` - Keystore passwords
- API keys - Passed via `--dart-define`

**For contributors:** Never commit `google-services.json`, signing keys, or API keys. Use environment variables for all secrets.

## Roadmap

### Phase 1 (Completed)
- ✅ Authentication system
- ✅ Mess profile management
- ✅ GPS-based location services
- ✅ Order management
- ✅ Digital wallet UI

### Phase 2 (In Progress)
- 🔄 OTP authentication
- 🔄 Payment gateway integration
- 🔄 Push notifications

### Phase 3 (Planned)
- 📋 Rating and review system
- 📋 Advanced analytics dashboard
- 📋 Multi-language support

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Guidelines

- Follow Dart/Flutter best practices
- Run `flutter analyze` before committing
- Add tests for new features
- Update documentation as needed

## License

This project is licensed under the MIT License.

```
MIT License

Copyright (c) 2025 Thaalika App

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

## Author

**Vinayak Ojha**

- GitHub: [@Vinayak258](https://github.com/Vinayak258)
--

Built with Flutter ❤️
