# The Chagres Initiative - Flutter Conversion

This is a complete conversion of the original HTML site (`old_reference.html`) into a responsive Flutter mobile application.

## Overview

The Flutter app maintains all the same content, visual style, and functionality of the original HTML site while providing a native mobile experience that adapts beautifully to phones, tablets, and desktop screens.

## Key Features

✅ **Responsive Design**: Automatically adapts to mobile, tablet, and desktop screens
✅ **Bilingual Support**: Switch between English and Spanish seamlessly
✅ **Dark Theme**: Matches the original design with KU Blue (#0051BA) and Crimson (#E8000D)
✅ **Mobile Navigation**: Bottom navigation bar on mobile, header navigation on desktop
✅ **Interactive Elements**: Expandable FAQs, image carousel, language switching
✅ **External Links**: Donate buttons and team contact links work seamlessly
✅ **Smooth Scrolling**: Native scrolling experience optimized for mobile devices

## Sections Implemented

1. **Hero Section** - Title and call-to-action for donations
2. **About Section** - Project overview and mission
3. **Meaningful Section** - Core principles and values (4 principles)
4. **Authorization Section** - Project legal authorization
5. **Methodology Section** - 4-stage participatory research process
6. **Gallery Section** - Image carousel with previous/next controls
7. **Maps Section** - Location overview with Google Maps link
8. **Reports Section** - Field blog and official reports
9. **FAQ Section** - Expandable frequently asked questions
10. **Donate Section** - Donation information and button
11. **Team Section** - Research team member cards with contact info
12. **Footer** - Copyright, language toggle

## Project Structure

```
lib/
├── main.dart              # Main app entry point with all widgets
│   ├── ChagresApp         # Root StatefulWidget
│   ├── ChagresHome        # Main home page widget
│   ├── HeroSection        # Hero/banner section
│   ├── AboutSection       # Project overview
│   ├── MeaningfulSection  # Core principles
│   ├── AuthorizationSection # Legal authorization
│   ├── MethodologySection # Research methodology
│   ├── GallerySection     # Photo carousel
│   ├── MapsSection        # Location maps
│   ├── ReportsSection     # Field reports
│   ├── FAQSection         # FAQ with expandable items
│   ├── DonateSection      # Donation section
│   ├── TeamSection        # Team member cards
│   └── FooterSection      # Footer with language toggle
```

## Design System

**Colors:**
- Background: `#070C18` (Dark Blue)
- Card Background: `#101A2F` (Darker Blue)
- Text Primary: `#EAF0FF` (Light Blue-White)
- Text Muted: `#B9C6EA` (Muted Blue)
- Primary Brand: `#0051BA` (KU Blue)
- Accent: `#E8000D` (KU Crimson)

**Typography:**
- Display titles use serif font (Times New Roman style)
- Body text uses system font (San Francisco, Segoe, Roboto)
- Responsive font sizes across breakpoints

## Running the App

### Prerequisites
- Flutter 3.11.0 or higher
- Dart 3.11.1 or higher

### Commands

**Get dependencies:**
```bash
flutter pub get
```

**Run on device/emulator:**
```bash
flutter run
```

**Run on specific platform:**
```bash
flutter run -d chrome          # Web
flutter run -d ios             # iOS device
flutter run -d android-generic # Android emulator
```

**Build for release:**
```bash
flutter build apk     # Android
flutter build ios     # iOS
flutter build web     # Web
```

## Responsive Breakpoints

- **Mobile**: < 800px width
  - Single column layouts
  - Bottom navigation bar
  - Compact header with app bar
  
- **Tablet/Desktop**: ≥ 800px width
  - Multi-column grids
  - Desktop header with navigation
  - Wider content padding

## Internationalization

The app includes basic English/Spanish support through the `language` parameter:
- **English**: Default language
- **Español**: Spanish translation

To add more languages:
1. Add more translation strings in each Section widget
2. Extend the language selection logic in `FooterSection`

## Dependencies

- **flutter**: UI framework
- **url_launcher**: Open URLs and send emails
- **cupertino_icons**: iOS-style icons (optional)

## Migration Notes from HTML

| Feature | HTML | Flutter |
|---------|------|---------|
| Navigation | Sticky header with dropdown | Header (desktop) + Bottom nav (mobile) |
| Images | Linked from `images/` folder | Using placeholder images from Unsplash |
| Styling | CSS variables & classes | Material Design 3 color scheme |
| Carousel | JavaScript-controlled | Built-in StatefulWidget |
| Responsive | CSS media queries | Flutter layout widgets |
| Language | HTML data-i18n attributes | Conditional build based on language state |

## Future Enhancements

- [ ] Load images from local assets instead of URLs
- [ ] Add PDF document viewer for authorization documents
- [ ] Implement offline support
- [ ] Add dark/light theme toggle
- [ ] Create separate pages/routes for deep linking
- [ ] Add analytics tracking
- [ ] Implement video support for field content
- [ ] Add sharing functionality
- [ ] Integrate with Firestore for blog content
- [ ] Add notifications for project updates

## Browser/Platform Support

- **iOS**: 11.0+
- **Android**: 5.0 (API 21)+
- **Web**: Chrome, Firefox, Safari, Edge
- **macOS**: 10.11+
- **Windows**: Windows 7+
- **Linux**: Ubuntu 18.04+

## Contact & Attribution

- Original HTML Design: The Chagres Initiative Team
- Flutter Conversion: 2026
- Based on: `old_reference.html`

## License

Maintain the same license as the original project.
