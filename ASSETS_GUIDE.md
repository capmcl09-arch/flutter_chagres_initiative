# Flutter App Image & Asset Setup Guide

This guide explains how to set up images and assets for the Chagres Initiative Flutter app.

## Adding Local Images

### Step 1: Create Assets Directory

```bash
mkdir -p assets/images
```

### Step 2: Copy Images

Copy your image files to the `assets/images/` directory:
```
assets/
└── images/
    ├── hero.jpg
    ├── palms.jpg
    ├── jayhawk.png
    ├── arlington_mini.png
    ├── labonga_seal.png
    ├── team/
    │   ├── peter1.jpg
    │   ├── cap.png
    │   ├── sam.jpg
    │   ├── taylor.jpg
    │   └── ...
    └── gallery/
        ├── lancha.jpg
        ├── field_tour.jpg
        └── ...
```

### Step 3: Update pubspec.yaml

Add assets declaration to `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/images/team/
    - assets/images/gallery/
```

### Step 4: Update Code

Replace network image URLs with local assets:

**Before:**
```dart
Image.network(
  'https://images.unsplash.com/photo-1489749798305-4fea3ba63d60?w=800&h=500&fit=crop',
  height: 250,
)
```

**After:**
```dart
Image.asset(
  'assets/images/lancha.jpg',
  height: 250,
  fit: BoxFit.cover,
)
```

## Updating Content

### Modify Text Content

Edit the section widgets in `lib/main.dart`. Each section has English (en) and Spanish (es) support:

```dart
Text(
  language == 'en' 
    ? 'English text here'
    : 'Texto en español aquí',
)
```

### Update Team Members

Find the `Team Section` class and modify the `team` list:

```dart
final team = [
  ('Name', 'Position', 'email@example.com', 'Institution'),
  // Add more team members...
];
```

### Update FAQ Questions

Modify the `FAQSection` widget's `faqs` list to add or update questions.

### Links & External URLs

Modify these endpoints:
- Donation: `https://geog.ku.edu/donate`
- Google Maps: Update coordinates in `MapsSection`
- Documents: Update PDF URLs in `AuthorizationSection`

## Image Optimization

### Sizing Recommendations

- **Hero Image**: 1200x400px (3:1 ratio)
- **Team Avatars**: 72x72px (1:1 square)
- **Gallery Images**: 800x600px minimum
- **Map Embed**: 16:9 aspect ratio

### File Formats

- **Photos**: JPG/JPEG (good compression)
- **Logos**: PNG (transparency support)
- **Icons**: PNG or SVG

### Compression

Use tools like:
- [ImageOptim](https://imageoptim.com/) - Mac
- [TinyPNG](https://tinypng.com/) - Online
- [FFmpeg](https://ffmpeg.org/) - Command line

```bash
# Reduce image size
ffmpeg -i input.jpg -vf scale=800:-1 -q:v 8 output.jpg
```

## Handling Large Image Sets

For the gallery carousel with many images, consider:

1. **Lazy Loading**: Load images as needed
2. **Caching**: Use `Image.network` with `cacheHeight` and `cacheWidth`
3. **Dynamic URLs**: Load from API instead of bundling

Example with better performance:
```dart
Image.network(
  imageUrl,
  cacheHeight: 500,
  cacheWidth: 800,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    return const Center(child: CircularProgressIndicator());
  },
)
```

## Web Deployment

### Option 1: Firebase Hosting

```bash
# Build web version
flutter build web --release

# Deploy (requires Firebase setup)
firebase deploy
```

### Option 2: GitHub Pages

```bash
# Build for web
flutter build web --release

# Copy to docs folder
cp -r build/web/* docs/

# Commit and push to enable Pages
```

### Option 3: Netlify

1. Connect GitHub repo to Netlify
2. Set build command: `flutter build web`
3. Set publish directory: `build/web`

## Mobile App Distribution

### iOS (App Store)

1. Build: `flutter build ipa`
2. Sign certificate
3. Upload to App Store Connect

### Android (Google Play)

1. Build: `flutter build appbundle`
2. Sign with keystore
3. Upload to Google Play Console

## Testing Images Locally

```bash
flutter run -d chrome --web-renderer html
```

Then test:
- Image loading
- Responsive sizing
- Carousel navigation
- Scroll performance

## Troubleshooting

### Images Not Showing

1. Check path in pubspec.yaml
2. Verify file exists: `ls -la assets/images/`
3. Run: `flutter pub get && flutter clean && flutter run`

### Large App Size

1. Use PNG for logos only
2. Compress all JPGs
3. Remove unused images
4. Use image cache: `ImageCache().clear()`

### Slow Scroll Performance

1. Use `Image.asset` instead of `Image.network`
2. Add `cacheHeight` and `cacheWidth`
3. Use placeholder widgets during loading
4. Reduce image dimensions

## Resources

- [Flutter Images Documentation](https://flutter.dev/docs/development/ui/assets-and-images)
- [Image Optimization Guide](https://web.dev/image-optimization/)
- [Responsive Images in Flutter](https://flutter.dev/docs/development/ui/layout/responsive)
