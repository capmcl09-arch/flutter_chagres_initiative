# Configuration Reference - Chagres Flutter App

This document lists all configurable elements that may need updating as the project evolves.

## External Links

### Donation Links
**Location**: Multiple places in `main.dart`

```dart
launchUrl(Uri.parse('https://geog.ku.edu/donate'));
```

Update the URL to match your funding platform:
- Stripe
- PayPal
- Donorbox
- GiveWP
- Any custom donation page

### Email Addresses

**Team Members** (TeamSection widget):
```dart
cmclineyjr@ku.edu
herlihy@ku.edu
ahippe@ku.edu
sam.morrow@ku.edu
taylor.tappan@uta.edu
```

**Format for email links:**
```dart
launchUrl(Uri(scheme: 'mailto', path: email));
```

### Document Links

**Authorization Documents** (AuthorizationSection):
```dart
launchUrl(Uri.parse('https://example.com/Documents/La_Bonga_Cartas.pdf'));
```

Replace with actual PDF URL or file path.

### Maps Integration

**Current**: Google Maps embed
**Location**: MapsSection widget

```dart
'https://www.google.com/maps/embed?pb=!1m18!1m12!...'
```

**To update location:**
1. Go to Google Maps
2. Find location: San Juan Pequení (La Bonga)
3. Click Share → Embed a map
4. Copy iframe src
5. Update URL in MapsSection

**Alternative**: Use Flutter package `google_maps_flutter` for interactive maps

```dart
flutter pub add google_maps_flutter
```

## Content Management

### Text Content

All text content is hardcoded in widgets. To extract to a config file:

**Option 1: Create strings.dart file**
```dart
// lib/strings.dart
class Strings {
  static const en = {
    'about_title': 'About the Initiative',
    'about_text': 'The Chagres Initiative is...',
  };
  static const es = {
    'about_title': 'Sobre la Iniciativa',
    'about_text': 'La Iniciativa Chagres es...',
  };
}
```

**Option 2: Use localization packages**
- `intl`: Official i18n
- `easy_localization`: Community favorite
- `getx`: Built-in i18n

### Navigation Structure

Current: Single-page app with sections
Future: Multi-page app for better organization

```dart
// Example navigation structure
const routes = {
  '/': HomePage(),
  '/about': AboutPage(),
  '/team': TeamPage(),
  '/gallery': GalleryPage(),
  '/faq': FAQPage(),
  '/donate': DonatePage(),
};
```

## Colors & Styling

### Theme Colors

File: `lib/main.dart` (ChagresApp widget)

```dart
Color scheme constants:
--ku-blue: #0051ba
--ku-crimson: #e8000d
--bg: #070c18
--card: #101a2f
--text: #eaf0ff
--muted: #b9c6ea
--line: rgba(255,255,255,.12)
```

**To change theme**:
1. Update ColorScheme in ThemeData
2. Or create separate theme file

```dart
// lib/theme.dart
class ChagresTheme {
  static final light = ThemeData(
    brightness: Brightness.light,
    // ... define light theme
  );
  
  static final dark = ThemeData(
    brightness: Brightness.dark,
    // ... define dark theme
  );
}
```

### Fonts

Current: System fonts (San Francisco, Segoe, Roboto)

To add custom fonts:
```yaml
# pubspec.yaml
flutter:
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/custom-font.ttf
```

Add font in build method:
```dart
fontFamily: 'CustomFont'
```

## Image Assets

### Current Setup
Using network images from Unsplash

### To Use Local Images

1. Create `assets/images/` directory
2. Place images there
3. Update `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/
    - assets/images/team/
    - assets/images/gallery/
```

4. Update code:
```dart
// From this:
Image.network('https://images.unsplash.com/...')

// To this:
Image.asset('assets/images/filename.jpg')
```

## Team Management

### Current Team Structure

```dart
final team = [
  (name, position, email, institution),
];
```

### Adding Team Members

Edit TeamSection in main.dart:
```dart
final team = [
  ('Dr. Peter Herlihy', 'Professor of Geography', 'herlihy@ku.edu', 'University of Kansas'),
  ('New Person', 'New Title', 'email@email.com', 'Institution'),
  // ...
];
```

### Team Categories

Current: All in one grid
Better: Organize by institution

```dart
// Option: Create separate sections
// - University of Kansas Personnel
// - University of Texas at Arlington Personnel
// - La Bonga Personnel
```

## FAQ Management

### Current Structure
Hardcoded in FAQSection widget

### To Manage from File

