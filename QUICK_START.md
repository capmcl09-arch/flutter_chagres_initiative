# Quick Start Guide - Chagres Flutter App

## What is This?

This is a mobile-friendly version of The Chagres Initiative website, built with Flutter. It works on phones, tablets, and web browsers while maintaining the look and feel of the original HTML site.

## Installation & Setup

### 1. Install Flutter

If you don't have Flutter installed, download it:
https://flutter.dev/docs/get-started/install

### 2. Get Dependencies

```bash
cd /Users/capmcliney/Desktop/chagres_flutter_site
flutter pub get
```

### 3. Run the App

**On Android Emulator:**
```bash
flutter run -d android-generic
```

**On iOS Simulator:**
```bash
flutter run -d ios
```

**On Web Browser:**
```bash
flutter run -d chrome
```

**On Physical Device:**
```bash
flutter run
```

## Building for Distribution

### Android App (.apk or .aab)

```bash
# Debug APK
flutter build apk

# Release APK
flutter build apk --release

# App Bundle (for Google Play)
flutter build appbundle --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS App

```bash
# Build for testing
flutter build ios

# Build for App Store
flutter build ipa --release
```

### Web App

```bash
flutter build web --release
```

Output: `build/web/`

## Customization

### Change Content

Edit `lib/main.dart` and modify the text in each section widget. Content is organized as:
- Hero section (title & CTA)
- About, Meaningful, Authorization sections
- Methodology, Gallery, Maps sections
- Reports, FAQ, Donate, Team sections

### Change Images

1. Create `assets/images/` folder
2. Place image files there
3. Update `pubspec.yaml` to include assets
4. Replace `Image.network()` calls with `Image.asset()`

See `ASSETS_GUIDE.md` for detailed instructions.

### Update Links

- **Donation URL**: Search "geog.ku.edu/donate" in main.dart
- **Google Maps**: Update coordinates in `MapsSection`
- **Email addresses**: Update in `TeamSection`
- **PDF documents**: Update in `AuthorizationSection`

### Change Colors

Color constants are defined at the top of each widget. Main colors:
```
Primary Background: #070C18
Card Background: #101A2F
Text Primary: #EAF0FF
Text Muted: #B9C6EA
KU Blue: #0051BA
KU Crimson: #E8000D
```

Change these `Color` values throughout the file.

## Project Structure

```
chagres_flutter_site/
├── lib/
│   └── main.dart              # All app code (2000+ lines)
├── pubspec.yaml               # Dependencies & assets
├── FLUTTER_CONVERSION.md       # Detailed conversion guide
├── ASSETS_GUIDE.md            # Image setup instructions
├── QUICK_START.md             # This file
├── android/                   # Android native code
├── ios/                       # iOS native code
├── web/                       # Web files
├── test/                      # Tests
├── build/                     # Build outputs
└── old_reference.html         # Original HTML for reference
```

## Key Features

✅ **Responsive**: Works on phones, tablets, websites
✅ **Bilingual**: English & Spanish support
✅ **Mobile-First**: Optimized for touch
✅ **Native Performance**: Compiled to native code
✅ **Offline Ready**: Can work without internet (needs local images)
✅ **Accessible**: Supports screen readers

## Useful Commands

```bash
# Clean build artifacts
flutter clean

# Check project for issues
flutter analyze

# Run unit tests
flutter test

# Get useful info
flutter doctor

# Update dependencies
flutter pub upgrade

# Format code
flutter format lib/

# Generate documentation
dartdoc

# Check app size
flutter build apk --split-per-abi
```

## Testing on Different Devices

### Emulators

```bash
# List available devices
flutter devices

# Launch emulator
emulator -avd emulator_name

# Run on specific device
flutter run -d device_id
```

### Physical Devices

1. Connect via USB
2. Enable Developer Mode
3. Run: `flutter run`

### Web Testing

Test responsive behavior:
```bash
# Run on web
flutter run -d chrome

# Open DevTools (F12) and test different screen sizes
```

## Deployment Options

### 1. Google Play Store (Android)

1. Create Google Play Console account
2. Prepare app signing: `keytool -genkey -v -keystore...`
3. Build: `flutter build appbundle --release`
4. Upload to Play Console

### 2. Apple App Store (iOS)

1. Create App Store Connect account
2. Code signing certificates required
3. Build: `flutter build ipa --release`
4. Upload using Transporter

### 3. Website Hosting

For web version, upload `build/web/` to:
- **Firebase Hosting**: `firebase deploy`
- **Netlify**: Connect GitHub repo, auto-deploy
- **GitHub Pages**: Push to gh-pages branch
- **Any Web Server**: Upload HTML/CSS/JS files

## Troubleshooting

### App Won't Start

```bash
flutter clean
flutter pub get
flutter run -v  # Verbose output to see errors
```

### Images Not Loading

1. Check `pubspec.yaml` has assets section
2. Verify image files exist in correct folder
3. Run: `flutter pub get`

### Slow Performance

1. Use `--release` flag when testing
2. Reduce image sizes
3. Profile with DevTools: `flutter run --profile`

### Build Errors

```bash
# Update dependencies
flutter pub upgrade

# Check for SDK issues
flutter doctor

# Clear cache
rm -rf ~/.dartServer*
```

## Development Tips

### Monitor Code Quality

```bash
flutter analyze         # Find issues
flutter format lib/     # Auto-format code
```

### Debug Mode

Press keys when app is running:
- `l` - Reload code
- `L` - Full restart
- `p` - Toggle performance overlay
- `i` - Detailed layer info
- `w` - Dump widget tree
- `t` - Dump rendering tree
- `R` - Hot reload

### State Management

Current app uses simple `setState()`. For larger apps, consider:
- Provider package
- GetX
- Riverpod
- MobX

### Adding Features

1. Create new widget class in `main.dart`
2. Add it to the `Column` in `ChagresHome`
3. Pass required parameters (language, callbacks)
4. Test on multiple screen sizes

## Getting Help

- **Flutter Docs**: https://flutter.dev/docs
- **Stack Overflow**: Tag with `flutter`
- **Flutter Community**: https://github.com/flutter/flutter/wiki
- **DartPad**: https://dartpad.dev (try code snippets)

## Next Steps

1. ✅ Download Flutter
2. ✅ Run `flutter pub get`
3. ✅ Run `flutter run`
4. ✅ Customize content
5. ✅ Test on devices
6. ✅ Deploy to stores

## Contact

For questions about this conversion, refer to the original HTML site documentation or Flutter documentation.

---

**Last Updated**: March 2026
**Flutter Version**: 3.11+
**Documentation**: See FLUTTER_CONVERSION.md for detailed information
