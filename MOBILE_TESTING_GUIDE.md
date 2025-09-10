# 📱 Mobile Testing Guide

This guide explains how to test the Flutter app on various mobile devices with the backend API.

## 🚀 Quick Start

```bash
# 1. Start the backend services
make dev-backend

# 2. Check your machine's IP address
make mobile-ip

# 3. Run on your desired platform
flutter run -d android  # Android
flutter run -d ios      # iOS
flutter run -d chrome   # Web
```

## 🤖 Android Testing

### Android Emulator

1. **Start the backend**:
   ```bash
   make dev-backend
   ```

2. **Launch Android emulator**:
   ```bash
   flutter emulators --launch pixel_5
   # Or use Android Studio AVD Manager
   ```

3. **Run the app**:
   ```bash
   cd enterprise-auth-template/flutter_auth_template
   flutter run -d android
   ```

The app will automatically connect to `http://10.0.2.2:8000` (Android emulator's host IP).

### Physical Android Device

1. **Enable Developer Mode**:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Enable "Developer Options" → "USB Debugging"

2. **Connect via USB**:
   ```bash
   # Check device is connected
   adb devices
   
   # Forward ports (USB connection)
   adb reverse tcp:8000 tcp:8000
   
   # Run the app
   flutter run -d <device-id>
   ```

3. **Connect via WiFi** (same network):
   ```bash
   # Get your machine's IP
   make mobile-ip
   # Example output: 192.168.1.100
   
   # Update Flutter environment.dart with your IP
   # Then run the app
   flutter run -d <device-id>
   ```

## 🍎 iOS Testing

### iOS Simulator

1. **Start the backend**:
   ```bash
   make dev-backend
   ```

2. **Open iOS Simulator**:
   ```bash
   open -a Simulator
   # Or use Xcode
   ```

3. **Run the app**:
   ```bash
   cd enterprise-auth-template/flutter_auth_template
   flutter run -d ios
   ```

The app will automatically connect to `http://localhost:8000`.

### Physical iOS Device

1. **Prerequisites**:
   - Xcode installed
   - Apple Developer account (free or paid)
   - Device registered in provisioning profile

2. **Setup**:
   ```bash
   # Open Xcode project
   cd enterprise-auth-template/flutter_auth_template/ios
   open Runner.xcworkspace
   
   # Sign the app with your developer account
   # Select your team in Signing & Capabilities
   ```

3. **Run on device**:
   ```bash
   # Get your machine's IP
   make mobile-ip
   
   # Update environment.dart with your IP
   # Run the app
   flutter run -d <device-id>
   ```

## 🌐 Web Testing

### Chrome

```bash
# Start backend
make dev-backend

# Run Flutter web
cd enterprise-auth-template/flutter_auth_template
flutter run -d chrome
```

### Other Browsers

```bash
# Build web app
flutter build web

# Serve with any HTTP server
cd build/web
python -m http.server 3000
# Open http://localhost:3000
```

## 🔧 Configuration

### Update API Endpoint

Edit `lib/config/environment.dart`:

```dart
class DeviceTestConfig {
  static String getMachineIP() {
    // Update with your machine's IP
    return '192.168.1.100';
  }
}
```

### Backend CORS Configuration

Ensure your backend `.env` includes mobile origins:

```env
CORS_ORIGINS=["http://localhost:3000","http://10.0.2.2:3000","http://192.168.1.100:3000"]
```

## 🧪 Test Accounts

Use these accounts for testing:

| Role    | Email                      | Password     | 2FA |
|---------|----------------------------|--------------|-----|
| Admin   | admin@example.com          | Admin123!@#  | No  |
| User    | john.doe@example.com       | User123!@#   | No  |
| Manager | jane.manager@example.com   | Manager123!@# | Yes |

## 🐛 Troubleshooting

### Connection Refused

**Problem**: App can't connect to backend

**Solutions**:
1. Check backend is running: `docker ps`
2. Verify correct IP in environment.dart
3. Check firewall settings
4. Ensure same network (physical devices)

### Android Specific

```bash
# Clear app data
adb shell pm clear com.enterprise.auth.flutter_auth_template

# Check logs
adb logcat | grep flutter

# Reinstall app
flutter clean
flutter run
```

### iOS Specific

```bash
# Reset simulator
xcrun simctl erase all

# Clear derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Check provisioning profiles
open ~/Library/MobileDevice/Provisioning\ Profiles
```

### Network Issues

```bash
# Test backend is accessible
curl http://localhost:8000/health

# Test from device perspective (Android)
adb shell curl http://10.0.2.2:8000/health

# Check CORS headers
curl -H "Origin: http://localhost:3000" \
     -I http://localhost:8000/api/v1/auth/login
```

## 📊 Performance Testing

### Profile Mode

```bash
# Run in profile mode for performance analysis
flutter run --profile

# Use Flutter DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Memory Profiling

```bash
# Monitor memory usage
flutter run --trace-startup --profile
```

## 🔄 Hot Reload vs Hot Restart

- **Hot Reload** (r): Updates UI preserving state
- **Hot Restart** (R): Restarts app losing state
- **Full Restart**: Stop and run again

## 📝 Debugging Tips

1. **Enable verbose logging**:
   ```dart
   // In main.dart
   if (kDebugMode) {
     debugPrint('Debug message');
   }
   ```

2. **Network debugging**:
   ```dart
   // Add to Dio client
   dio.interceptors.add(LogInterceptor(
     requestBody: true,
     responseBody: true,
   ));
   ```

3. **State inspection**:
   - Use Flutter Inspector
   - Add Redux DevTools for state
   - Use Riverpod Observer

## 🚢 Building for Release

### Android APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
flutter build ios --release
# Then archive in Xcode
```

## 📱 Device-Specific Features

### Biometric Authentication

- ✅ Android: Fingerprint, Face
- ✅ iOS: Touch ID, Face ID
- ❌ Web: Not supported (use WebAuthn)

### Push Notifications

- ✅ Android: FCM
- ✅ iOS: APNs
- ⚠️ Web: Limited support

### Deep Linking

- ✅ Android: App Links
- ✅ iOS: Universal Links
- ✅ Web: Regular URLs

---

## Need Help?

- Check logs: `make logs-backend`
- View API docs: http://localhost:8000/docs
- Flutter Inspector: In VS Code/Android Studio
- Report issues: GitHub Issues