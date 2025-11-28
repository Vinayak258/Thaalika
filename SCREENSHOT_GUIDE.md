# 📸 Screenshot Capture Guide

This guide will help you capture high-quality screenshots for the README.

## Quick Method (Recommended)

### Using Flutter DevTools

1. **Run the app:**
   ```bash
   flutter run --dart-define=GOOGLE_API_KEY=your_key
   ```

2. **Navigate to each screen and press 's' in terminal**
   - This captures the current screen
   - Screenshot saved to project root
   - Move to `assets/screens/` and rename

### Using ADB (Android)

For each screen:

```bash
# 1. Navigate to the screen in the app
# 2. Run this command:
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png ./assets/screens/[screen_name].png
```

## Screens to Capture

### 1. Student Dashboard (`student_dashboard.png`)
- Login as student
- Main dashboard with mess list
- Shows GPS location banner and distance

### 2. Mess Details (`mess_details.png`)
- Tap on any mess from student dashboard
- Shows mess info, menu, and subscription options

### 3. Owner Dashboard (`owner_dashboard.png`)
- Login as mess owner
- Main dashboard with quick actions
- Shows today's summary

### 4. Location Autocomplete (`location_autocomplete.png`)
- Go to Create/Edit Mess Profile
- Tap on location field
- Show autocomplete suggestions

### 5. Order Management (`order_management.png`)
- Owner dashboard → View Orders
- Shows list of orders with status

### 6. Wallet (`wallet.png`)
- Student → Wallet screen
- Shows balance and transaction history

## Screenshot Requirements

- **Format:** PNG
- **Resolution:** Match your emulator (1080×2400 recommended)
- **No debug banner:** Run in release mode or hide debug banner
- **Clean UI:** No keyboard, no overlays

## Remove Debug Banner

Add this to your app:

```dart
MaterialApp(
  debugShowCheckedModeBanner: false, // Add this
  // ... rest of config
)
```

## After Capturing

1. Verify all 6 screenshots are in `assets/screens/`
2. Check file names match exactly:
   - `student_dashboard.png`
   - `mess_details.png`
   - `owner_dashboard.png`
   - `location_autocomplete.png`
   - `order_management.png`
   - `wallet.png`

3. Run `flutter pub get` to register assets

4. Screenshots will appear in README on GitHub!

## Alternative: Use Android Studio

1. Run app in Android Studio
2. Click camera icon in device toolbar
3. Save to `assets/screens/`
4. Rename files as needed