Create `lib/data/faqs.dart`:
```dart
final faqs_en = [
  ('Question 1?', 'Answer 1'),
  ('Question 2?', 'Answer 2'),
];

final faqs_es = [
  ('¿Pregunta 1?', 'Respuesta 1'),
  ('¿Pregunta 2?', 'Respuesta 2'),
];
```

## Language Management

### Current Languages
- English (en)
- Spanish (es)

### Adding Languages

1. Add language string:
```dart
const lang = {'en', 'es', 'fr'}; // Add 'fr' for French
```

2. Add translations in each Section widget:
```dart
language == 'en' ? 'English'
  : language == 'es' ? 'Español'
  : 'Français'
```

3. Update FooterSection language toggle

## API Integration Points

### Future Enhancements

**Blog Content from CMS:**
```dart
// Example with Firebase
import 'package:cloud_firestore/cloud_firestore.dart';

final posts = FirebaseFirestore.instance
  .collection('blog')
  .where('language', isEqualTo: language)
  .get();
```

**Team Data from Database:**
```dart
// Load dynamically instead of hardcoding
final teamData = await getTeamMembers(language);
```

**Dynamic Galleries:**
```dart
// Load images from cloud storage
final images = await FirebaseStorage.instance
  .ref('gallery/')
  .listAll();
```

## Analytics Setup

### Add Firebase Analytics

```bash
flutter pub add firebase_core firebase_analytics
```

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

void _logEvent(String name) {
  FirebaseAnalytics.instance.logEvent(name: name);
}
```

### Track User Actions
```dart
// Track page views
_logEvent('about_viewed');
_logEvent('donate_clicked');
_logEvent('language_changed_to_es');
```

## Performance Configuration

### Image Caching

```dart
// Configure cache
ImageCache imageCache = ImageCache();
imageCache.maximumSize = 100; // KB
imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50 MB
```

### Scrolling Performance

```dart
// For large lists, use ListView instead of Column
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

## Internationalization Best Practices

### File Structure
```
lib/
├── l10n/              # Localization files
│   ├── app_en.arb
│   ├── app_es.arb
│   └── app_fr.arb
├── models/
└── main.dart
```

### Using ARB (Application Resource Bundle)

```json
// lib/l10n/app_en.arb
{
  "@@locale": "en",
  "appTitle": "The Chagres Initiative",
  "aboutTitle": "About the Initiative",
  "aboutText": "The Chagres Initiative is..."
}
```

Then use in code:
```dart
import 'package:flutter_localizations/flutter_localizations.dart';

Text(AppLocalizations.of(context)!.appTitle)
```

## Building Environment-Specific Apps

### Development
```bash
flutter run --dart-define=FLAVOR=dev
```

### Staging
```bash
flutter build apk --dart-define=FLAVOR=staging
```

### Production
```bash
flutter build apk --dart-define=FLAVOR=prod --release
```

Access in code:
```dart
const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
```

## Version Management

Update in `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

Format: `major.minor.patch+buildNumber`
- Major: Breaking changes
- Minor: New features
- Patch: Bug fixes
- Build: Increment each release

## Security Considerations

### API Keys & Secrets

**Never commit secrets!**

Option 1: Environment variables
```bash
export API_KEY=secret_key
flutter run --dart-define=API_KEY=$API_KEY
```

Option 2: Use flutter_dotenv
```bash
flutter pub add flutter_dotenv
```

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  dotenv.load();
  runApp(const ChagresApp());
}

String apiKey = dotenv.env['API_KEY']!;
```

### URLScheme Security

Current implementation safely uses `url_launcher`. For custom schemes:
```dart
// Good
launchUrl(Uri(scheme: 'mailto', path: email));

// Avoid
launchUrl(Uri.parse('javascript:alert(...)'));
```

## Testing Configuration

### Widget Tests

Create `test/main_test.dart`:
```dart
testWidgets('HeroSection displays title', (WidgetTester tester) async {
  await tester.pumpWidget(const ChagresApp());
  expect(find.text('The Chagres Initiative'), findsOneWidget);
});
```

Run tests:
```bash
flutter test
```

### Integration Tests

Create `integration_test/app_test.dart` for end-to-end testing.

## Metrics & Monitoring

### Error Tracking

Integrate with Sentry:
```bash
flutter pub add sentry_flutter
```

```dart
Sentry.captureException(exception, stackTrace: stackTrace);
```

### Performance Monitoring

Use Flutter DevTools:
```bash
flutter run --profile
```

Then press "p" to toggle performance overlay.

---

**For More Information**: See other documentation files (FLUTTER_CONVERSION.md, ASSETS_GUIDE.md, QUICK_START.md)
