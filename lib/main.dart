import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:html' as html;
import 'dart:ui' as dart_ui;
import 'dart:ui_web' as ui;
import 'dart:math' as math;
import 'dart:convert';

const String _donationPageUrl =
    'https://launchku.org/campaigns/chagres-initiative-safeguarding-panama-canal-water-security-through-indigenous-rainforest-stewardship';
const Color _kuBlue = Color(0xFF1D53B3);
const String _kuLogoBlueAsset = 'assets/images/KU_LOGO_BLUE.jpg';
const String _revisedBadgeLogoAsset = 'assets/images/logo_badge_revised.png';

void _openDonationPage() {
  launchUrl(Uri.parse(_donationPageUrl));
}

void main() {
  // Register the Google Maps iframe view factory for web
  ui.platformViewRegistry.registerViewFactory(
    'google-maps-embed',
    (int viewId) => html.IFrameElement()
      ..src =
          'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3949.823992608622!2d-79.5241626!3d9.3827301!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x8fab494a734c2493%3A0xe55e405b5412d0dc!2sSan%20Juan%20de%20Pequen%C3%AD%20Ind%C3%ADgena%20(La%20Bonga)!5e1!3m2!1sen!2sus!4v1730000000000'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..setAttribute('loading', 'lazy')
      ..setAttribute('referrerpolicy', 'no-referrer-when-downgrade')
      ..setAttribute('allowfullscreen', '')
      ..setAttribute('title', 'San Juan de Pequení Indígena (La Bonga)'),
  );

  runApp(const ChagresApp());
}

// Helper: splits text on "Chagres Initiative" / "Iniciativa Chagres" and italicizes those spans.
List<InlineSpan> _buildCISpans(String text, TextStyle? baseStyle) {
  const ciEN = 'Chagres Initiative';
  const ciES = 'Iniciativa Chagres';
  final spans = <InlineSpan>[];
  String remaining = text;
  while (remaining.isNotEmpty) {
    final enIdx = remaining.indexOf(ciEN);
    final esIdx = remaining.indexOf(ciES);
    int idx = -1;
    String ciWord = '';
    if (enIdx >= 0 && (esIdx < 0 || enIdx <= esIdx)) {
      idx = enIdx;
      ciWord = ciEN;
    } else if (esIdx >= 0) {
      idx = esIdx;
      ciWord = ciES;
    }
    if (idx < 0) {
      spans.add(TextSpan(text: remaining, style: baseStyle));
      break;
    }
    if (idx > 0) {
      spans.add(TextSpan(text: remaining.substring(0, idx), style: baseStyle));
    }
    spans.add(
      TextSpan(
        text: ciWord,
        style: (baseStyle ?? const TextStyle()).copyWith(
          fontStyle: FontStyle.italic,
        ),
      ),
    );
    remaining = remaining.substring(idx + ciWord.length);
  }
  return spans;
}

class ChagresApp extends StatefulWidget {
  const ChagresApp({super.key});

  @override
  State<ChagresApp> createState() => _ChagresAppState();
}

class _ChagresAppState extends State<ChagresApp> {
  String _language = 'en';

  void _setLanguage(String lang) {
    setState(() {
      _language = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chagres Initiative',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'serif',
        scaffoldBackgroundColor: const Color(0xFF0C1328),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0C1328),
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0051ba),
          brightness: Brightness.dark,
          background: const Color(0xFF0C1328),
          surface: const Color(0xFF101A2F),
        ),
        // Unified section heading: every section title across the site uses
        // headlineSmall (or displaySmall for About), so force both to the
        // same prominent spec. Individual call sites keep applying `color:
        // Colors.white` via copyWith, which is all they need.
        textTheme: ThemeData.dark().textTheme.copyWith(
          headlineSmall: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            height: 1.2,
          ),
          displaySmall: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            height: 1.2,
          ),
        ),
      ),
      home: ChagresHome(language: _language, onLanguageChanged: _setLanguage),
    );
  }
}

class ChagresHome extends StatefulWidget {
  final String language;
  final Function(String) onLanguageChanged;

  const ChagresHome({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  @override
  State<ChagresHome> createState() => _ChagresHomeState();
}

class _ChagresHomeState extends State<ChagresHome> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;
  String _activeSection = '';
  bool _showJayhawk = true;
  bool _showLanguageToggle = true;
  double _screenHeight = 800.0;

  // GlobalKey references for each section
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _methodologyKey = GlobalKey();
  final GlobalKey _fieldworkKey = GlobalKey();
  final GlobalKey _teamKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();
  final GlobalKey _partnershipsKey = GlobalKey();
  final GlobalKey _projectMapsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _screenHeight = MediaQuery.of(context).size.height);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache images for faster loading
    precacheImage(
      const AssetImage('assets/images/chagres_initiative_logo_hq.png'),
      context,
    );
    precacheImage(const AssetImage(_revisedBadgeLogoAsset), context);
    precacheImage(const AssetImage('assets/images/jayhawk.png'), context);
    precacheImage(const AssetImage(_kuLogoBlueAsset), context);
    precacheImage(const AssetImage('assets/images/Launch_KU.png'), context);
    precacheImage(const AssetImage('assets/images/palms.jpg'), context);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    // Show/hide back-to-top button
    if (_scrollController.offset > 300) {
      if (!_showBackToTop) {
        setState(() => _showBackToTop = true);
      }
    } else {
      if (_showBackToTop) {
        setState(() => _showBackToTop = false);
      }
    }

    // Show jayhawk in nav while hero logo is still on screen
    final showJayhawk = _scrollController.offset < _screenHeight * 0.75;
    if (showJayhawk != _showJayhawk) {
      setState(() => _showJayhawk = showJayhawk);
    }

    // Show language toggle only on the opening page (hero visible).
    final showLanguageToggle = _scrollController.offset < _screenHeight * 0.75;
    if (showLanguageToggle != _showLanguageToggle) {
      setState(() => _showLanguageToggle = showLanguageToggle);
    }

    // Track active section
    _updateActiveSection();
  }

  void _updateActiveSection() {
    final Map<GlobalKey, String> sections = {
      _teamKey: 'Team',
      _aboutKey: 'About',
      _methodologyKey: 'Methodology',
      _fieldworkKey: 'Fieldwork',
      _faqKey: 'FAQ',
    };

    // Find the section whose top has most recently passed the nav threshold (120px).
    // That means: among all sections where top <= 120px, pick the one with the
    // largest (least negative) dy — it's the one currently filling the viewport.
    const double threshold = 120.0;
    String newActiveSection = '';
    double bestY = double.negativeInfinity;

    for (final entry in sections.entries) {
      final ctx = entry.key.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      if (dy <= threshold && dy > bestY) {
        bestY = dy;
        newActiveSection = entry.value;
      }
    }

    if (newActiveSection.isNotEmpty && _activeSection != newActiveSection) {
      setState(() => _activeSection = newActiveSection);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null || !_scrollController.hasClients) return;
    final box = ctx.findRenderObject();
    if (box is! RenderBox) return;
    final viewport = RenderAbstractViewport.of(box);
    final reveal = viewport.getOffsetToReveal(box, 0.0).offset;
    final isMobile = MediaQuery.of(this.context).size.width < 900;
    // Desktop has a ~58px fixed header overlay; leave a small gap so the
    // section title lands just below the ribbon. Mobile uses a Scaffold AppBar
    // so the body already begins below it.
    final headerOffset = isMobile ? 0.0 : 70.0;
    final target = (reveal - headerOffset).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  void _showLogoZoom() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black87,
        child: Stack(
          children: [
            PhotoView(
              imageProvider: const AssetImage(
                'assets/images/chagres_initiative_logo_hq.png',
              ),
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 2.0,
              enableRotation: false,
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: isMobile ? _buildMobileAppBar() : null,
      drawer: isMobile ? _buildMobileDrawer() : null,
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: const Color(0xFF0051BA),
              child: const Icon(Icons.arrow_upward),
            )
          : null,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                if (!isMobile)
                  const SizedBox(height: 58), // Space for fixed header
                HeroSection(language: widget.language),
                RevealOnScroll(
                  child: AboutSection(
                    key: _aboutKey,
                    language: widget.language,
                  ),
                ),
                // Continuous navy + palm-texture band: maps title, two-panel
                // map, community-geographers callout, and the 5-figure stats
                // band all share one textured backdrop so the navy run reads
                // as one section instead of three flat navy slabs.
                _NavyPalmBand(
                  child: Column(
                    children: [
                // Panama Canal / Chagres National Park map — drops in between
                // the About cards and the fact-icons stats band.
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 20 : 60,
                    isMobile ? 36 : 56,
                    isMobile ? 20 : 60,
                    isMobile ? 8 : 12,
                  ),
                  child: RevealOnScroll(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1375),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.language == 'en'
                                  ? 'CHAGRES NATIONAL PARK (CNP):\nPANAMA CANAL WATER SOURCE & INDIGENOUS HOMELAND'
                                  : 'PARQUE NACIONAL CHAGRES (PNC):\nFUENTE DE AGUA DEL CANAL DE PANAMÁ Y HOGAR INDÍGENA',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.playfairDisplay(
                                // Matches the neon-green Chagres NP fill on the
                                // overview map (#47FC23).
                                color: const Color(0xFF47FC23),
                                fontSize: isMobile ? 22 : 32,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: isMobile ? 14 : 18),
                            // Two-panel map: left = Panama country, right =
                            // Chagres NP detail. Side-by-side on desktop,
                            // stacked vertically on phones. Each panel opens a
                            // zoomable full-screen view on tap.
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final stack = constraints.maxWidth < 720;
                                final leftMap = _ZoomableMapPanel(
                                  imagePath:
                                      'assets/images/panama_left_map.png',
                                );
                                final rightMap = _ZoomableMapPanel(
                                  imagePath:
                                      'assets/images/panama_right_map.png',
                                );
                                if (stack) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      leftMap,
                                      const SizedBox(height: 18),
                                      rightMap,
                                    ],
                                  );
                                }
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(child: leftMap),
                                    const SizedBox(width: 24),
                                    Expanded(child: rightMap),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Blue fact figures sit directly below the maps, tightly
                // grouped.
                Container(
                  width: double.infinity,
                  child: RevealOnScroll(
                    child: _SealWithStats(language: widget.language),
                  ),
                ),
                // "Click to View Live Maps" jumps down to the interactive
                // "Project Maps" section; sits below the fact figures.
                Padding(
                  padding: EdgeInsets.only(bottom: isMobile ? 24 : 32),
                  child: Center(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _scrollToSection(_projectMapsKey),
                        child: _HoverGlow(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 22 : 30,
                              vertical: isMobile ? 13 : 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0051BA),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: const Color(0xFF4A90D9),
                                width: 1.4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0051BA,
                                  ).withOpacity(0.32),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.language == 'en'
                                      ? 'Click to View Live Maps'
                                      : 'Haga clic para ver los mapas en vivo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.arrow_downward,
                                  color: Colors.white,
                                  size: isMobile ? 16 : 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // "The Chagres Initiative Solution…" callout — follows the
                // blue fact figures.
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 20 : 60,
                    0,
                    isMobile ? 20 : 60,
                    isMobile ? 48 : 72,
                  ),
                  child: RevealOnScroll(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF152544),
                                Color(0xFF0F1B36),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFE0B660).withOpacity(0.32),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.40),
                                blurRadius: 30,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 24 : 48,
                            vertical: isMobile ? 32 : 44,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                widget.language == 'en'
                                    ? 'The Chagres Initiative Solution…'
                                    : 'La Solución de la Iniciativa Chagres…',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.playfairDisplay(
                                  color: const Color(0xFFE0B660),
                                  fontSize: isMobile ? 22 : 28,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                  height: 1.25,
                                ),
                              ),
                              SizedBox(height: isMobile ? 14 : 20),
                              Container(
                                width: 56,
                                height: 1.5,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFE0B660),
                                      Color(0xFFFFE9A8),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: isMobile ? 16 : 22),
                              Text(
                                widget.language == 'en'
                                    ? 'Develop a participatory research mapping project that converts Indigenous Spatial Knowledge (ISK) into standard geographic information now crucial for the rainforest conservation and Panama Canal Security.'
                                    : 'Desarrollar un proyecto de mapeo de investigación participativa que convierta el Conocimiento Espacial Indígena (ISK) en información geográfica estándar, ahora crucial para la conservación del bosque tropical y la seguridad del Canal de Panamá.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.playfairDisplay(
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                  fontSize: isMobile ? 15 : 17,
                                  height: 1.55,
                                ),
                              ),
                              SizedBox(height: isMobile ? 18 : 24),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => _scrollToSection(
                                    _methodologyKey,
                                  ),
                                  child: _HoverGlow(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 22 : 30,
                                        vertical: isMobile ? 13 : 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0051BA),
                                        borderRadius: BorderRadius.circular(100),
                                        border: Border.all(
                                          color: const Color(0xFF4A90D9),
                                          width: 1.4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF0051BA,
                                            ).withOpacity(0.32),
                                            blurRadius: 20,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            widget.language == 'en'
                                                ? 'PRM Methodology Details'
                                                : 'Detalles de la Metodología PRM',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isMobile ? 14 : 16,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(
                                            Icons.arrow_downward,
                                            color: Colors.white,
                                            size: isMobile ? 16 : 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                    ],
                  ),
                ),
                RevealOnScroll(
                  child: MappingMethodSection(
                    language: widget.language,
                    methodologyKey: _methodologyKey,
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: const Color(0xFF16402E),
                  child: Stack(
                    children: [
                      if (!isMobile)
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: _JungleSideStrip(mirror: false),
                        ),
                      if (!isMobile)
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: _JungleSideStrip(mirror: true),
                        ),
                      RevealOnScroll(
                        child: _MakeDreamsCallout(
                          language: widget.language,
                          onDonate: _openDonationPage,
                        ),
                      ),
                    ],
                  ),
                ),
                // Transition green → navy for Partnerships.
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF16402E), Color(0xFF0C1328)],
                    ),
                  ),
                  height: 60,
                ),
                RevealOnScroll(
                  child: PartnershipsSection(
                    key: _partnershipsKey,
                    language: widget.language,
                  ),
                ),
                RevealOnScroll(
                  child: TeamSection(key: _teamKey, language: widget.language),
                ),
                Container(
                  width: double.infinity,
                  // Soft gradient fade from navy into the second green band.
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF0C1328), Color(0xFF16402E)],
                    ),
                  ),
                  height: 60,
                ),
                Container(
                  width: double.infinity,
                  color: const Color(0xFF16402E),
                  child: Stack(
                    children: [
                      if (!isMobile)
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: _JungleSideStrip(mirror: false),
                        ),
                      if (!isMobile)
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: _JungleSideStrip(mirror: true),
                        ),
                      Column(
                        children: [
                          RevealOnScroll(
                            child: MapsSection(
                              key: _projectMapsKey,
                              language: widget.language,
                            ),
                          ),
                          RevealOnScroll(
                            child: AuthorizationSection(
                              language: widget.language,
                            ),
                          ),
                          RevealOnScroll(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 40,
                                horizontal: 60,
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/community_meeting.jpg',
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    widget.language == 'en'
                                        ? 'The Indigenous Council Meeting of La Bonga as they listen to our team present about PRM.'
                                        : 'La Junta Directiva Indígena de La Bonga escuchando la presentación de nuestro equipo sobre el PRM.',
                                    style: const TextStyle(
                                      color: Color(0xFFB0B8C8),
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          RevealOnScroll(
                            child: GallerySection(
                              key: _fieldworkKey,
                              language: widget.language,
                            ),
                          ),
                          // Field Reports section removed — that content will
                          // live on learn.chagresinitiative.org later.
                          RevealOnScroll(
                            child: FAQSection(
                              key: _faqKey,
                              language: widget.language,
                            ),
                          ),
                          RevealOnScroll(
                            child: NewsletterSection(language: widget.language),
                          ),
                          RevealOnScroll(
                            child: ContactUsSection(language: widget.language),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                FooterSection(
                  language: widget.language,
                  onLanguageChanged: widget.onLanguageChanged,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              ],
            ),
          ),
          if (!isMobile)
            Positioned(top: 0, left: 0, right: 0, child: _buildDesktopHeader()),
          Positioned(
            right: 0,
            top: MediaQuery.of(context).size.height * 0.62,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _openDonationPage,
                child: _HoverGlow(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  scale: 1.04,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 20,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFA0291E),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 8,
                          offset: Offset(-2, 2),
                        ),
                      ],
                    ),
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        widget.language == 'en' ? 'Donate Now' : 'Donar Ahora',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBrand({required bool isMobile}) {
    final kuHeight = isMobile ? 26.0 : 38.0;

    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse('https://ku.edu'),
        mode: LaunchMode.externalApplication,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Image.asset(
          _kuLogoBlueAsset,
          height: kuHeight,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }

  AppBar _buildMobileAppBar() {
    return AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: _buildHeaderBrand(isMobile: true),
      backgroundColor: _kuBlue,
      elevation: 1,
      centerTitle: true,
      actions: _showLanguageToggle
          ? [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor: const Color(0xFF0051BA),
                  ),
                  onPressed: () => widget.onLanguageChanged(
                    widget.language == 'en' ? 'es' : 'en',
                  ),
                  child: Text(
                    widget.language == 'en' ? 'Español' : 'English',
                    style: const TextStyle(fontSize: 14, fontFamily: 'serif'),
                  ),
                ),
              ),
            ]
          : null,
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0C1328),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0051BA)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/chagres_initiative_logo_hq.png',
                  height: 60,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.language == 'en' ? 'Navigation' : 'Navegación',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            widget.language == 'en' ? 'About' : 'Acerca de',
            _aboutKey,
          ),
          _buildDrawerItem(
            widget.language == 'en' ? 'Methodology' : 'Metodología',
            _methodologyKey,
          ),
          _buildDrawerItem(
            widget.language == 'en' ? 'Fieldwork' : 'Trabajo de Campo',
            _fieldworkKey,
          ),
          _buildDrawerItem(
            widget.language == 'en' ? 'Team' : 'Equipo',
            _teamKey,
          ),
          _buildDrawerItem(
            widget.language == 'en' ? 'FAQ' : 'Preguntas Frecuentes',
            _faqKey,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String label, GlobalKey key) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(color: Color(0xFFB9C6EA), fontSize: 16),
      ),
      onTap: () {
        Navigator.of(context).pop(); // Close drawer
        _scrollToSection(key);
      },
    );
  }

  Widget _buildDesktopHeader() {
    return Container(
      color: _kuBlue,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderBrand(isMobile: false),
          const SizedBox(width: 40),
          // Navigation Links
          Wrap(
            spacing: 16,
            children: [
              _buildNavLink('About', _aboutKey),
              _buildNavLink('Methodology', _methodologyKey),
              _buildNavLink('Fieldwork', _fieldworkKey),
              _buildNavLink('Team', _teamKey),
              _buildNavLink('FAQ', _faqKey),
              if (_showLanguageToggle)
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: const Color(0xFF0051BA),
                    ),
                    onPressed: () => widget.onLanguageChanged(
                      widget.language == 'en' ? 'es' : 'en',
                    ),
                    child: Text(
                      widget.language == 'en' ? 'Español' : 'English',
                      style: const TextStyle(fontSize: 15, fontFamily: 'serif'),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String label, GlobalKey key) {
    final isActive = _activeSection == label;
    final displayLabel = _translatedNavLabel(label);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _scrollToSection(key),
        child: Text(
          displayLabel,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFFB9C6EA),
            fontSize: 17,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _translatedNavLabel(String label) {
    if (widget.language == 'en') return label;
    return switch (label) {
      'About' => 'Acerca de',
      'Methodology' => 'Metodología',
      'Fieldwork' => 'Trabajo de Campo',
      'Team' => 'Equipo',
      'FAQ' => 'Preguntas Frecuentes',
      _ => label,
    };
  }
}

// Hero Section - project mark centered on palms
class HeroSection extends StatelessWidget {
  final String language;

  const HeroSection({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final topInset = MediaQuery.paddingOf(context).top;
    // Spanish hero pills are taller (longer phrases wrap to two lines), so
    // pull the whole hero column up a bit more on Spanish phones to keep
    // the news ticker from overlapping the third pill.
    final heroTopPadding = isMobile
        ? (language == 'es' ? topInset : topInset + 9)
        : screenHeight * 0.035;
    final sealMaxWidth = isMobile ? screenWidth * 0.54 : screenWidth * 0.39;
    final sealMaxHeight = isMobile ? screenHeight * 0.42 : screenHeight * 0.63;
    final double jayhawkWidth =
        (isMobile ? screenWidth * 0.28 : screenWidth * 0.22)
            .clamp(96.0, 310.0)
            .toDouble();
    // Match La Bonga's diameter to the Jayhawk's rendered height (950x847
    // image) so their top and bottom edges line up.
    final double laBongaSize = jayhawkWidth * (847 / 950);

    final sealImage = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: sealMaxWidth,
        maxHeight: sealMaxHeight,
      ),
      child: AspectRatio(
        aspectRatio: 1200 / 1440,
        child: Image.asset(
          'assets/images/chagres_oval_seal.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
    final laBongaSeal = _LaBongaSeal(size: laBongaSize, language: language);
    final jayhawkLogo = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: language == 'en'
            ? 'University of Kansas'
            : 'Universidad de Kansas',
        child: GestureDetector(
          onTap: () => launchUrl(
            Uri.parse('https://ku.edu'),
            mode: LaunchMode.externalApplication,
          ),
          child: Image.asset(
            'assets/images/jayhawk.png',
            width: jayhawkWidth,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
    // Phone: seal on top, La Bonga + Jayhawk side by side beneath it.
    // Desktop: La Bonga and Jayhawk flank the seal left and right.
    final Widget heroSealArea = isMobile
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              sealImage,
              const SizedBox(height: 14),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  laBongaSeal,
                  const SizedBox(width: 22),
                  jayhawkLogo,
                ],
              ),
            ],
          )
        : SizedBox(
            width: screenWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: laBongaSeal,
                      ),
                    ),
                  ),
                  sealImage,
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: jayhawkLogo,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

    return Stack(
      children: [
        // Background
        Container(
          width: double.infinity,
          height: screenHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.65),
                Colors.black.withOpacity(0.65),
              ],
            ),
            image: const DecorationImage(
              image: AssetImage('assets/images/palms.jpg'),
              fit: BoxFit.cover,
              opacity: 0.3,
            ),
          ),
        ),
        Positioned(
          top: heroTopPadding,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                heroSealArea,
                SizedBox(
                  height: isMobile ? (language == 'es' ? 12 : 18) : 26,
                ),
                Column(
                  children: [
                    _buildPhrase(
                      context,
                      language == 'en'
                          ? 'Panama Canal Water Security'
                          : 'Seguridad Hídrica del Canal de Panamá',
                    ),
                    const SizedBox(height: 10),
                    _buildPhrase(
                      context,
                      language == 'en'
                          ? 'Rainforest Conservation'
                          : 'Conservación del Bosque Tropical',
                    ),
                    const SizedBox(height: 10),
                    _buildPhrase(
                      context,
                      language == 'en'
                          ? 'Indigenous Community Engagement'
                          : 'Participación de la Comunidad Indígena',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Gradient fade at bottom blending into next section. Horizontal
        // mask reduces opacity in the middle 50% so the centered hero pill
        // and the section card below aren't overlapped by the dark shade.
        // Lifted off the bottom so the news ticker sits flush against the
        // viewport edge. Phones skip it because the shorter viewport leaves
        // it crowding the hero pills.
        if (!isMobile)
          Positioned(
            bottom: 126,
            left: 0,
            right: 0,
            height: 160,
            child: IgnorePointer(
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white,
                    Colors.white,
                    Color(0x33FFFFFF),
                    Color(0x33FFFFFF),
                    Colors.white,
                    Colors.white,
                  ],
                  stops: [0.0, 0.20, 0.30, 0.70, 0.80, 1.0],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xFF0C1328)],
                    ),
                  ),
                ),
              ),
            ),
          ),
        // Canal-news ticker pinned near the bottom of the hero so it's
        // visible on page load. Sourced from docs/news.json (refreshed daily
        // by CI); hides itself if the feed is unavailable. Sits lower on
        // phones where the shorter viewport leaves the hero pills closer to
        // the ticker.
        Positioned(
          bottom: isMobile ? 12 : 80,
          left: 0,
          right: 0,
          child: _NewsTicker(language: language),
        ),
      ],
    );
  }

  Widget _buildPhrase(BuildContext context, String text) {
    return _HeroPhrasePill(text: text);
  }
}

// La Bonga community seal — clickable; tapping reveals its caption. Reused in
// the hero (flanking the project seal) and in the top ribbon.
class _LaBongaSeal extends StatelessWidget {
  final double size;
  final String language;
  const _LaBongaSeal({required this.size, required this.language});

  @override
  Widget build(BuildContext context) {
    final message = language == 'en'
        ? 'The Seal of the Community of La Bonga'
        : 'El Sello de la Comunidad de La Bonga';
    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 3),
      preferBelow: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Image.asset(
          'assets/images/labonga_seal.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class _HeaderProjectMark extends StatelessWidget {
  final String language;
  final bool isMobile;

  const _HeaderProjectMark({required this.language, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size.square(isMobile ? 34 : 44),
          painter: const _ChagresMarkPainter(compact: true),
        ),
        SizedBox(width: isMobile ? 8 : 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              language == 'en' ? 'Chagres' : 'Chagres',
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: isMobile ? 15 : 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                height: 1.0,
              ),
            ),
            Text(
              language == 'en' ? 'Initiative' : 'Iniciativa',
              style: GoogleFonts.cinzel(
                color: const Color(0xFFE8F1FF),
                fontSize: isMobile ? 9 : 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroPlaceholderLogo extends StatelessWidget {
  final String language;

  const _HeroPlaceholderLogo({required this.language});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final title = language == 'en'
        ? 'Chagres Initiative'
        : 'Iniciativa Chagres';
    final subtitle = language == 'en'
        ? 'Water Security | Rainforest Stewardship'
        : 'Seguridad Hidrica | Custodia del Bosque';

    return AspectRatio(
      aspectRatio: isMobile ? 1.55 : 2.45,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 22 : 40,
          vertical: isMobile ? 18 : 30,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF07111F).withOpacity(0.58),
          borderRadius: BorderRadius.circular(isMobile ? 18 : 24),
          border: Border.all(color: Colors.white.withOpacity(0.24), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.42),
              blurRadius: 34,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: isMobile
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomPaint(
                    size: const Size.square(86),
                    painter: const _ChagresMarkPainter(),
                  ),
                  const SizedBox(height: 14),
                  _HeroLogoText(
                    title: title,
                    subtitle: subtitle,
                    centered: true,
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomPaint(
                    size: const Size.square(132),
                    painter: const _ChagresMarkPainter(),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: _HeroLogoText(
                      title: title,
                      subtitle: subtitle,
                      centered: false,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _HeroLogoText extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool centered;

  const _HeroLogoText({
    required this.title,
    required this.subtitle,
    required this.centered,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: centered ? Alignment.center : Alignment.centerLeft,
          child: Text(
            title,
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: isMobile ? 36 : 62,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              height: 1.02,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.55),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            textAlign: centered ? TextAlign.center : TextAlign.left,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 12),
        Text(
          subtitle,
          style: GoogleFonts.cinzel(
            color: const Color(0xFFE8F1FF),
            fontSize: isMobile ? 12 : 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            height: 1.25,
          ),
          textAlign: centered ? TextAlign.center : TextAlign.left,
        ),
        SizedBox(height: isMobile ? 10 : 14),
        Container(
          width: isMobile ? 96 : 150,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            gradient: const LinearGradient(
              colors: [Color(0xFF77A7D9), Color(0xFF7FB069), Color(0xFFFFC766)],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChagresMarkPainter extends CustomPainter {
  final bool compact;

  const _ChagresMarkPainter({this.compact = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final outerPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0051BA), Color(0xFF16402E)],
      ).createShader(Offset.zero & size);

    canvas.drawCircle(center, radius, outerPaint);
    canvas.drawCircle(
      center,
      radius * 0.91,
      Paint()
        ..color = const Color(0xFF07111F).withOpacity(compact ? 0.24 : 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.07,
    );

    final mountainPaint = Paint()..color = const Color(0xFF7FB069);
    final mountainPath = Path()
      ..moveTo(size.width * 0.16, size.height * 0.62)
      ..lineTo(size.width * 0.38, size.height * 0.30)
      ..lineTo(size.width * 0.53, size.height * 0.52)
      ..lineTo(size.width * 0.68, size.height * 0.34)
      ..lineTo(size.width * 0.88, size.height * 0.62)
      ..close();
    canvas.drawPath(mountainPath, mountainPaint);

    final riverPaint = Paint()
      ..color = const Color(0xFF77A7D9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.16
      ..strokeCap = StrokeCap.round;
    final riverPath = Path()
      ..moveTo(size.width * 0.24, size.height * 0.70)
      ..cubicTo(
        size.width * 0.40,
        size.height * 0.58,
        size.width * 0.48,
        size.height * 0.80,
        size.width * 0.70,
        size.height * 0.67,
      );
    canvas.drawPath(riverPath, riverPaint);

    final sunPaint = Paint()..color = const Color(0xFFFFC766);
    canvas.drawCircle(
      Offset(size.width * 0.70, size.height * 0.30),
      radius * 0.12,
      sunPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ChagresMarkPainter oldDelegate) =>
      oldDelegate.compact != compact;
}

class _HeroPhrasePill extends StatefulWidget {
  final String text;
  const _HeroPhrasePill({required this.text});

  @override
  State<_HeroPhrasePill> createState() => _HeroPhrasePillState();
}

class _HeroPhrasePillState extends State<_HeroPhrasePill> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(_hover ? 0.55 : 0.45),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: Colors.white.withOpacity(_hover ? 0.55 : 0.18),
            width: 1,
          ),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: const Color(0xFF81C784).withOpacity(0.35),
                    blurRadius: 22,
                    spreadRadius: 1,
                  ),
                ]
              : const [],
        ),
        child: Text(
          widget.text,
          textAlign: TextAlign.center,
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}

// Partnerships Section
class PartnershipsSection extends StatelessWidget {
  final String language;

  const PartnershipsSection({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final isPhone = screenWidth < 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Image is 3999x2250; calculate its natural contained height
        final imageHeight = constraints.maxWidth * 2250 / 3999;
        // Lancha is 4032x3024 (4:3)
        final lanchaHeight = constraints.maxWidth * 3024 / 4032;
        final lanchaTop = imageHeight;

        return Stack(
          children: [
            // Dark background for content that overflows past image
            Container(width: double.infinity, color: const Color(0xFF0C1328)),
            // Background photos: hidden on phones, shown on tablets/desktop
            if (!isPhone)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: imageHeight,
                child: ShaderMask(
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.75, 1.0],
                    colors: [Colors.white, Colors.white, Color(0x55FFFFFF)],
                  ).createShader(rect),
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    'assets/images/Background_BOAT.jpg',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    color: const Color(0xFF0C1328).withOpacity(0.30),
                    colorBlendMode: BlendMode.srcOver,
                  ),
                ),
              ),
            if (!isPhone)
              Positioned(
                top: lanchaTop,
                left: 0,
                right: 0,
                height: lanchaHeight,
                child: ShaderMask(
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.15, 0.85, 1.0],
                    colors: [
                      Color(0x55FFFFFF),
                      Colors.white,
                      Colors.white,
                      Color(0x55FFFFFF),
                    ],
                  ).createShader(rect),
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    'assets/images/long_lancha.jpeg',
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomRight,
                    filterQuality: FilterQuality.high,
                    color: const Color(0xFF0C1328).withOpacity(0.30),
                    colorBlendMode: BlendMode.srcOver,
                  ),
                ),
              ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                isMobile ? 20.0 : 60.0,
                140,
                isMobile ? 20.0 : 60.0,
                60,
              ),
              child: Column(
                children: [
                  // Donation copy now lives in the combined "Why Donations
                  // Matter" band higher on the page; only the KU/Launch KU
                  // branding remains here, leading into the donate button.
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/jayhawk.png',
                        height: isPhone ? 72 : 96,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: isPhone ? 14 : 22),
                      GestureDetector(
                        onTap: _openDonationPage,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Image.asset(
                            'assets/images/Launch_KU.png',
                            height: isPhone ? 54 : 72,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // "Make Dreams Possible" callout was moved up to a dedicated
                  // section right after the mapping flowchart.
                  const SizedBox(height: 60),
                  // Poem Image — below boat photo seam
                  Image.asset(
                    'assets/images/poem.png',
                    width: isMobile ? 280 : 360,
                    fit: BoxFit.contain,
                    opacity: const AlwaysStoppedAnimation(0.95),
                  ),
                  const SizedBox(height: 32),
                  // Donation button — after Make Dreams section
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _openDonationPage,
                      child: _HoverGlow(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 280),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA0291E),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(0xFFA0291E),
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 18,
                          ),
                          child: Column(
                            children: [
                              language == 'en'
                                  ? Text.rich(
                                      TextSpan(
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: [
                                          const TextSpan(text: 'Please '),
                                          const TextSpan(
                                            text: 'Click',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          const TextSpan(text: ' to '),
                                          const TextSpan(
                                            text: 'Contribute',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  : const Text(
                                      'Haga clic aquí para contribuir',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// About Section — three-card layout: each card holds one core idea with an
// illustrative image, a heading, and a short body. Designed for marketing
// readability over the previous two-paragraph wall of text.
class AboutSection extends StatelessWidget {
  final String language;

  const AboutSection({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth < 600;
    // Two-column layout above 900px; stack below.
    final useTwoColumns = screenWidth >= 900;

    final horizontalPad = isPhone ? 20.0 : (useTwoColumns ? 60.0 : 40.0);
    final verticalPad = isPhone ? 64.0 : 96.0;

    final cards = <_AboutCardData>[
      _AboutCardData(
        illustration: const _CompassPainter(),
        hero: language == 'en' ? 'Exploring…' : 'Explorando…',
        subtitle: language == 'en'
            ? 'Rainforests and Indigenous Communities Thriving at the Heart of the Panama Canal.'
            : 'Bosques tropicales y comunidades indígenas prosperando en el corazón del Canal de Panamá.',
        tagline: '',
        accent: const Color(0xFF77A7D9),
        sentence: '',
        highlights: const [],
        bullets: const [],
      ),
      _AboutCardData(
        illustration: const _MountainPalmsPainter(),
        hero: language == 'en' ? 'Discovering…' : 'Descubriendo…',
        subtitle: language == 'en'
            ? 'Indigenous Territories provide Water Security for Global Panama Canal Trade.'
            : 'Los territorios indígenas brindan seguridad hídrica al comercio global del Canal de Panamá.',
        tagline: '',
        accent: const Color(0xFF7FB069),
        sentence: '',
        highlights: const [],
        bullets: const [],
      ),
      _AboutCardData(
        illustration: const _MapSheetPainter(),
        hero: language == 'en' ? 'Helping…' : 'Ayudando…',
        subtitle: language == 'en'
            ? 'Chagres National Park (CNP) Residents create geographic data needed to protect it & their lands.'
            : 'Los residentes del Parque Nacional Chagres (PNC) crean los datos geográficos necesarios para proteger el parque y sus tierras.',
        tagline: '',
        accent: const Color(0xFFE0B660),
        sentence: '',
        highlights: const [],
        bullets: const [],
      ),
    ];

    final cardsLayout = useTwoColumns
        ? IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < cards.length; i++) ...[
                  Expanded(child: _AboutCard(data: cards[i])),
                  if (i < cards.length - 1) const SizedBox(width: 18),
                ],
              ],
            ),
          )
        : Column(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                _AboutCard(data: cards[i]),
                if (i < cards.length - 1) const SizedBox(height: 20),
              ],
            ],
          );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C1328), Color(0xFF101A2F)],
        ),
      ),
      child: CustomPaint(
        painter: const _CartographicBackdropPainter(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPad,
            vertical: verticalPad,
          ),
          child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                language == 'en'
                    ? 'The Chagres Initiative is…'
                    : 'La Iniciativa Chagres es…',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  color: const Color(0xFFE0B660),
                  fontSize: isPhone ? 28 : 36,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      color: const Color(0xFFE0B660).withOpacity(0.4),
                      blurRadius: 24,
                    ),
                  ],
                ),
              ),
              SizedBox(height: isPhone ? 24 : 32),
              cardsLayout,
            ],
          ),
        ),
      ),
        ),
      ),
    );
  }
}

class _AboutCardData {
  final CustomPainter illustration;
  final String hero;
  final String subtitle;
  final String tagline;
  final Color accent;
  final String sentence;
  final List<String> highlights;
  final List<String> bullets;
  const _AboutCardData({
    required this.illustration,
    required this.hero,
    required this.subtitle,
    required this.tagline,
    required this.accent,
    required this.sentence,
    required this.highlights,
    required this.bullets,
  });
}

/// Splits `text` into TextSpans, gold-italic-styling any substring that matches
/// a `highlight`. First-occurrence wins; matches don't nest.
List<TextSpan> _buildHighlightSpans(
  String text,
  List<String> highlights,
  TextStyle baseStyle,
  TextStyle highlightStyle,
) {
  final spans = <TextSpan>[];
  String remaining = text;
  while (remaining.isNotEmpty) {
    int firstIdx = -1;
    String firstMatch = '';
    for (final h in highlights) {
      final idx = remaining.indexOf(h);
      if (idx >= 0 && (firstIdx < 0 || idx < firstIdx)) {
        firstIdx = idx;
        firstMatch = h;
      }
    }
    if (firstIdx < 0) {
      spans.add(TextSpan(text: remaining, style: baseStyle));
      break;
    }
    if (firstIdx > 0) {
      spans.add(
        TextSpan(text: remaining.substring(0, firstIdx), style: baseStyle),
      );
    }
    spans.add(TextSpan(text: firstMatch, style: highlightStyle));
    remaining = remaining.substring(firstIdx + firstMatch.length);
  }
  return spans;
}

// Gold gradient used for the hero word — gives it a metallic shimmer that
// reads as "luxury editorial" against the dark navy card.
const List<Color> _aboutGoldGradient = [
  Color(0xFFFFE9A8),
  Color(0xFFE0B660),
  Color(0xFFB8851A),
];

class _AboutCard extends StatelessWidget {
  final _AboutCardData data;
  const _AboutCard({required this.data});

  @override
  Widget build(BuildContext context) {
    // Solid gold with a subtle warm glow for that "shiny" feel — no gradient.
    final goldHeroStyle = GoogleFonts.playfairDisplay(
      color: const Color(0xFFE0B660),
      fontSize: 28,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      height: 1.15,
      letterSpacing: 0.5,
      shadows: [
        Shadow(
          color: const Color(0xFFE0B660).withOpacity(0.45),
          blurRadius: 18,
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF152544), Color(0xFF0F1B36)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                // Headline illustration — gold compass / mountains-and-palms.
                SizedBox(
                  width: 108,
                  height: 108,
                  child: CustomPaint(painter: data.illustration),
                ),
                const SizedBox(height: 10),
                // Hero — single solid-gold Text, centered.
                Text(
                  data.hero,
                  textAlign: TextAlign.center,
                  style: goldHeroStyle,
                ),
                const SizedBox(height: 8),
                // Hairline gold rule.
                Container(
                  width: 56,
                  height: 1.5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE0B660), Color(0xFFFFE9A8)],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // White subtitle — continuation of the gold title.
                Text(
                  data.subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                    height: 1.4,
                  ),
                ),
                if (data.tagline.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    data.tagline,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
    );
  }
}

class _AboutBullet extends StatelessWidget {
  final String text;
  final Color accent;
  const _AboutBullet({required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 12),
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFB9C6EA),
              fontSize: 15.5,
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}

// Hand-drawn gold illustrations for the About cards. Drawn at runtime as
// vector strokes/fills so they stay crisp at any size and pick up the
// surrounding card aesthetic.
const Color _aboutGold = Color(0xFFE0B660);
const Color _aboutGoldLight = Color(0xFFFFE9A8);

/// Detailed brass compass, drawn at a 3/4 (tilted) angle so the dial reads as
/// an ellipse rather than a flat circle. All elements stay symmetrically
/// inside the bounding box so the illustration's visual center matches its
/// geometric center.
class _CompassPainter extends CustomPainter {
  const _CompassPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final r = size.shortestSide / 2;
    // Foreshortening factor (1.0 = top-down, lower = more tilted).
    const yScale = 0.66;
    // How thick the visible case rim is below the dial.
    final caseDepth = r * 0.10;
    // Pre-shift the dial center upward by half the case depth so the visual
    // center of the dial+rim composition lands at the geometric center of
    // the SizedBox.
    final cy = size.height / 2 - caseDepth / 2;
    final center = Offset(cx, cy);

    final ringStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.040
      ..strokeCap = StrokeCap.round
      ..color = _aboutGold;
    final hairline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.018
      ..strokeCap = StrokeCap.round
      ..color = _aboutGold.withOpacity(0.85);
    final faintHairline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.010
      ..color = _aboutGold.withOpacity(0.45);

    // Helper — point on an ellipse at compass angle `degrees` (0 = N, clockwise).
    Offset onEllipse(double degrees, double radiusFactor) {
      final a = (degrees - 90) * math.pi / 180; // compass to math
      return Offset(
        cx + math.cos(a) * r * radiusFactor,
        cy + math.sin(a) * r * radiusFactor * yScale,
      );
    }

    // ---- Brass case body (visible rim below the dial) ----
    final caseRect = Rect.fromCenter(
      center: Offset(cx, cy + caseDepth),
      width: r * 1.92,
      height: r * 1.92 * yScale,
    );
    canvas.drawOval(
      caseRect,
      Paint()..color = const Color(0xFFB8851A), // deep brass
    );
    // Highlight along the bottom of the case rim.
    canvas.drawArc(
      caseRect,
      0,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.030
        ..color = const Color(0xFFFFE9A8).withOpacity(0.55),
    );

    // ---- Dial face (top ellipse) ----
    final dialRect = Rect.fromCircle(center: center, radius: r * 0.92);
    final tiltedDialRect = Rect.fromCenter(
      center: center,
      width: dialRect.width,
      height: dialRect.height * yScale,
    );
    // Soft radial gradient inside the face for depth.
    final dialPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.3),
        radius: 0.95,
        colors: const [Color(0xFF1B2A48), Color(0xFF0B1426)],
      ).createShader(tiltedDialRect);
    canvas.drawOval(tiltedDialRect, dialPaint);
    canvas.drawOval(tiltedDialRect, ringStroke);

    // Inner decorative ring.
    final innerDialRect = Rect.fromCenter(
      center: center,
      width: r * 1.55,
      height: r * 1.55 * yScale,
    );
    canvas.drawOval(innerDialRect, hairline);

    // Faint compass-rose enclosure ring.
    final roseRingRect = Rect.fromCenter(
      center: center,
      width: r * 1.10,
      height: r * 1.10 * yScale,
    );
    canvas.drawOval(roseRingRect, faintHairline);

    // ---- Degree ticks: long every 30°, short every 15° between ----
    for (int i = 0; i < 24; i++) {
      final degrees = i * 15.0;
      final isMajor = i % 2 == 0;
      final outer = onEllipse(degrees, 0.92);
      final inner = onEllipse(degrees, isMajor ? 0.80 : 0.86);
      canvas.drawLine(outer, inner, isMajor ? hairline : faintHairline);
    }

    // ---- Cardinal labels (N E S W) inside the inner ring ----
    void drawLabel(String letter, double degrees, double radiusFactor) {
      final pos = onEllipse(degrees, radiusFactor);
      final tp = TextPainter(
        text: TextSpan(
          text: letter,
          style: TextStyle(
            color: letter == 'N' ? _aboutGoldLight : _aboutGold,
            fontSize: r * 0.16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2),
      );
    }

    drawLabel('N', 0, 0.66);
    drawLabel('E', 90, 0.70);
    drawLabel('S', 180, 0.66);
    drawLabel('W', 270, 0.70);

    // ---- Compass rose: 4-point primary star (N/E/S/W) + 4-point intercardinals ----
    void drawPetal({
      required double angleDeg,
      required double outerR,
      required double sideR,
      required double sideSpread,
      required Color color,
    }) {
      final tip = onEllipse(angleDeg, outerR);
      final left = onEllipse(angleDeg - sideSpread, sideR);
      final right = onEllipse(angleDeg + sideSpread, sideR);
      final petal = Path()
        ..moveTo(cx, cy)
        ..lineTo(left.dx, left.dy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(right.dx, right.dy)
        ..close();
      canvas.drawPath(petal, Paint()..color = color);
      canvas.drawPath(petal, hairline);
    }

    // Intercardinal (smaller, drawn first so they sit behind cardinals).
    for (final ang in const [45.0, 135.0, 225.0, 315.0]) {
      drawPetal(
        angleDeg: ang,
        outerR: 0.36,
        sideR: 0.10,
        sideSpread: 25,
        color: _aboutGold.withOpacity(0.45),
      );
    }
    // Cardinal (larger, primary star points).
    drawPetal(
      angleDeg: 0,
      outerR: 0.50,
      sideR: 0.12,
      sideSpread: 18,
      color: _aboutGoldLight,
    );
    drawPetal(
      angleDeg: 90,
      outerR: 0.50,
      sideR: 0.12,
      sideSpread: 18,
      color: _aboutGold,
    );
    drawPetal(
      angleDeg: 180,
      outerR: 0.50,
      sideR: 0.12,
      sideSpread: 18,
      color: _aboutGold.withOpacity(0.7),
    );
    drawPetal(
      angleDeg: 270,
      outerR: 0.50,
      sideR: 0.12,
      sideSpread: 18,
      color: _aboutGold,
    );

    // ---- Center hub (brass screw cap) ----
    canvas.drawCircle(center, r * 0.06, Paint()..color = _aboutGoldLight);
    canvas.drawCircle(center, r * 0.06, hairline);
    // Tiny screw slot.
    canvas.drawLine(
      Offset(cx - r * 0.04, cy),
      Offset(cx + r * 0.04, cy),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.015
        ..color = const Color(0xFFB8851A),
    );
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) => false;
}

class _MountainPalmsPainter extends CustomPainter {
  const _MountainPalmsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final s = size.shortestSide;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.025
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = _aboutGold;
    final thin = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.018
      ..strokeCap = StrokeCap.round
      ..color = _aboutGold.withOpacity(0.85);
    final mountainFill = Paint()..color = _aboutGold.withOpacity(0.16);
    final frontFill = Paint()..color = _aboutGold.withOpacity(0.28);

    // Sun behind the mountains.
    canvas.drawCircle(
      Offset(w * 0.66, h * 0.32),
      s * 0.07,
      Paint()..color = _aboutGoldLight,
    );
    canvas.drawCircle(Offset(w * 0.66, h * 0.32), s * 0.07, thin);

    // Back mountain ridge.
    final back = Path()
      ..moveTo(w * 0.05, h * 0.66)
      ..lineTo(w * 0.22, h * 0.42)
      ..lineTo(w * 0.36, h * 0.54)
      ..lineTo(w * 0.54, h * 0.30)
      ..lineTo(w * 0.72, h * 0.46)
      ..lineTo(w * 0.85, h * 0.36)
      ..lineTo(w * 0.96, h * 0.66)
      ..lineTo(w * 0.05, h * 0.66)
      ..close();
    canvas.drawPath(back, mountainFill);
    canvas.drawPath(back, stroke);

    // Front mountain ridge — slightly lower and softer.
    final front = Path()
      ..moveTo(w * 0.02, h * 0.74)
      ..lineTo(w * 0.16, h * 0.54)
      ..lineTo(w * 0.30, h * 0.66)
      ..lineTo(w * 0.46, h * 0.48)
      ..lineTo(w * 0.62, h * 0.62)
      ..lineTo(w * 0.78, h * 0.56)
      ..lineTo(w * 0.92, h * 0.70)
      ..lineTo(w * 0.98, h * 0.74)
      ..lineTo(w * 0.02, h * 0.74)
      ..close();
    canvas.drawPath(front, frontFill);
    canvas.drawPath(front, stroke);

    // Ground horizon line.
    canvas.drawLine(
      Offset(w * 0.04, h * 0.86),
      Offset(w * 0.96, h * 0.86),
      thin,
    );

  }

  @override
  bool shouldRepaint(covariant _MountainPalmsPainter oldDelegate) => false;
}

// Gold-line illustration evoking community cartographers creating a map:
// a tilted sheet of paper with a sketched landform, a location pin, and a
// pencil at work along its edge.
class _MapSheetPainter extends CustomPainter {
  const _MapSheetPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final s = size.shortestSide;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.025
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _aboutGold;
    final thin = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.016
      ..strokeCap = StrokeCap.round
      ..color = _aboutGold.withOpacity(0.85);
    final faint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.010
      ..color = _aboutGold.withOpacity(0.45);
    final paperFill = Paint()..color = _aboutGold.withOpacity(0.10);
    final landFill = Paint()..color = _aboutGold.withOpacity(0.22);

    // Tilted paper sheet.
    final paper = Path()
      ..moveTo(w * 0.10, h * 0.20)
      ..lineTo(w * 0.92, h * 0.14)
      ..lineTo(w * 0.96, h * 0.84)
      ..lineTo(w * 0.14, h * 0.90)
      ..close();
    canvas.drawPath(paper, paperFill);
    canvas.drawPath(paper, stroke);

    // Faint grid lines on paper (cartographic).
    for (int i = 1; i < 4; i++) {
      final t = i / 4.0;
      // Horizontal grid line interpolated between the two long edges.
      final ax = w * 0.10 + (w * 0.04) * t;
      final ay = h * 0.20 + (h * 0.70) * t;
      final bx = w * 0.92 + (w * 0.04) * t;
      final by = h * 0.14 + (h * 0.70) * t;
      canvas.drawLine(Offset(ax, ay), Offset(bx, by), faint);
    }
    for (int i = 1; i < 5; i++) {
      final t = i / 5.0;
      final ax = w * 0.10 + (w * 0.82) * t;
      final ay = h * 0.20 + (h * -0.06) * t;
      final bx = w * 0.14 + (w * 0.82) * t;
      final by = h * 0.90 + (h * -0.06) * t;
      canvas.drawLine(Offset(ax, ay), Offset(bx, by), faint);
    }

    // Sketched land outline on the sheet.
    final land = Path()
      ..moveTo(w * 0.30, h * 0.40)
      ..cubicTo(
        w * 0.20, h * 0.55,
        w * 0.34, h * 0.74,
        w * 0.52, h * 0.72,
      )
      ..cubicTo(
        w * 0.72, h * 0.70,
        w * 0.80, h * 0.46,
        w * 0.62, h * 0.34,
      )
      ..cubicTo(
        w * 0.48, h * 0.26,
        w * 0.38, h * 0.30,
        w * 0.30, h * 0.40,
      )
      ..close();
    canvas.drawPath(land, landFill);
    canvas.drawPath(land, stroke);

    // River line through landform.
    final river = Path()
      ..moveTo(w * 0.34, h * 0.46)
      ..quadraticBezierTo(w * 0.48, h * 0.50, w * 0.52, h * 0.60)
      ..quadraticBezierTo(w * 0.58, h * 0.68, w * 0.70, h * 0.66);
    canvas.drawPath(river, thin);

    // Location pin on landform.
    final pinCenter = Offset(w * 0.56, h * 0.50);
    final pinR = s * 0.055;
    canvas.drawCircle(pinCenter, pinR, Paint()..color = _aboutGoldLight);
    canvas.drawCircle(pinCenter, pinR, thin);
    final pinTail = Path()
      ..moveTo(pinCenter.dx - pinR * 0.55, pinCenter.dy + pinR * 0.45)
      ..lineTo(pinCenter.dx, pinCenter.dy + pinR * 1.6)
      ..lineTo(pinCenter.dx + pinR * 0.55, pinCenter.dy + pinR * 0.45)
      ..close();
    canvas.drawPath(pinTail, Paint()..color = _aboutGoldLight);
    canvas.drawPath(pinTail, thin);

    // Pencil along upper right corner of sheet.
    canvas.save();
    canvas.translate(w * 0.78, h * 0.18);
    canvas.rotate(0.55);
    final pencilLen = s * 0.45;
    final pencilW = s * 0.07;
    // Shaft.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, pencilLen, pencilW),
      Paint()..color = _aboutGold.withOpacity(0.85),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, pencilLen, pencilW),
      thin,
    );
    // Tip (triangle).
    final tip = Path()
      ..moveTo(pencilLen, 0)
      ..lineTo(pencilLen + pencilW * 1.2, pencilW * 0.5)
      ..lineTo(pencilLen, pencilW)
      ..close();
    canvas.drawPath(tip, Paint()..color = _aboutGoldLight);
    canvas.drawPath(tip, thin);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MapSheetPainter oldDelegate) => false;
}

// Faint cartographic grid + meridian curve drawn behind the whole About
// section — gives the page a "weathered map spread" backdrop without
// competing with foreground content.
class _CartographicBackdropPainter extends CustomPainter {
  const _CartographicBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final lineColor = const Color(0xFF8FB3FF).withOpacity(0.18);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = lineColor;

    // Vertical meridians — curved (longitude lines projected on a sphere).
    const verticalCount = 9;
    for (int i = 1; i < verticalCount; i++) {
      final x = w * (i / verticalCount);
      final bow = (x - w / 2) * 0.15; // outer meridians bow further
      final path = Path()
        ..moveTo(x, 0)
        ..quadraticBezierTo(x + bow, h / 2, x, h);
      canvas.drawPath(path, stroke);
    }

    // Horizontal parallels.
    const horizontalCount = 7;
    for (int i = 1; i < horizontalCount; i++) {
      final y = h * (i / horizontalCount);
      canvas.drawLine(Offset(0, y), Offset(w, y), stroke);
    }

    // Faint dashed "route" arc spanning the section diagonally.
    final routeColor = const Color(0xFFE0B660).withOpacity(0.22);
    final routeStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = routeColor;
    final dashLen = 12.0;
    final gapLen = 8.0;
    final route = Path()
      ..moveTo(w * 0.10, h * 0.30)
      ..quadraticBezierTo(w * 0.50, h * 0.05, w * 0.92, h * 0.40);
    final metrics = route.computeMetrics();
    for (final m in metrics) {
      double dist = 0;
      while (dist < m.length) {
        final extract = m.extractPath(dist, dist + dashLen);
        canvas.drawPath(extract, routeStroke);
        dist += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CartographicBackdropPainter oldDelegate) =>
      false;
}

// Tiny faint compass-rose decoration that sits in a card corner; ties each
// card visually to the cartographic theme.
class _CardCornerCompassRose extends CustomPainter {
  final Color accent;
  const _CardCornerCompassRose({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.shortestSide / 2;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = accent.withOpacity(0.16);
    canvas.drawCircle(Offset(cx, cy), r * 0.85, stroke);
    canvas.drawCircle(Offset(cx, cy), r * 0.62, stroke);
    canvas.drawCircle(Offset(cx, cy), r * 0.40, stroke);
    for (int i = 0; i < 16; i++) {
      final a = i * math.pi / 8;
      final inner = r * 0.40;
      final outer = r * 0.85;
      canvas.drawLine(
        Offset(cx + math.cos(a) * inner, cy + math.sin(a) * inner),
        Offset(cx + math.cos(a) * outer, cy + math.sin(a) * outer),
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CardCornerCompassRose oldDelegate) =>
      oldDelegate.accent != accent;
}

// Mapping Method Section — large-scale showcase of the PRM diagram.
class MappingMethodSection extends StatelessWidget {
  final String language;
  final Key? methodologyKey;

  const MappingMethodSection({
    super.key,
    required this.language,
    this.methodologyKey,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final isPhone = screenWidth < 600;

    final horizontalPad = isPhone ? 20.0 : (isMobile ? 40.0 : 60.0);
    // Top padding stays generous so the section breathes coming out of the
    // navy band; bottom is tightened so the new "Visit Geography HQ" button
    // hands off to Make Dreams without a long empty green stretch.
    final topPad = isPhone ? 60.0 : 110.0;
    final bottomPad = isPhone ? 32.0 : 44.0;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C1328), Color(0xFF16402E), Color(0xFF16402E)],
          stops: [0.0, 0.28, 1.0],
        ),
      ),
      child: Stack(
        children: [
          if (!isMobile)
            const Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _JungleSideStrip(mirror: false),
            ),
          if (!isMobile)
            const Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _JungleSideStrip(mirror: true),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPad,
              topPad,
              horizontalPad,
              bottomPad,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      language == 'en'
                          ? 'PARTICIPATORY RESEARCH MAPPING'
                          : 'MAPEO PARTICIPATIVO DE INVESTIGACIÓN',
                      style: TextStyle(
                        color: const Color(0xFF9EC77A),
                        fontSize: isPhone ? 12 : 14,
                        letterSpacing: 3.0,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    Builder(
                      builder: (context) {
                        final titleStyle = Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            );
                        return Text(
                          language == 'en'
                              ? 'How Our Maps Are Made'
                              : 'Cómo se Elaboran Nuestros Mapas',
                          style: titleStyle,
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 880),
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: const Color(0xFFE5ECF5),
                            fontSize: isPhone ? 15 : 17,
                            height: 1.7,
                          ),
                          children: language == 'en'
                              ? const [
                                  TextSpan(
                                    text: 'Participatory Research Mapping (PRM)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ' can pinpoint land use locations in uncharted territories by combining Indigenous geographic knowledge (IGK) with modern cartographic tools to create new maps and data needed for land and park management.\n\nWe elevate community members (once the "researched") to a collateral position as co-researchers and co-authors, demanding unprecedented respect of each other’s knowledge and abilities.\n\nCommunity representatives are trained to complete land-use assessments using questionnaires, sketch-maps, GPS, interviews, and more. They work with a team of geographers to transform this information into consensual and then standard cartographic and demographic results.',
                                  ),
                                ]
                              : const [
                                  TextSpan(
                                    text:
                                        'El Mapeo de Investigación Participativa (PRM)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ' puede ubicar con precisión los usos de la tierra en territorios poco cartografiados al combinar el conocimiento geográfico indígena (IGK) con herramientas cartográficas modernas para crear los mapas y datos nuevos que se necesitan para el manejo de la tierra y los parques.\n\nElevamos a los miembros de la comunidad (antes los "investigados") a una posición colateral como co-investigadores y co-autores, exigiendo un respeto sin precedentes por los conocimientos y capacidades de cada uno.\n\nLos representantes comunitarios reciben capacitación para realizar evaluaciones de uso de la tierra mediante cuestionarios, mapas esquemáticos, GPS, entrevistas y más. Trabajan con un equipo de geógrafos para transformar esta información en resultados cartográficos y demográficos consensuados y luego estándar.',
                                  ),
                                ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: isPhone ? 24 : 40),
                    // Stages of PRM expansion list — sits directly under the
                    // descriptive paragraphs.
                    MethodologySection(
                      key: methodologyKey,
                      language: language,
                    ),
                    SizedBox(height: isPhone ? 24 : 40),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Text(
                        language == 'en'
                            ? 'A good map does not replace local knowledge — it translates that knowledge into a form more people can understand, use, and act on.'
                            : 'Un buen mapa no reemplaza el conocimiento local: traduce ese conocimiento a una forma que más personas puedan entender, usar y aplicar.',
                        style: TextStyle(
                          color: const Color(0xFFD7E0EA),
                          fontSize: isPhone ? 14 : 16,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: isPhone ? 20 : 28),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => launchUrl(
                          Uri.parse('https://learn.chagresinitiative.org'),
                          mode: LaunchMode.externalApplication,
                        ),
                        child: _HoverGlow(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isPhone ? 22 : 30,
                              vertical: isPhone ? 13 : 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0051BA),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: const Color(0xFF4A90D9),
                                width: 1.4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0051BA,
                                  ).withOpacity(0.32),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  language == 'en'
                                      ? 'Visit our Geography HQ to Learn More'
                                      : 'Visite nuestro Geography HQ para aprender más',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isPhone ? 14 : 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.arrow_outward,
                                  color: Colors.white,
                                  size: isPhone ? 16 : 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Scrollytelling comparison: satellite imagery versus PRM maps.
class SatellitePrmStorySection extends StatelessWidget {
  final String language;

  const SatellitePrmStorySection({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;
    final isPhone = width < 600;
    final en = language == 'en';

    final beats = en
        ? const [
            _StoryBeat(
              label: '1',
              title:
                  'Satellite imagery is useful, but it is not the whole map.',
              body:
                  'Tools many people use every day let us zoom into a picture of the earth from above. That is powerful. But in remote areas like Chagres, imagery is often unclassified, partly classified, incorrectly labeled, or not labeled at all.',
              satellitePoint: 'Imagery may show forest without explaining it',
              prmPoint:
                  'Our method explains how places are used and understood',
              icon: Icons.satellite_alt,
              visualType: _StoryVisualType.satelliteTiles,
            ),
            _StoryBeat(
              label: '2',
              title: 'A green patch can hold many stories.',
              body:
                  'A green patch may look empty. To families nearby, it may be hunting forest, a medicinal plant area, a sacred place, a seasonal trail, or land that floods after heavy rain.',
              satellitePoint: 'Can miss uses, names, history, and rules',
              prmPoint: 'Adds lived knowledge from community geographers',
              icon: Icons.groups_2,
              visualType: _StoryVisualType.hiddenMeaning,
            ),
            _StoryBeat(
              label: '3',
              title: 'How we map: layer the image with field knowledge.',
              body:
                  'Participatory Research Mapping combines field walks, GPS points, sketch maps, interviews, air photos, and satellite imagery. The crucial step happens in the field, where community geographers identify what different parts of the rainforest are, how they are used, and why they matter.',
              satellitePoint: 'One visual layer: surface appearance',
              prmPoint: 'Many meaning layers: use, access, risk, value',
              icon: Icons.layers,
              visualType: _StoryVisualType.mapLayers,
            ),
            _StoryBeat(
              label: '4',
              title: 'That detail matters when decisions have consequences.',
              body:
                  'Conservation, watershed protection, zoning, and governance all require more than “forest” versus “not forest.” Chagres National Park spans about 318,765 acres (129,000 hectares), so accurate mapping requires travel throughout an enormous park and enough detail to understand where protection is urgent, where use is traditional, and where conflict could happen.',
              satellitePoint: 'Helps spot change after it appears',
              prmPoint: 'Helps plan before harm or conflict grows',
              icon: Icons.account_tree_outlined,
              visualType: _StoryVisualType.decisionPath,
            ),
            _StoryBeat(
              label: '5',
              title: 'This is why our method is worth funding.',
              body:
                  'Your gift supports the careful, iterative fieldwork that fills the gap between raw imagery and real-world decisions. The time and cost come from repeated travel across the park, training local mappers, working with the people who live there to facilitate this process, checking and refining the maps, and giving communities and partners a tool they can act on.',
              satellitePoint: 'Imagery helps us see',
              prmPoint: 'PRM helps people understand, decide, and protect',
              icon: Icons.volunteer_activism,
              visualType: _StoryVisualType.donorTool,
            ),
          ]
        : const [
            _StoryBeat(
              label: '1',
              title: 'La imagen satelital es útil, pero no es todo el mapa.',
              body:
                  'Las herramientas que muchas personas usan a diario permiten acercarse a una imagen de la tierra desde arriba. Eso es poderoso. Pero en áreas remotas como Chagres, la imagen muchas veces no está clasificada, está parcialmente clasificada, está mal etiquetada o no tiene etiquetas.',
              satellitePoint: 'La imagen puede mostrar bosque sin explicarlo',
              prmPoint:
                  'Nuestro método explica cómo se usan y entienden los lugares',
              icon: Icons.satellite_alt,
              visualType: _StoryVisualType.satelliteTiles,
            ),
            _StoryBeat(
              label: '2',
              title: 'Pero una imagen desde arriba no explica a las personas.',
              body:
                  'Una zona verde puede parecer vacía. Para las familias cercanas, puede ser bosque de cacería, área de plantas medicinales, lugar sagrado, sendero estacional o tierra que se inunda con lluvias fuertes.',
              satellitePoint: 'Puede perder usos, nombres, historia y reglas',
              prmPoint: 'Agrega conocimiento vivido de geógrafos comunitarios',
              icon: Icons.groups_2,
              visualType: _StoryVisualType.hiddenMeaning,
            ),
            _StoryBeat(
              label: '3',
              title:
                  'Cómo mapeamos: combinamos imagen con conocimiento de campo.',
              body:
                  'El Mapeo Participativo de Investigación combina recorridos de campo, puntos GPS, mapas dibujados, entrevistas, fotos aéreas e imágenes satelitales. El paso crucial ocurre en el campo, donde geógrafos comunitarios identifican qué son las distintas partes del bosque tropical, cómo se usan y por qué importan.',
              satellitePoint: 'Una capa visual: apariencia de la superficie',
              prmPoint:
                  'Muchas capas de significado: uso, acceso, riesgo, valor',
              icon: Icons.layers,
              visualType: _StoryVisualType.mapLayers,
            ),
            _StoryBeat(
              label: '4',
              title:
                  'Ese detalle importa cuando las decisiones tienen consecuencias.',
              body:
                  'La conservación, la protección de cuencas, la zonificación y la gobernanza requieren más que “bosque” o “no bosque”. El Parque Nacional Chagres abarca aproximadamente 318,765 acres (129,000 hectáreas), por eso el mapeo preciso requiere viajar por un parque enorme y reunir suficiente detalle para saber dónde la protección es urgente, dónde el uso es tradicional y dónde puede surgir conflicto.',
              satellitePoint: 'Ayuda a ver cambios cuando ya aparecen',
              prmPoint: 'Ayuda a planificar antes de que crezca el daño',
              icon: Icons.account_tree_outlined,
              visualType: _StoryVisualType.decisionPath,
            ),
            _StoryBeat(
              label: '5',
              title: 'Por eso vale la pena financiar nuestro método.',
              body:
                  'Su donación apoya el trabajo de campo cuidadoso e iterativo que llena el espacio entre imágenes crudas y decisiones reales. El tiempo y el costo vienen de viajes repetidos por el parque, capacitar mapeadores locales, trabajar con las personas que viven allí para facilitar este proceso, revisar y mejorar los mapas, y dar a comunidades y aliados una herramienta para actuar.',
              satellitePoint: 'Las imágenes ayudan a ver',
              prmPoint: 'El PRM ayuda a entender, decidir y proteger',
              icon: Icons.volunteer_activism,
              visualType: _StoryVisualType.donorTool,
            ),
          ];

    return Container(
      width: double.infinity,
      color: const Color(0xFF16402E),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF16402E).withOpacity(0.96),
                      const Color(0xFF1A4A35).withOpacity(0.98),
                      const Color(0xFF16402E).withOpacity(0.96),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!isMobile)
            const Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _JungleSideStrip(mirror: false),
            ),
          if (!isMobile)
            const Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _JungleSideStrip(mirror: true),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              isPhone ? 20 : (isMobile ? 36 : 72),
              isPhone ? 58 : 84,
              isPhone ? 20 : (isMobile ? 36 : 72),
              isPhone ? 26 : 36,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Column(
                  children: [
                    Text(
                      en
                          ? 'SEEING IS NOT THE SAME AS UNDERSTANDING'
                          : 'VER NO ES LO MISMO QUE ENTENDER',
                      style: TextStyle(
                        color: const Color(0xFFFFC766),
                        fontSize: isPhone ? 11 : 13,
                        letterSpacing: 2.2,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      en
                          ? 'Comparing Satellite Imagery and the Maps We Make'
                          : 'Comparando imágenes satelitales y los mapas que hacemos',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      en
                          ? 'It is easy to feel like the whole world has already been mapped because satellite imagery is everywhere. But in remote places like Chagres, imagery may be unclassified, partly classified, or mislabeled. Our method asks what the place means, how it is used, and what people need to decide wisely.'
                          : 'Es fácil sentir que todo el mundo ya está mapeado porque las imágenes satelitales están en todas partes. Pero en lugares remotos como Chagres, la imagen puede no estar clasificada, estar parcialmente clasificada o estar mal etiquetada. Nuestro método pregunta qué significa el lugar, cómo se usa y qué necesitan saber las personas para decidir bien.',
                      style: TextStyle(
                        color: const Color(0xFFE5ECF5),
                        fontSize: isPhone ? 16 : 18,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isPhone ? 24 : 42),
                    if (!isMobile) ...[
                      _ImageryPrmSideBySide(language: language),
                      const SizedBox(height: 34),
                    ],
                    _StaticStoryComparison(language: language),
                    SizedBox(height: isPhone ? 28 : 42),
                    for (var index = 0; index < beats.length; index++) ...[
                      _StaticStoryBeatCard(
                        beat: beats[index],
                        isMobile: isMobile,
                      ),
                      if (index != beats.length - 1) const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryBeat {
  final String label;
  final String title;
  final String body;
  final String satellitePoint;
  final String prmPoint;
  final IconData icon;
  final _StoryVisualType visualType;

  const _StoryBeat({
    required this.label,
    required this.title,
    required this.body,
    required this.satellitePoint,
    required this.prmPoint,
    required this.icon,
    required this.visualType,
  });
}

enum _StoryVisualType {
  satelliteTiles,
  hiddenMeaning,
  mapLayers,
  decisionPath,
  donorTool,
}

class _ImageryPrmSideBySide extends StatelessWidget {
  final String language;

  const _ImageryPrmSideBySide({required this.language});

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.of(context).size.width < 600;
    final en = language == 'en';
    final imagery = _LandscapeUnderstandingPanel(
      title: en ? 'Satellite imagery' : 'Imagen satelital',
      subtitle: en
          ? 'remote-area imagery may not classify what it shows'
          : 'la imagen remota puede no clasificar lo que muestra',
      mode: _LandscapePanelMode.imagery,
      language: language,
    );
    final map = _LandscapeUnderstandingPanel(
      title: en ? 'How we map' : 'Cómo mapeamos',
      subtitle: en
          ? 'the same place, separated by use and meaning'
          : 'el mismo lugar, separado por uso y significado',
      mode: _LandscapePanelMode.prm,
      language: language,
    );

    return Container(
      padding: EdgeInsets.all(isPhone ? 14 : 18),
      decoration: BoxDecoration(
        color: const Color(0xFF07111F).withOpacity(0.86),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: isPhone
          ? Column(children: [imagery, const SizedBox(height: 14), map])
          : Row(
              children: [
                Expanded(child: imagery),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    Icons.arrow_forward,
                    color: const Color(0xFFFFC766).withOpacity(0.9),
                    size: 30,
                  ),
                ),
                Expanded(child: map),
              ],
            ),
    );
  }
}

enum _LandscapePanelMode { imagery, prm }

class _LandscapeUnderstandingPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final _LandscapePanelMode mode;
  final String language;

  const _LandscapeUnderstandingPanel({
    required this.title,
    required this.subtitle,
    required this.mode,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final isImagery = mode == _LandscapePanelMode.imagery;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, right: 6, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isImagery ? Colors.white : const Color(0xFFF7E7BE),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: isImagery
                      ? const Color(0xFFB9C6EA)
                      : const Color(0xFFEFD49D),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 330,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isImagery
                ? const Color(0xFF173529)
                : const Color(0xFFF0E3C5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isImagery
                  ? const Color(0xFF77A7D9).withOpacity(0.34)
                  : const Color(0xFF7A4D25).withOpacity(0.30),
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: isImagery
                    ? const _SatelliteMosaicGraphic()
                    : _PrmMeaningMapGraphic(language: language),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SatelliteMosaicGraphic extends StatelessWidget {
  const _SatelliteMosaicGraphic();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _SatelliteScenePainter());
  }
}

class _PrmMeaningMapGraphic extends StatelessWidget {
  final String language;

  const _PrmMeaningMapGraphic({required this.language});

  @override
  Widget build(BuildContext context) {
    final en = language == 'en';

    return Stack(
      children: [
        const Positioned.fill(child: CustomPaint(painter: _PrmScenePainter())),
        Positioned(
          left: 18,
          top: 14,
          child: Text(
            en ? 'A Pretend PRM Map' : 'Un mapa PRM imaginario',
            style: const TextStyle(
              color: Color(0xFF3B2A16),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Positioned(
          left: 74,
          top: 94,
          child: _WaterTextLabel(label: en ? 'river' : 'río'),
        ),
        Positioned(
          left: 78,
          top: 224,
          child: _WaterTextLabel(label: en ? 'lake' : 'lago'),
        ),
        Positioned(
          left: 24,
          top: 126,
          child: _MapZone(
            label: en ? 'water source' : 'fuente de agua',
            color: const Color(0xFF77A7D9),
          ),
        ),
        Positioned(
          right: 18,
          top: 92,
          child: _MapZone(
            label: en ? 'village' : 'aldea',
            color: const Color(0xFFE8C36F),
          ),
        ),
        Positioned(
          left: 22,
          bottom: 44,
          child: _MapZone(
            label: en ? 'medicinal forest' : 'bosque medicinal',
            color: const Color(0xFF7FB069),
          ),
        ),
        Positioned(
          right: 30,
          top: 156,
          child: _MapZone(
            label: en ? 'hunting forest' : 'bosque de cacería',
            color: const Color(0xFF4F8F5B),
          ),
        ),
        Positioned(
          left: 126,
          bottom: 42,
          child: _MapZone(
            label: en ? 'seasonal trail' : 'sendero estacional',
            color: const Color(0xFFFFC766),
          ),
        ),
        Positioned(
          right: 28,
          bottom: 30,
          child: _MapZone(
            label: en ? 'cultivation zone' : 'zona de cultivo',
            color: const Color(0xFFA0291E),
          ),
        ),
        Positioned(
          right: 84,
          top: 196,
          child: _MapZone(
            label: en ? 'religious site' : 'sitio religioso',
            color: const Color(0xFFB87AD9),
          ),
        ),
        Positioned(
          right: 14,
          top: 14,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MapScaleBar(label: en ? '500 m' : '500 m'),
              const SizedBox(width: 16),
              _MapLegend(language: language),
            ],
          ),
        ),
      ],
    );
  }
}

class _WaterTextLabel extends StatelessWidget {
  final String label;

  const _WaterTextLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w900,
        shadows: [
          Shadow(color: Color(0xAA063B52), blurRadius: 5),
          Shadow(color: Color(0xAA063B52), offset: Offset(0, 1)),
        ],
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  final String language;

  const _MapLegend({required this.language});

  @override
  Widget build(BuildContext context) {
    final en = language == 'en';

    return Container(
      width: 124,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            en ? 'Legend' : 'Leyenda',
            style: const TextStyle(
              color: Color(0xFF3B2A16),
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          _MapLegendItem(
            color: const Color(0xFF7FB069),
            text: en ? 'forest use' : 'uso del bosque',
          ),
          _MapLegendItem(
            color: const Color(0xFFA0291E),
            text: en ? 'cultivation' : 'cultivo',
          ),
          _MapLegendItem(
            color: const Color(0xFFB87AD9),
            text: en ? 'religious' : 'religioso',
          ),
        ],
      ),
    );
  }
}

class _MapLegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _MapLegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF3B2A16),
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapScaleBar extends StatelessWidget {
  final String label;

  const _MapScaleBar({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 64, height: 4, color: const Color(0xFF3B2A16)),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF3B2A16),
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SatelliteScenePainter extends CustomPainter {
  const _SatelliteScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF173529),
    );

    final forestPaints = [
      Paint()..color = const Color(0xFF1B4B32),
      Paint()..color = const Color(0xFF245D37),
      Paint()..color = const Color(0xFF2F6B3F),
      Paint()..color = const Color(0xFF173326),
    ];
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 13; col++) {
        final center = Offset(
          size.width * (0.04 + col * 0.083),
          size.height * (0.08 + row * 0.105),
        );
        final radius = size.shortestSide * (0.045 + ((row + col) % 3) * 0.007);
        canvas.drawCircle(
          center,
          radius,
          forestPaints[(row + col) % forestPaints.length],
        );
      }
    }

    final riverPaint = Paint()
      ..color = const Color(0xFF67A8C7).withOpacity(0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.075
      ..strokeCap = StrokeCap.round;
    final river = Path()
      ..moveTo(-20, size.height * 0.32)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.42,
        size.width * 0.33,
        size.height * 0.18,
        size.width * 0.52,
        size.height * 0.35,
      )
      ..cubicTo(
        size.width * 0.68,
        size.height * 0.50,
        size.width * 0.75,
        size.height * 0.64,
        size.width + 20,
        size.height * 0.54,
      );
    canvas.drawPath(river, riverPaint);

    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.10,
        size.height * 0.62,
        size.width * 0.26,
        size.height * 0.18,
      ),
      Paint()..color = const Color(0xFF79B9D6).withOpacity(0.92),
    );

    final clearing = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.68,
        size.height * 0.20,
        size.width * 0.22,
        size.height * 0.17,
      ),
      const Radius.circular(18),
    );
    canvas.drawRRect(
      clearing,
      Paint()..color = const Color(0xFF9B8555).withOpacity(0.78),
    );
    final roofPaint = Paint()..color = const Color(0xFFE8C36F);
    for (var index = 0; index < 8; index++) {
      final x = size.width * (0.70 + (index % 4) * 0.045);
      final y = size.height * (0.23 + (index ~/ 4) * 0.055);
      canvas.drawRect(Rect.fromLTWH(x, y, 18, 10), roofPaint);
    }

    final hazePaint = Paint()..color = Colors.white.withOpacity(0.12);
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.42,
        size.height * 0.08,
        size.width * 0.38,
        size.height * 0.14,
      ),
      hazePaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.05,
        size.height * 0.62,
        size.width * 0.34,
        size.height * 0.12,
      ),
      hazePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SatelliteScenePainter oldDelegate) => false;
}

class _PrmScenePainter extends CustomPainter {
  const _PrmScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF0E3C5),
    );

    final gridPaint = Paint()
      ..color = const Color(0xFF8C6B3E).withOpacity(0.15)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += size.width / 8) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += size.height / 7) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    _drawZone(
      canvas,
      Path()
        ..moveTo(size.width * 0.06, size.height * 0.54)
        ..quadraticBezierTo(
          size.width * 0.20,
          size.height * 0.38,
          size.width * 0.36,
          size.height * 0.54,
        )
        ..quadraticBezierTo(
          size.width * 0.30,
          size.height * 0.86,
          size.width * 0.08,
          size.height * 0.84,
        )
        ..close(),
      const Color(0xFF7FB069).withOpacity(0.56),
    );
    _drawZone(
      canvas,
      Path()
        ..moveTo(size.width * 0.46, size.height * 0.46)
        ..quadraticBezierTo(
          size.width * 0.74,
          size.height * 0.30,
          size.width * 0.92,
          size.height * 0.48,
        )
        ..quadraticBezierTo(
          size.width * 0.84,
          size.height * 0.76,
          size.width * 0.52,
          size.height * 0.68,
        )
        ..close(),
      const Color(0xFF4F8F5B).withOpacity(0.54),
    );
    _drawZone(
      canvas,
      Path()
        ..moveTo(size.width * 0.58, size.height * 0.62)
        ..quadraticBezierTo(
          size.width * 0.78,
          size.height * 0.54,
          size.width * 0.98,
          size.height * 0.66,
        )
        ..lineTo(size.width, size.height)
        ..lineTo(size.width * 0.64, size.height)
        ..close(),
      const Color(0xFFA0291E).withOpacity(0.30),
    );
    _drawZone(
      canvas,
      Path()
        ..moveTo(size.width * 0.70, size.height * 0.68)
        ..quadraticBezierTo(
          size.width * 0.82,
          size.height * 0.58,
          size.width * 0.92,
          size.height * 0.70,
        )
        ..quadraticBezierTo(
          size.width * 0.86,
          size.height * 0.84,
          size.width * 0.72,
          size.height * 0.82,
        )
        ..close(),
      const Color(0xFFB87AD9).withOpacity(0.38),
    );

    final riverPaint = Paint()
      ..color = const Color(0xFF2E9CC3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.032
      ..strokeCap = StrokeCap.round;
    final river = Path()
      ..moveTo(-10, size.height * 0.32)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.42,
        size.width * 0.33,
        size.height * 0.18,
        size.width * 0.52,
        size.height * 0.35,
      )
      ..cubicTo(
        size.width * 0.68,
        size.height * 0.50,
        size.width * 0.75,
        size.height * 0.64,
        size.width + 10,
        size.height * 0.54,
      );
    canvas.drawPath(river, riverPaint);
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.10,
        size.height * 0.62,
        size.width * 0.22,
        size.height * 0.16,
      ),
      Paint()..color = const Color(0xFF77A7D9).withOpacity(0.80),
    );

    final trailPaint = Paint()
      ..color = const Color(0xFF543518)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final trail = Path()
      ..moveTo(size.width * 0.20, size.height * 0.76)
      ..quadraticBezierTo(
        size.width * 0.40,
        size.height * 0.55,
        size.width * 0.62,
        size.height * 0.76,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.86,
        size.width * 0.88,
        size.height * 0.80,
      );
    canvas.drawPath(trail, trailPaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.70,
          size.height * 0.38,
          size.width * 0.20,
          size.height * 0.15,
        ),
        const Radius.circular(14),
      ),
      Paint()..color = const Color(0xFFE8C36F).withOpacity(0.58),
    );
  }

  void _drawZone(Canvas canvas, Path path, Color color) {
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(0.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _PrmScenePainter oldDelegate) => false;
}

class _MapGridBackground extends StatelessWidget {
  const _MapGridBackground();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        8,
        (row) => Expanded(
          child: Row(
            children: List.generate(
              8,
              (col) => Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0x228C6B3E)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapZone extends StatelessWidget {
  final String label;
  final Color color;

  const _MapZone({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return _SimpleLegendPill(text: label, color: color, darkText: true);
  }
}

class _SimpleLegendPill extends StatelessWidget {
  final String text;
  final Color color;
  final bool darkText;

  const _SimpleLegendPill({
    required this.text,
    required this.color,
    required this.darkText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.86),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.46)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: darkText ? const Color(0xFF2A1B0B) : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StaticStoryComparison extends StatelessWidget {
  final String language;

  const _StaticStoryComparison({required this.language});

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.of(context).size.width < 600;
    final en = language == 'en';
    final satellite = _StaticComparisonPanel(
      icon: Icons.satellite_alt,
      title: en ? 'Satellite imagery' : 'Imagen satelital',
      color: const Color(0xFF77A7D9),
      points: en
          ? const [
              'This is a valuable starting point, not a complete map of land meaning or land use.',
              'It shows forest canopy, water, roads, roofs, and clearings.',
              'It cannot tell who uses a place, what it is called, or why it matters.',
            ]
          : const [
              'Es un punto de partida valioso, no un mapa completo del significado o uso de la tierra.',
              'Muestra copa forestal, agua, caminos, techos y claros.',
              'No puede decir quién usa un lugar, cómo se llama o por qué importa.',
            ],
    );
    final prm = _StaticComparisonPanel(
      icon: Icons.edit_location_alt,
      title: en ? 'How we map' : 'Cómo mapeamos',
      color: const Color(0xFF7FB069),
      points: en
          ? const [
              'Adds field notes, GPS points, names, routes, rules, and local history.',
              'Connects ecological detail with community knowledge.',
              'Creates a tool for conservation, zoning, governance, and negotiation.',
            ]
          : const [
              'Agrega notas de campo, puntos GPS, nombres, rutas, reglas e historia local.',
              'Conecta detalle ecológico con conocimiento comunitario.',
              'Crea una herramienta para conservación, zonificación, gobernanza y negociación.',
            ],
    );

    if (isPhone) {
      return Column(children: [satellite, const SizedBox(height: 14), prm]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: satellite),
        const SizedBox(width: 18),
        Expanded(child: prm),
      ],
    );
  }
}

class _StaticComparisonPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<String> points;

  const _StaticComparisonPanel({
    required this.icon,
    required this.title,
    required this.color,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF07111F).withOpacity(0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.46), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final point in points) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    point,
                    style: const TextStyle(
                      color: Color(0xFFD7E0EA),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _StaticStoryBeatCard extends StatelessWidget {
  final _StoryBeat beat;
  final bool isMobile;

  const _StaticStoryBeatCard({required this.beat, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final visualAid = _StoryVisualAid(
      type: beat.visualType,
      isMobile: isMobile,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 26),
      decoration: BoxDecoration(
        color: const Color(0xFF101A2F).withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: isMobile
          ? Column(
              children: [
                _StoryBeatText(beat: beat, isMobile: isMobile),
                const SizedBox(height: 18),
                visualAid,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _StoryBeatText(beat: beat, isMobile: isMobile),
                ),
                const SizedBox(width: 22),
                Expanded(flex: 4, child: visualAid),
              ],
            ),
    );
  }
}

class _StoryBeatText extends StatelessWidget {
  final _StoryBeat beat;
  final bool isMobile;

  const _StoryBeatText({required this.beat, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFFFC766),
            shape: BoxShape.circle,
          ),
          child: Text(
            beat.label,
            style: const TextStyle(
              color: Color(0xFF07111F),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(beat.icon, color: const Color(0xFF7FB069), size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      beat.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 20 : 23,
                        fontWeight: FontWeight.w800,
                        height: 1.22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                beat.body,
                style: TextStyle(
                  color: const Color(0xFFD7E0EA),
                  fontSize: isMobile ? 15 : 16,
                  height: 1.58,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _StoryTag(
                    text: beat.satellitePoint,
                    color: const Color(0xFF77A7D9),
                  ),
                  _StoryTag(
                    text: beat.prmPoint,
                    color: const Color(0xFF7FB069),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StoryVisualAid extends StatelessWidget {
  final _StoryVisualType type;
  final bool isMobile;

  const _StoryVisualAid({required this.type, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isMobile ? 180 : 210),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF07111F).withOpacity(0.78),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: switch (type) {
        _StoryVisualType.satelliteTiles => _SatelliteTileVisual(),
        _StoryVisualType.hiddenMeaning => _HiddenMeaningVisual(),
        _StoryVisualType.mapLayers => _MapLayerVisual(),
        _StoryVisualType.decisionPath => _DecisionPathVisual(),
        _StoryVisualType.donorTool => _DonorToolVisual(),
      },
    );
  }
}

class _SatelliteTileVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _VisualTitle(icon: Icons.grid_view, text: 'Pixels show surface'),
        const SizedBox(height: 14),
        SizedBox(
          height: 124,
          child: GridView.count(
            crossAxisCount: 5,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(15, (index) {
              final colors = [
                const Color(0xFF1F5A38),
                const Color(0xFF2E6F3C),
                const Color(0xFF77A7D9),
                const Color(0xFF36513A),
              ];
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: BorderRadius.circular(5),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _HiddenMeaningVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _VisualTitle(
          icon: Icons.visibility_off,
          text: 'Meaning is hidden from above',
        ),
        SizedBox(height: 16),
        _VisualPill(icon: Icons.forest, text: 'medicinal plants'),
        SizedBox(height: 10),
        _VisualPill(icon: Icons.route, text: 'seasonal trail'),
        SizedBox(height: 10),
        _VisualPill(icon: Icons.water_drop, text: 'flood risk'),
      ],
    );
  }
}

class _MapLayerVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 188,
      child: Stack(
        children: [
          Positioned(
            left: 14,
            right: 44,
            top: 26,
            child: _LayerSheet(color: Color(0xFF77A7D9), label: 'imagery'),
          ),
          Positioned(
            left: 28,
            right: 28,
            top: 70,
            child: _LayerSheet(color: Color(0xFFFFC766), label: 'field notes'),
          ),
          Positioned(
            left: 42,
            right: 12,
            top: 114,
            child: _LayerSheet(
              color: Color(0xFF7FB069),
              label: 'community knowledge',
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionPathVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _DecisionStep(icon: Icons.image_search, text: 'See change'),
        Icon(Icons.arrow_downward, color: Color(0xFFFFC766)),
        _DecisionStep(icon: Icons.map, text: 'Understand context'),
        Icon(Icons.arrow_downward, color: Color(0xFFFFC766)),
        _DecisionStep(icon: Icons.task_alt, text: 'Plan before harm grows'),
      ],
    );
  }
}

class _DonorToolVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _VisualTitle(
          icon: Icons.volunteer_activism,
          text:
              'Donation enables all of these steps which facilitate this process',
        ),
        SizedBox(height: 16),
        _VisualPill(icon: Icons.gps_fixed, text: 'GPS + fieldwork'),
        SizedBox(height: 10),
        _VisualPill(icon: Icons.school, text: 'trained community geographers'),
        SizedBox(height: 10),
        _VisualPill(icon: Icons.handshake, text: 'governance-ready maps'),
      ],
    );
  }
}

class _VisualTitle extends StatelessWidget {
  final IconData icon;
  final String text;

  const _VisualTitle({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFC766), size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _VisualPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _VisualPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF16402E).withOpacity(0.82),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF7FB069).withOpacity(0.36)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7FB069), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFD7E0EA),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LayerSheet extends StatelessWidget {
  final Color color;
  final String label;

  const _LayerSheet({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: color.withOpacity(0.84),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.38)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF07111F),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DecisionStep extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DecisionStep({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7FB069), size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _StoryTag extends StatelessWidget {
  final String text;
  final Color color;

  const _StoryTag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.46)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// Compact "Make Dreams Possible" callout — moved up from Partnerships and
// shortened to a marketing-friendly summary with bullet highlights.
class _MakeDreamsCallout extends StatelessWidget {
  final String language;
  final VoidCallback onDonate;
  const _MakeDreamsCallout({required this.language, required this.onDonate});

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.of(context).size.width < 600;
    final isMobile = MediaQuery.of(context).size.width < 900;

    final bullets = language == 'en'
        ? const [
            '100% to direct project costs — no overhead, no salaries.',
            'Three-year mission launching Summer 2026 via KU Endowment.',
            'Funds workshops, mapping tech, travel, and community-geographer stipends.',
            'Public-private partnership replacing shrinking federal research funding.',
          ]
        : const [
            '100% a costos directos — sin gastos generales ni salarios.',
            'Misión de 3 años, verano 2026, vía KU Endowment.',
            'Financia talleres, tecnología de mapeo, viajes y estipendios comunitarios.',
            'Asociación público-privada que reemplaza el financiamiento federal recortado.',
          ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isPhone ? 20 : 60,
        isPhone ? 24 : 36,
        isPhone ? 20 : 60,
        isPhone ? 40 : 64,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: dart_ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 36,
                  vertical: isMobile ? 26 : 34,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF0E261C).withOpacity(0.62),
                  border: Border.all(
                    color: const Color(0xFFE0B660).withOpacity(0.32),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF08130E).withOpacity(0.45),
                      blurRadius: 40,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      language == 'en'
                          ? 'Make Dreams Possible'
                          : 'Haga Posibles los Sueños',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        color: const Color(0xFFE0B660),
                        fontSize: isPhone ? 26 : 34,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        height: 1.15,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      language == 'en'
                          ? 'FUND KU RESEARCH ABROAD'
                          : 'FINANCIE LA INVESTIGACIÓN DE KU EN EL EXTERIOR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isPhone ? 11 : 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.2,
                      ),
                    ),
                    SizedBox(height: isMobile ? 14 : 18),
                    for (int i = 0; i < bullets.length; i++) ...[
                      _MakeDreamsBullet(text: bullets[i]),
                      if (i < bullets.length - 1) const SizedBox(height: 8),
                    ],
                    SizedBox(height: isMobile ? 20 : 24),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: onDonate,
                        child: _HoverGlow(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 36,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA0291E),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: const Color(0xFFA0291E),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              language == 'en' ? 'Donate Now' : 'Donar Ahora',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MakeDreamsBullet extends StatelessWidget {
  final String text;
  const _MakeDreamsBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 12),
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE0B660),
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFD9DEEC),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// One headline in the canal-news ticker.
class _NewsHeadline {
  final String title;
  final String url;
  final String source;
  final String date;
  const _NewsHeadline({
    required this.title,
    required this.url,
    required this.source,
    required this.date,
  });
}

// Full-width auto-scrolling ribbon of Panama Canal headlines. Reads the static
// news.json (same-origin, refreshed daily by CI). If the file is missing,
// empty, or fails to load, the widget renders nothing so the page is never
// affected.
class _NewsTicker extends StatefulWidget {
  final String language;
  const _NewsTicker({required this.language});

  @override
  State<_NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<_NewsTicker>
    with SingleTickerProviderStateMixin {
  List<_NewsHeadline> _items = const [];
  late final AnimationController _controller;
  final GlobalKey _contentKey = GlobalKey();
  double _contentWidth = 0;
  static const double _gap = 64; // space between the two looping copies
  static const double _pxPerSecond = 55;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _loadNews();
  }

  Future<void> _loadNews() async {
    try {
      // Cache-bust hourly so a fresh deploy shows new headlines without a
      // hard refresh, while still allowing normal caching within the hour.
      final bust = DateTime.now().millisecondsSinceEpoch ~/ 3600000;
      final raw = await html.HttpRequest.getString('news.json?t=$bust');
      final data = json.decode(raw) as Map<String, dynamic>;
      final list = (data['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (e) => _NewsHeadline(
              title: (e['title'] ?? '').toString(),
              url: (e['url'] ?? '').toString(),
              source: (e['source'] ?? '').toString(),
              date: (e['date'] ?? '').toString(),
            ),
          )
          .where((h) => h.title.isNotEmpty && h.url.isNotEmpty)
          .toList();
      if (!mounted || list.isEmpty) return;
      setState(() => _items = list);
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    } catch (_) {
      // No ticker if the feed can't be loaded.
    }
  }

  void _measure() {
    final ctx = _contentKey.currentContext;
    final width = ctx?.size?.width ?? 0;
    if (width <= 0 || width == _contentWidth) return;
    _contentWidth = width;
    final loopPx = width + _gap;
    _controller.duration = Duration(
      milliseconds: (loopPx / _pxPerSecond * 1000).round(),
    );
    _controller
      ..reset()
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();
    final en = widget.language == 'en';
    final isPhone = MediaQuery.of(context).size.width < 600;

    final label = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPhone ? 14 : 20,
        vertical: isPhone ? 10 : 12,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE0B660), Color(0xFFB8851A)],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_boat_filled,
            size: isPhone ? 16 : 18,
            color: const Color(0xFF0C1328),
          ),
          SizedBox(width: isPhone ? 6 : 8),
          Text(
            en ? 'CANAL NEWS' : 'NOTICIAS DEL CANAL',
            style: TextStyle(
              color: const Color(0xFF0C1328),
              fontWeight: FontWeight.w800,
              fontSize: isPhone ? 11 : 12.5,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );

    // The visible window is bounded by Expanded; ClipRect clips to it and an
    // OverflowBox lets the (wider-than-screen) strip overflow inside so hit
    // testing on each headline lands correctly. Hovering pauses the scroll so
    // a moving headline is easy to click.
    final scroller = MouseRegion(
      onEnter: (_) => _controller.stop(),
      onExit: (_) {
        if (_contentWidth > 0 && !_controller.isAnimating) {
          _controller.repeat();
        }
      },
      child: ClipRect(
        child: SizedBox(
          height: isPhone ? 40 : 46,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final loopPx = _contentWidth + _gap;
              final dx =
                  _contentWidth == 0 ? 0.0 : -_controller.value * loopPx;
              return OverflowBox(
                alignment: Alignment.centerLeft,
                minWidth: 0,
                maxWidth: double.infinity,
                child: Transform.translate(
                  offset: Offset(dx, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStrip(key: _contentKey),
                      SizedBox(width: _gap),
                      // Second identical copy makes the wrap seamless.
                      if (_contentWidth > 0) _buildStrip(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF101A2F),
        border: Border(
          top: BorderSide(color: Color(0x33E0B660)),
          bottom: BorderSide(color: Color(0x33E0B660)),
        ),
      ),
      child: Row(
        children: [
          label,
          Expanded(child: scroller),
        ],
      ),
    );
  }

  Widget _buildStrip({Key? key}) {
    return Row(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final item in _items) _buildItem(item),
      ],
    );
  }

  Widget _buildItem(_NewsHeadline item) {
    return Padding(
      padding: const EdgeInsets.only(left: 28),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => launchUrl(
            Uri.parse(item.url),
            mode: LaunchMode.externalApplication,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 28),
                child: Text(
                  '•',
                  style: TextStyle(color: Color(0xFFE0B660), fontSize: 14),
                ),
              ),
              Text(
                item.title,
                style: const TextStyle(
                  color: Color(0xFFE5ECF5),
                  fontSize: 14,
                  height: 1.1,
                ),
              ),
              if (_attribution(item).isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  _attribution(item),
                  style: const TextStyle(
                    color: Color(0xFF8FA0C4),
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // "— Source, 5/20/26" (either part omitted if missing).
  String _attribution(_NewsHeadline item) {
    final parts = [
      if (item.source.isNotEmpty) item.source,
      if (item.date.isNotEmpty) item.date,
    ];
    return parts.isEmpty ? '' : '— ${parts.join(', ')}';
  }
}

// One panel of the two-panel overview/detail map. Tapping it opens a
// full-screen, pinch/scroll-zoomable view; a small magnifier badge signals it
// is interactive.
class _ZoomableMapPanel extends StatelessWidget {
  final String imagePath;
  const _ZoomableMapPanel({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.zoomIn,
      child: GestureDetector(
        onTap: () => showDialog(
          context: context,
          builder: (_) => ZoomImageDialog(imagePath: imagePath),
        ),
        child: Stack(
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.zoom_in,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable navy band with the faint, green-tinted palm texture used elsewhere
// in the page. Wrap a vertical run of navy sections in one of these to get a
// continuous textured backdrop instead of multiple flat-navy stretches.
class _NavyPalmBand extends StatelessWidget {
  final Widget child;
  const _NavyPalmBand({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0C1328),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00FFFFFF),
                    Color(0xFFFFFFFF),
                    Color(0xFFFFFFFF),
                    Color(0x00FFFFFF),
                  ],
                  stops: [0.0, 0.06, 0.94, 1.0],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Opacity(
                  opacity: 0.38,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/palms.jpg'),
                        repeat: ImageRepeat.repeat,
                        fit: BoxFit.none,
                        alignment: Alignment.topCenter,
                        colorFilter: ColorFilter.mode(
                          Color(0xCC16402E),
                          BlendMode.multiply,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// Seal with surrounding blue stat figures (water stats + Chagres biodiversity)
class _SealWithStats extends StatelessWidget {
  final String language;
  const _SealWithStats({required this.language});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final en = language == 'en';

    final waterStat = _StatFigure(
      painter: _WaterDropCanalPainter(),
      value: '40%',
      label: en
          ? "of the Panama Canal's freshwater comes from Chagres forests (MiAmbiente)."
          : 'del agua dulce del Canal de Panamá proviene de los bosques de Chagres (MiAmbiente).',
    );
    final peopleStat = _StatFigure(
      painter: _PeopleDrinkingPainter(),
      value: '2M+',
      label: en
          ? 'people in Panama City and Colón rely on its drinking water (MacroTrends).'
          : 'personas en la Ciudad de Panamá y Colón dependen de su agua potable (MacroTrends).',
    );
    final birdStat = _StatFigure(
      painter: _HarpyEaglePainter(),
      value: '396+',
      label: en
          ? 'bird species, including the iconic Harpy Eagle, are documented here (Fundación Chagres).'
          : 'especies de aves, incluyendo la icónica Águila Harpía, están documentadas aquí (Fundación Chagres).',
    );
    final plantStat = _StatFigure(
      painter: _RainforestTreePainter(),
      value: '900+',
      label: en
          ? 'plant species, including 143 endemic species, are documented across 129,000 hectares (TNC-ANCON 2003).'
          : 'especies de plantas, incluidas 143 endémicas, están documentadas en 129,000 hectáreas (TNC-ANCON 2003).',
    );
    final communitiesStat = _StatFigure(
      painter: _IndigenousCommunitiesPainter(),
      value: '~5',
      label: en
          ? 'Indigenous communities with thousands of residents call the park home (KU Field Research).'
          : 'comunidades indígenas con miles de habitantes residen en el parque (Investigación de Campo de KU).',
    );

    final content = isMobile
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Column(
              children: [
                waterStat,
                const SizedBox(height: 28),
                peopleStat,
                const SizedBox(height: 28),
                communitiesStat,
                const SizedBox(height: 28),
                birdStat,
                const SizedBox(height: 28),
                plantStat,
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  waterStat,
                  const SizedBox(width: 16),
                  peopleStat,
                  const SizedBox(width: 16),
                  communitiesStat,
                  const SizedBox(width: 16),
                  birdStat,
                  const SizedBox(width: 16),
                  plantStat,
                ],
              ),
            ),
          );

    // The palm-texture backdrop is now provided by the surrounding
    // _NavyPalmBand wrapper, so this widget just renders its content.
    return content;
  }
}

class _StatFigure extends StatelessWidget {
  final CustomPainter painter;
  final String value;
  final String label;

  const _StatFigure({
    required this.painter,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth < 600;
    final circleSize = isPhone ? 78.0 : 82.0;
    final iconPad = isPhone ? 12.0 : 13.0;
    final valueSize = isPhone ? 27.0 : 28.0;
    final labelSize = isPhone ? 11.5 : 12.0;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF5FB5FF).withOpacity(0.08),
              border: Border.all(
                color: const Color(0xFF5FB5FF).withOpacity(0.35),
                width: 2.0,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(iconPad),
              child: CustomPaint(painter: painter),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              color: const Color(0xFF7CC4FF),
              fontSize: valueSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFB9C6EA),
              fontSize: labelSize,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Simple blue illustrations ---

const Color _figureBlue = Color(0xFF7CC4FF);

Paint _stroke({double width = 2.2}) => Paint()
  ..color = _figureBlue
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round
  ..strokeWidth = width;

Paint _fill({double opacity = 1.0}) => Paint()
  ..color = _figureBlue.withOpacity(opacity)
  ..style = PaintingStyle.fill;

class _WaterDropCanalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Water drop
    final drop = Path()
      ..moveTo(w * 0.5, h * 0.06)
      ..cubicTo(w * 0.95, h * 0.55, w * 0.82, h * 0.95, w * 0.5, h * 0.95)
      ..cubicTo(w * 0.18, h * 0.95, w * 0.05, h * 0.55, w * 0.5, h * 0.06)
      ..close();
    canvas.drawPath(drop, _fill(opacity: 0.18));
    canvas.drawPath(drop, _stroke(width: 2.4));

    // Little ship silhouette inside (canal reference)
    final shipY = h * 0.62;
    final ship = Path()
      ..moveTo(w * 0.28, shipY)
      ..lineTo(w * 0.72, shipY)
      ..lineTo(w * 0.64, shipY + h * 0.10)
      ..lineTo(w * 0.36, shipY + h * 0.10)
      ..close();
    canvas.drawPath(ship, _fill());
    // Mast + funnel
    canvas.drawLine(
      Offset(w * 0.50, shipY),
      Offset(w * 0.50, shipY - h * 0.14),
      _stroke(width: 2.0),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.44, shipY - h * 0.09, w * 0.06, h * 0.09),
      _fill(),
    );

    // Waves below ship
    final wave = Path()
      ..moveTo(w * 0.22, h * 0.82)
      ..quadraticBezierTo(w * 0.33, h * 0.76, w * 0.44, h * 0.82)
      ..quadraticBezierTo(w * 0.55, h * 0.88, w * 0.66, h * 0.82)
      ..quadraticBezierTo(w * 0.73, h * 0.78, w * 0.78, h * 0.82);
    canvas.drawPath(wave, _stroke(width: 2.0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PeopleDrinkingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void person(double cx, double cy, double scale) {
      final headR = 0.09 * w * scale;
      canvas.drawCircle(Offset(cx, cy - 0.22 * h * scale), headR, _fill());
      final body = Path()
        ..moveTo(cx - 0.16 * w * scale, cy + 0.30 * h * scale)
        ..quadraticBezierTo(
          cx - 0.16 * w * scale,
          cy - 0.08 * h * scale,
          cx,
          cy - 0.08 * h * scale,
        )
        ..quadraticBezierTo(
          cx + 0.16 * w * scale,
          cy - 0.08 * h * scale,
          cx + 0.16 * w * scale,
          cy + 0.30 * h * scale,
        )
        ..close();
      canvas.drawPath(body, _fill());
    }

    // Back figure (smaller, center)
    person(w * 0.5, h * 0.48, 0.95);
    // Left figure
    person(w * 0.22, h * 0.55, 0.85);
    // Right figure
    person(w * 0.78, h * 0.55, 0.85);

    // Water drop above center (drinking water motif)
    final drop = Path()
      ..moveTo(w * 0.5, h * 0.02)
      ..cubicTo(w * 0.66, h * 0.15, w * 0.62, h * 0.28, w * 0.5, h * 0.28)
      ..cubicTo(w * 0.38, h * 0.28, w * 0.34, h * 0.15, w * 0.5, h * 0.02)
      ..close();
    canvas.drawPath(drop, _fill(opacity: 0.25));
    canvas.drawPath(drop, _stroke(width: 2.0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HarpyEaglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Stylized flying bird (gull/eagle silhouette)
    final wings = Path()
      ..moveTo(w * 0.04, h * 0.58)
      ..quadraticBezierTo(w * 0.22, h * 0.30, w * 0.38, h * 0.55)
      ..quadraticBezierTo(w * 0.44, h * 0.46, w * 0.50, h * 0.52)
      ..quadraticBezierTo(w * 0.56, h * 0.46, w * 0.62, h * 0.55)
      ..quadraticBezierTo(w * 0.78, h * 0.30, w * 0.96, h * 0.58);
    canvas.drawPath(wings, _stroke(width: 3.0));

    // Body
    final body = Path()
      ..moveTo(w * 0.44, h * 0.52)
      ..quadraticBezierTo(w * 0.50, h * 0.82, w * 0.56, h * 0.52)
      ..close();
    canvas.drawPath(body, _fill());

    // Head crest (harpy trademark)
    canvas.drawCircle(Offset(w * 0.50, h * 0.50), h * 0.045, _fill());
    canvas.drawLine(
      Offset(w * 0.50, h * 0.47),
      Offset(w * 0.46, h * 0.41),
      _stroke(width: 2.0),
    );
    canvas.drawLine(
      Offset(w * 0.50, h * 0.47),
      Offset(w * 0.54, h * 0.41),
      _stroke(width: 2.0),
    );

    // Tail
    final tail = Path()
      ..moveTo(w * 0.47, h * 0.70)
      ..lineTo(w * 0.50, h * 0.92)
      ..lineTo(w * 0.53, h * 0.70)
      ..close();
    canvas.drawPath(tail, _fill(opacity: 0.75));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RainforestTreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Trunk
    final trunk = Path()
      ..moveTo(w * 0.46, h * 0.95)
      ..lineTo(w * 0.48, h * 0.50)
      ..lineTo(w * 0.52, h * 0.50)
      ..lineTo(w * 0.54, h * 0.95)
      ..close();
    canvas.drawPath(trunk, _fill());

    // Canopy (three overlapping cloud-like blobs)
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.30),
      h * 0.24,
      _fill(opacity: 0.85),
    );
    canvas.drawCircle(
      Offset(w * 0.28, h * 0.42),
      h * 0.18,
      _fill(opacity: 0.70),
    );
    canvas.drawCircle(
      Offset(w * 0.72, h * 0.42),
      h * 0.18,
      _fill(opacity: 0.70),
    );
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.30),
      h * 0.24,
      _stroke(width: 2.0),
    );
    canvas.drawCircle(
      Offset(w * 0.28, h * 0.42),
      h * 0.18,
      _stroke(width: 2.0),
    );
    canvas.drawCircle(
      Offset(w * 0.72, h * 0.42),
      h * 0.18,
      _stroke(width: 2.0),
    );

    // A small leaf/frond accent
    canvas.drawLine(
      Offset(w * 0.50, h * 0.30),
      Offset(w * 0.50, h * 0.50),
      _stroke(width: 1.6),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IndigenousCommunitiesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void hut(double cx, double baseY, double scale, {double opacity = 1.0}) {
      final roofH = 0.32 * h * scale;
      final wallH = 0.22 * h * scale;
      final halfW = 0.16 * w * scale;
      final apexY = baseY - wallH - roofH;
      final eaveY = baseY - wallH;

      final roof = Path()
        ..moveTo(cx, apexY)
        ..lineTo(cx + halfW + 0.03 * w * scale, eaveY)
        ..lineTo(cx - halfW - 0.03 * w * scale, eaveY)
        ..close();
      canvas.drawPath(roof, _fill(opacity: 0.85 * opacity));
      canvas.drawPath(roof, _stroke(width: 2.0));

      final wall = Path()
        ..moveTo(cx - halfW, eaveY)
        ..lineTo(cx + halfW, eaveY)
        ..lineTo(cx + halfW, baseY)
        ..lineTo(cx - halfW, baseY)
        ..close();
      canvas.drawPath(wall, _fill(opacity: 0.18 * opacity));
      canvas.drawPath(wall, _stroke(width: 2.0));

      final doorTop = baseY - wallH * 0.65;
      final doorHalfW = halfW * 0.32;
      final door = Path()
        ..moveTo(cx - doorHalfW, baseY)
        ..lineTo(cx - doorHalfW, doorTop)
        ..lineTo(cx + doorHalfW, doorTop)
        ..lineTo(cx + doorHalfW, baseY);
      canvas.drawPath(door, _stroke(width: 1.8));
    }

    // Back row (2 smaller huts, peeking from behind)
    hut(w * 0.30, h * 0.66, 0.78, opacity: 0.85);
    hut(w * 0.70, h * 0.66, 0.78, opacity: 0.85);

    // Front row (3 huts)
    hut(w * 0.18, h * 0.96, 0.95);
    hut(w * 0.50, h * 0.96, 1.05);
    hut(w * 0.82, h * 0.96, 0.95);

    // Subtle ground line beneath the front row
    canvas.drawLine(
      Offset(w * 0.04, h * 0.97),
      Offset(w * 0.96, h * 0.97),
      _stroke(width: 1.4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Authorization Section
class AuthorizationSection extends StatefulWidget {
  final String language;

  const AuthorizationSection({super.key, required this.language});

  @override
  State<AuthorizationSection> createState() => _AuthorizationSectionState();
}

class _AuthorizationSectionState extends State<AuthorizationSection> {
  bool _showPDF = false;
  static const String _pdfViewerEnId = 'auth-pdf-viewer-en';
  static const String _pdfViewerEsId = 'auth-pdf-viewer-es';

  @override
  void initState() {
    super.initState();
    // Register PDF viewer factories for English and Spanish
    try {
      ui.platformViewRegistry.registerViewFactory(
        _pdfViewerEnId,
        (int viewId) => html.IFrameElement()
          ..src = 'assets/Documents/La_Bonga_Cartas.pdf#page=1&toolbar=1'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '800px'
          ..setAttribute('allowfullscreen', 'true')
          ..setAttribute('allow', 'fullscreen'),
      );
    } catch (e) {
      // Already registered
    }

    try {
      ui.platformViewRegistry.registerViewFactory(
        _pdfViewerEsId,
        (int viewId) => html.IFrameElement()
          ..src = 'assets/Documents/La_Bonga_Cartas.pdf#page=2&toolbar=1'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '800px'
          ..setAttribute('allowfullscreen', 'true')
          ..setAttribute('allow', 'fullscreen'),
      );
    } catch (e) {
      // Already registered
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    final inner = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 60,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _scrollToTop(context),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                widget.language == 'en'
                    ? 'Project Authorization'
                    : 'Autorización del Proyecto',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF101A2F),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Text(
                  widget.language == 'en'
                      ? 'During our exploratory expedition to the Indigenous Emberá/Wounaan community of La Bonga Pequení in the Panama Canal Watershed last summer 2025, community leaders invited us to return and present our participatory research methodology (PRM) to their governing congress because they understood the project\'s potential.\n\nAt their governing Congreso Local in June 2025, Indigenous Emberá and Wounaan leaders from communities inside the Chagres National Park (CNP) recognized "KU know-how" from previous successful mapping projects with their relatives in the eastern Darién Province back in the 1990s! The Congreso Local voted unanimously to ask our KU team of geographers to map their lands and help them develop a management plan acceptable to the Panamanian government.'
                      : 'Durante nuestra expedición exploratoria a la comunidad indígena Emberá/Wounaan de La Bonga Pequení en la Cuenca del Canal de Panamá el verano pasado de 2025, los líderes comunitarios nos invitaron a regresar y presentar nuestra metodología de investigación participativa (PRM) a su congreso rector porque entendieron el potencial del proyecto.\n\nEn su Congreso Local en junio de 2025, los líderes indígenas Emberá y Wounaan de comunidades dentro del Parque Nacional Chagres (PNC) reconocieron el "know-how de KU" gracias a proyectos de mapeo exitosos previos con sus parientes en la provincia oriental del Darién, ¡ya desde la década de 1990! El Congreso Local acordó por unanimidad solicitar a nuestro equipo de geógrafos de KU que mapearan sus tierras y les ayudaran a desarrollar un plan de manejo aceptable para el gobierno panameño.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFB9C6EA),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showPDF = !_showPDF;
                    });
                  },
                  child: Text(
                    _showPDF
                        ? (widget.language == 'en'
                              ? 'Hide Authorization Documents'
                              : 'Ocultar Documentos de Autorización')
                        : (widget.language == 'en'
                              ? 'View Authorization Documents'
                              : 'Ver Documentos de Autorización'),
                  ),
                ),
                if (_showPDF) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    height: isMobile ? 900 : 800,
                    child: HtmlElementView(
                      viewType: widget.language == 'en'
                          ? _pdfViewerEnId
                          : _pdfViewerEsId,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return inner;
  }

  void _scrollToTop(BuildContext context) {
    // Scroll to top of the page
    ScaffoldState? scaffoldState = Scaffold.maybeOf(context);
    if (scaffoldState != null) {
      scaffoldState.appBarMaxHeight;
    }
  }
}

// Methodology Section
class MethodologySection extends StatefulWidget {
  final String language;

  const MethodologySection({super.key, required this.language});

  @override
  State<MethodologySection> createState() => _MethodologySectionState();
}

class _MethodologySectionState extends State<MethodologySection> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    final stages = widget.language == 'en'
        ? [
            (
              '1. Training Workshops',
              'Researchers train and certify "community geographers" in a "toolbox" of geospatial skills for conservation management (sketch-mapping, basic cartography, and the use of questionnaires, topographic maps, the compass, the Global Positioning System (GPS), air photography and satellite imagery analysis, and drone use).',
            ),
            (
              '2. Creating Consensual Maps',
              'Through workshops and fieldwork community questionnaire data and hand-drawn sketch-maps on land use are converted into "consensual maps" showing agreed-upon place-names and resource-use locations.',
            ),
            (
              '3. Verification of Data',
              'The accuracy of the results and maps with precise coordinates are reviewed repeatedly in workshops and community meetings, and by government agencies.',
            ),
            (
              '4. Standardizing Map Products',
              'The consensual, community-produced maps are converted into standard maps that are scientifically accurate and recognized by government officials and other external, professional audiences.',
            ),
          ]
        : [
            (
              '1. Talleres de Capacitación',
              'Los investigadores capacitan y certifican a "geógrafos comunitarios" en una "caja de herramientas" de habilidades geoespaciales para el manejo de la conservación (mapeo esquemático, cartografía básica y el uso de cuestionarios, mapas topográficos, la brújula, el Sistema de Posicionamiento Global (GPS), análisis de fotografía aérea e imágenes satelitales, y uso de drones).',
            ),
            (
              '2. Creación de Mapas Consensuados',
              'Mediante talleres y trabajo de campo, los datos de cuestionarios comunitarios y los mapas esquemáticos hechos a mano sobre el uso de la tierra se convierten en "mapas consensuados" que muestran los topónimos acordados y las ubicaciones de uso de recursos.',
            ),
            (
              '3. Verificación de Datos',
              'La precisión de los resultados y de los mapas con coordenadas exactas se revisa repetidamente en talleres y reuniones comunitarias, y por agencias gubernamentales.',
            ),
            (
              '4. Estandarización de Productos Cartográficos',
              'Los mapas consensuados producidos por la comunidad se convierten en mapas estándar que son científicamente precisos y reconocidos por funcionarios gubernamentales y otras audiencias externas y profesionales.',
            ),
          ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 60,
        vertical: 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF101A2F),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 40,
              vertical: 40,
            ),
            child: Column(
              children: [
                Text(
                  widget.language == 'en'
                      ? 'Stages of Participatory Research Mapping (PRM)'
                      : 'Etapas del Mapeo de Investigación Participativa',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.language == 'en'
                      ? 'Unlike most research, PRM releases the research function to trained "community geographers" who co-design and implement the project as they interpret geo-spatial information alongside KU geographers and students.'
                      : 'A diferencia de la mayoría de las investigaciones, el PRM delega la función de investigación en "geógrafos comunitarios" capacitados que co-diseñan e implementan el proyecto mientras interpretan información geoespacial junto a geógrafos y estudiantes de KU.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFB9C6EA),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: stages.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.white.withOpacity(0.08),
                    ),
                    itemBuilder: (context, index) {
                      final stage = stages[index];
                      return Theme(
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.transparent,
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          title: Text(
                            stage.$1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          collapsedIconColor: const Color(0xFFB9C6EA),
                          iconColor: const Color(0xFF81C784),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              child: Text(
                                stage.$2,
                                style: const TextStyle(
                                  color: Color(0xFFB9C6EA),
                                  fontSize: 14,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Gallery Section
class GallerySection extends StatefulWidget {
  final String language;

  const GallerySection({super.key, required this.language});

  @override
  State<GallerySection> createState() => _GallerySectionState();
}

class _GallerySectionState extends State<GallerySection> {
  int _currentIndex = 0;
  final List<String> _images = [
    'assets/images/lancha.jpg',
    'assets/images/field_tour.jpg',
    'assets/images/indigenous_band.jpg',
    'assets/images/indigenous_girl_smiling.jpg',
    'assets/images/chief_checking.jpg',
    'assets/images/site_analysis.jpg',
    'assets/images/lizard.jpg',
    'assets/images/monkey.jpg',
  ];
  final List<(String, String)> _captions = [
    ('River lancha transport', 'Transporte en lancha por el río'),
    ('Field tour in watershed', 'Gira de campo en la cuenca hidrográfica'),
    ('Indigenous cultural performance', 'Presentación cultural indígena'),
    ('Community member portrait', 'Retrato de miembro de la comunidad'),
    (
      'Community leadership engagement',
      'Participación del liderazgo comunitario',
    ),
    (
      'Site analysis at Panamanian Geographic Institute',
      'Análisis del sitio en el Instituto Geográfico de Panamá',
    ),
    ('Rainforest lizard', 'Lagarto del bosque tropical'),
    ('White-Faced Capuchin Monkey', 'Mono Capuchino de Cara Blanca'),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 60,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // Scroll or click effect for heading
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                widget.language == 'en'
                    ? 'Fieldwork & Landscape'
                    : 'Trabajo de Campo y Paisaje',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 800,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF101A2F),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ZoomableImage(
                          imagePath: _images[_currentIndex % _images.length],
                          height: isMobile ? 380 : 580,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF101A2F),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.language == 'en'
                                ? _captions[_currentIndex % _captions.length].$1
                                : _captions[_currentIndex % _captions.length]
                                      .$2,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: const Color(0xFFB9C6EA),
                                  fontSize: 16,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: () {
                                  setState(() => _currentIndex--);
                                },
                              ),
                              Text(
                                '${_currentIndex % _captions.length + 1} / ${_captions.length}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: const Color(0xFFB9C6EA)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: () {
                                  setState(() => _currentIndex++);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Team Photo Carousel (signing + team photo)
class _TeamPhotoCarousel extends StatefulWidget {
  final String language;
  const _TeamPhotoCarousel({required this.language});

  @override
  State<_TeamPhotoCarousel> createState() => _TeamPhotoCarouselState();
}

class _TeamPhotoCarouselState extends State<_TeamPhotoCarousel> {
  int _currentIndex = 0;

  final List<String> _images = [
    'assets/images/signing.jpeg',
    'assets/images/team_photo.jpg',
  ];

  List<(String, String)> get _captions => [
    (
      'Indigenous Local Congress inviting KU geographers to do participatory mapping of their communities in the Chagres National Park to produce the cartographic and statistical data needed for a conservation zoning plan. Photo shows Emberá Chief Marcelino Guático and Community President Elieser Adames signing the legal request (pedido) formalizing the KU Chagres Initiative (Taylor Tappan and Cap McLiney are also shown).',
      'Congreso Local Indígena invitando a los geógrafos de KU a realizar el mapeo participativo de sus comunidades en el Parque Nacional Chagres para producir los datos cartográficos y estadísticos necesarios para un plan de zonificación de conservación. La foto muestra al Jefe Emberá Marcelino Guático y al Presidente Comunitario Elieser Adames firmando la solicitud legal (pedido) que formaliza la Iniciativa Chagres de KU (Taylor Tappan y Cap McLiney también aparecen en la foto).',
    ),
    (
      'Original KU Research Team of Dr. Peter Herlihy, Cap McLiney, Amalie Hipp, Sam Morrow and Dr. Taylor Tappan on Barro Colorado Island in Lake Gatún, Panama Canal Zone, June 2025.',
      'Equipo de Investigación Original de KU del Dr. Peter Herlihy, Cap McLiney, Amalie Hipp, Sam Morrow y Dr. Taylor Tappan en la Isla Barro Colorado en el Lago Gatún, Zona del Canal de Panamá, junio de 2025.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final idx = _currentIndex % _images.length;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 700),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF101A2F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ZoomableImage(
                  imagePath: _images[idx],
                  height: isMobile ? 300 : 450,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF101A2F),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFB9C6EA),
                        fontSize: 14,
                      ),
                      children: _buildCISpans(
                        widget.language == 'en'
                            ? _captions[idx].$1
                            : _captions[idx].$2,
                        Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFB9C6EA),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => setState(() => _currentIndex--),
                      ),
                      Text(
                        '${idx + 1} / ${_images.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFB9C6EA),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setState(() => _currentIndex++),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Maps Section
class MapsSection extends StatelessWidget {
  final String language;

  const MapsSection({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 60,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // Heading click effect
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                language == 'en' ? 'Project Maps' : 'Mapas del Proyecto',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              const mapAspectH = 1237.0 / 1600.0; // height/width ratio

              final captionText = Text(
                language == 'en'
                    ? 'This map shows the Río Pequení Chagres National Park — the geographic setting and subsistence area of our participatory research mapping work with the resident Indigenous communities, including La Bonga.'
                    : 'Este mapa muestra el Parque Nacional Chagres del Río Pequení — el escenario geográfico y área de subsistencia de nuestro trabajo de mapeo participativo de investigación con las comunidades indígenas residentes, incluyendo La Bonga.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFB9C6EA),
                ),
              );

              final openMapsButton = ElevatedButton(
                onPressed: () {
                  launchUrl(
                    Uri.parse(
                      'https://www.google.com/maps/place/San+Juan+de+Pequní+Indígena+(+La+Bonga)/@9.3827301,-79.5241626,17z/data=!3m1!4b1!4m6!3m5!1s0x8fab494a734c2493:0xe55e405b5412d0dc!8m2!3d9.3827301!4d-79.5215877!16s%2Fg%2F11mtjt0g7z?entry=ttu',
                    ),
                  );
                },
                child: Text(
                  language == 'en'
                      ? 'Open La Bonga in Google Maps'
                      : 'Abrir La Bonga en Google Maps',
                ),
              );

              if (isMobile) {
                // Mobile: stacked column
                const displayHeight = 563.0;
                const imageAspectRatio = 1600.0 / 1237.0;
                final displayWidth = math.min(
                  constraints.maxWidth,
                  displayHeight * imageAspectRatio,
                );
                final iframeHeight = displayWidth / 1.6;
                return Center(
                  child: Container(
                    width: displayWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFF101A2F),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ZoomableImage(
                            imagePath: 'assets/images/chagres_broadermap.jpg',
                            height: displayHeight,
                            width: displayWidth,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        captionText,
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: displayWidth,
                            height: iframeHeight,
                            child: _GoogleMapEmbed(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        openMapsButton,
                      ],
                    ),
                  ),
                );
              }

              // Desktop: side-by-side row
              const gap = 16.0;
              const cardPadding = 12.0;
              final colWidth =
                  (constraints.maxWidth - gap - cardPadding * 2) / 2;
              final mapHeight = colWidth * mapAspectH;

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF101A2F),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(cardPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: project map image + caption
                    SizedBox(
                      width: colWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ZoomableImage(
                              imagePath: 'assets/images/chagres_broadermap.jpg',
                              height: mapHeight,
                              width: colWidth,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 12),
                          captionText,
                        ],
                      ),
                    ),
                    const SizedBox(width: gap),
                    // Right: Google Maps iframe + open button
                    SizedBox(
                      width: colWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: colWidth,
                              height: mapHeight,
                              child: _GoogleMapEmbed(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          openMapsButton,
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Google Maps Embed Widget
class _GoogleMapEmbed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const HtmlElementView(viewType: 'google-maps-embed');
  }
}

// Reports Section
// Reports Section
class ReportsSection extends StatefulWidget {
  final String language;

  const ReportsSection({super.key, required this.language});

  @override
  State<ReportsSection> createState() => _ReportsSectionState();
}

class _ReportsSectionState extends State<ReportsSection> {
  int _selectedTab = 0; // 0 = Blog, 1 = Official Reports

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 60,
      ),
      child: Column(
        children: [
          Text(
            widget.language == 'en' ? 'Field Reports' : 'Informes de Campo',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            widget.language == 'en'
                ? 'Explore our gallery of Substack posts and field reflections. Official research reports will be available as PDFs here.'
                : 'Explore nuestra galería de publicaciones de Substack y reflexiones de campo. Los informes de investigación oficiales estarán disponibles como PDF aquí.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFFB9C6EA)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Tab Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedTab = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedTab == 0
                        ? const Color(0xFF0051BA)
                        : const Color(0xFF101A2F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.language == 'en' ? 'Field Blog' : 'Blog de Campo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => setState(() => _selectedTab = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedTab == 1
                        ? const Color(0xFF0051BA)
                        : const Color(0xFF101A2F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.language == 'en'
                        ? 'Official Reports'
                        : 'Informes Oficiales',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Tab Content
          if (_selectedTab == 0)
            _buildReportCard(
              context,
              widget.language == 'en' ? 'Field Blog' : 'Blog de Campo',
              widget.language == 'en'
                  ? 'Narrative updates from the field, participatory mapping workshops, and watershed engagement activities.'
                  : 'Actualizaciones narrativas del campo, talleres de mapeo participativo y actividades de involucramiento con las cuencas hidrográficas.',
            )
          else
            _buildReportCard(
              context,
              widget.language == 'en'
                  ? 'Official Reports'
                  : 'Informes Oficiales',
              widget.language == 'en'
                  ? 'Formal reports, project summaries, grant documentation, and technical outputs.'
                  : 'Informes formales, resúmenes de proyectos, documentación de subvenciones y resultados técnicos.',
            ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    String title,
    String description,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101A2F),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 34,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFFB9C6EA),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// FAQ Section
class FAQSection extends StatelessWidget {
  final String language;

  const FAQSection({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    final faqs = language == 'en'
        ? [
            (
              'Why does the health of Chagres National Park matter for people in the United States?',
              'Chagres National Park provides approximately 40 percent of the freshwater used by Panama Canal operations and drinking water for more than 2 million people in Panama City and Colón. The Canal remains one of the most strategically important global trade corridors, moving a significant portion of U.S.-bound maritime commerce.\n\nRecent droughts have demonstrated that water scarcity is one of the canal\'s greatest operational threats. Long-term watershed health directly affects trade reliability, regional diplomatic stability, and economic security.',
            ),
            (
              'Who and what legal authority authorizes this project?',
              'This initiative proceeds only with community consent and institutional coordination. During a reconnaissance expedition in Summer 2025, the research team met with the Indigenous community of San Juan Pequeñí, participated in a formal Local Congress, and received written approval.\n\nThis authorization aligns with Panama\'s 2008 Law 72 governing Collective Indigenous Lands. The project continues only through collaborative agreement with community leadership.',
            ),
            (
              'How does "mapping" help protect an area like this?',
              'National park boundaries alone do not ensure forest protection or water security. Effective stewardship requires understanding the ecological and social processes occurring within those boundaries.\n\nParticipatory research mapping translates Indigenous geographic knowledge into structured formats that can support zoning, monitoring, and long-term governance planning. At a fundamental level, it is difficult to protect what is not clearly understood.',
            ),
            (
              'How are community members involved and compensated?',
              'Community representatives are trained and certified as local geographers in GPS data collection and mapping techniques. Participants are compensated for their time and expertise.',
            ),
            (
              'How long will the project take?',
              'We estimate the Chagres Initiative will have 3 overlapping phases requiring about three years in total to complete depending on funding availability:\n\nYear 1-2: Participatory research mapping and geospatial database development.\nYear 1-2: Develop proposed consensus-driven zoning and community land-use guidelines.\nYear 2-3: Final map production, synthesis, and integration into management planning frameworks.\n\nThe participatory research mapping approach is iterative, with alternating workshops and field research in Panama followed by GIS and computer mapping analyzes at the universities to obtain the most precise cartographic and spatial data on resource use in the Chagres National Park for developing an Indigenous and state approved management plan for land use in the park.',
            ),
            (
              'How will donated funds be used?',
              'Your support funds all field-based research and community collaboration. Included are the workshops, equipment (GPS, drones, Starlink), and expenses of local geographers, researchers and students.',
            ),
            (
              'Is this project political?',
              'The project is non-partisan and research-driven. Its focus is watershed stewardship, participatory governance, and environmental monitoring.',
            ),
            (
              'Will the data be publicly available?',
              'Final authorship will be shared by team members, community and governmental participants. Sensitive knowledge remains under community control.',
            ),
            (
              'Can this model be replicated elsewhere?',
              'Yes. This is a new framework for community-based research with a novel public-private funding formula combined with 21st century geospatial and A.I. innovations designed to engage the public ranging from Indigenous villages to metropolitan centers. We hope to connect people of all backgrounds and educations with our research.\n\nWe hope to channel the power of tax-deductible donations and connect the people and institutions that make them with the on-the-ground and in-the-university realities of fieldwork on a strategic, geopolitical issue of global importance: Water Security of the Panama Canal.',
            ),
            (
              'Hasn\'t the whole world been mapped already?',
              'No. There is a difference between remote imagery of an area from satellites and the kinds of maps we are making. The level of detail combining physical geography with cultural-historical information in the community is unique and critical to our process.',
            ),
          ]
        : [
            (
              '¿Por qué importa la salud del Parque Nacional Chagres para la gente de los Estados Unidos?',
              'El Parque Nacional Chagres proporciona aproximadamente el 40 por ciento del agua dulce utilizada en las operaciones del Canal de Panamá y agua potable para más de 2 millones de personas en la Ciudad de Panamá y Colón. El Canal sigue siendo uno de los corredores comerciales globales más estratégicamente importantes, y por él circula una parte significativa del comercio marítimo con destino a EE.UU.\n\nLas sequías recientes han demostrado que la escasez de agua es una de las mayores amenazas operativas del Canal. La salud de la cuenca a largo plazo afecta directamente la confiabilidad del comercio, la estabilidad diplomática regional y la seguridad económica.',
            ),
            (
              '¿Quién y qué autoridad legal autoriza este proyecto?',
              'Esta iniciativa procede solo con consentimiento comunitario y coordinación institucional. Durante una expedición de reconocimiento en verano de 2025, el equipo de investigación se reunió con la comunidad indígena de San Juan Pequeñí, participó en un Congreso Local formal y recibió aprobación escrita.\n\nEsta autorización se alinea con la Ley 72 de 2008 de Panamá que rige las Tierras Colectivas Indígenas. El proyecto continúa solo mediante acuerdo colaborativo con el liderazgo comunitario.',
            ),
            (
              '¿Cómo ayuda el "mapeo" a proteger un área como esta?',
              'Los límites del parque nacional por sí solos no garantizan la protección forestal ni la seguridad hídrica. El manejo efectivo requiere comprender los procesos ecológicos y sociales que ocurren dentro de esos límites.\n\nEl mapeo participativo de investigación traduce el conocimiento geográfico indígena a formatos estructurados que pueden apoyar la zonificación, el monitoreo y la planificación de gobernanza a largo plazo. En un nivel fundamental, es difícil proteger lo que no se entiende claramente.',
            ),
            (
              '¿Cómo participan y son compensados los miembros de la comunidad?',
              'Los representantes comunitarios son capacitados y certificados como geógrafos locales en recopilación de datos GPS y técnicas de mapeo. Los participantes reciben compensación por su tiempo y experiencia.',
            ),
            (
              '¿Cuánto tiempo tomará el proyecto?',
              'Estimamos que la Iniciativa Chagres tendrá 3 fases superpuestas que requerirán aproximadamente tres años en total para completarse dependiendo de la disponibilidad de fondos:\n\nAño 1-2: Mapeo participativo de investigación y desarrollo de base de datos geoespacial.\nAño 1-2: Desarrollar propuestas de zonificación impulsada por consenso y directrices de uso del suelo comunitario.\nAño 2-3: Producción final del mapa, síntesis e integración en marcos de planificación de manejo.\n\nEl enfoque de mapeo participativo de investigación es iterativo, con talleres e investigación de campo alternados en Panamá seguidos de análisis de SIG y mapeo computarizado en las universidades para obtener los datos cartográficos y espaciales más precisos sobre el uso de recursos en el Parque Nacional Chagres para desarrollar un plan de manejo de uso del suelo aprobado por las comunidades indígenas y el estado.',
            ),
            (
              '¿Cómo se usarán los fondos donados?',
              'Su apoyo financia toda la investigación de campo y la colaboración comunitaria. Se incluyen los talleres, equipos (GPS, drones, Starlink) y los gastos de geógrafos locales, investigadores y estudiantes.',
            ),
            (
              '¿Es este proyecto político?',
              'El proyecto es apartidista e impulsado por la investigación. Su enfoque es el manejo de cuencas hidrográficas, gobernanza participativa y monitoreo ambiental.',
            ),
            (
              '¿Estarán los datos disponibles públicamente?',
              'La autoría final será compartida por los miembros del equipo, participantes comunitarios y gubernamentales. El conocimiento sensible permanece bajo control comunitario.',
            ),
            (
              '¿Se puede replicar este modelo en otros lugares?',
              'Sí. Este es un nuevo marco para la investigación comunitaria con una fórmula de financiación público-privada novedosa combinada con innovaciones geoespaciales y de I.A. del siglo XXI diseñadas para involucrar al público, desde comunidades indígenas hasta centros metropolitanos. Esperamos conectar a personas de todos los orígenes y niveles de educación con nuestra investigación.\n\nEsperamos canalizar el poder de las donaciones deducibles de impuestos y conectar a las personas e instituciones que las realizan con las realidades del trabajo de campo, tanto sobre el terreno como en la universidad, en un tema estratégico y geopolítico de importancia global: la Seguridad Hídrica del Canal de Panamá.',
            ),
            (
              '¿No ha sido mapeado ya todo el mundo?',
              'No. Hay una diferencia entre la teledetección satelital de un área y los tipos de mapas que estamos haciendo. El nivel de detalle que combina geografía física con información cultural-histórica en la comunidad es único y crítico para nuestro proceso.',
            ),
          ];

    return Container(
      // Transparent so the surrounding green band + jungle side strips
      // show through.
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 60,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // Heading click effect
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                language == 'en'
                    ? 'Frequently Asked Questions'
                    : 'Preguntas Frecuentes',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF101A2F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                return _buildFAQItem(
                  context,
                  faqs[index].$1,
                  faqs[index].$2,
                  index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context,
    String question,
    String answer,
    int index,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          question,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        children: [
          Text.rich(
            TextSpan(
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB0B8C8),
                height: 1.6,
                fontSize: 16,
              ),
              children: _buildCISpans(
                answer,
                Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFB0B8C8),
                  height: 1.6,
                  fontSize: 16,
                ),
              ),
            ),
            textAlign: TextAlign.left,
          ),
        ],
        shape: Border.all(color: Colors.transparent),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
      ),
    );
  }
}

// Giving Levels Section
class GivingLevelsSection extends StatefulWidget {
  final String language;

  const GivingLevelsSection({super.key, required this.language});

  @override
  State<GivingLevelsSection> createState() => _GivingLevelsSectionState();
}

class _GivingLevelsSectionState extends State<GivingLevelsSection> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    final givingLevels = [
      (
        widget.language == 'en' ? 'Community Supporter' : 'Donante Comunitario',
        widget.language == 'en' ? '< \$100' : '< \$100',
        widget.language == 'en'
            ? 'Donors funding field essentials - first aid kits, Starlink, dry bags, notebooks, river travel, batteries, tents, housing when working far from infrastructure.'
            : 'Donantes que financian elementos esenciales de campo: botiquines de primeros auxilios, Starlink, bolsas secas, cuadernos, viajes por río, baterías, tiendas de campaña y alojamiento al trabajar lejos de cualquier infraestructura.',
      ),
      (
        widget.language == 'en' ? 'Action Supporter' : 'Donante de Acción',
        widget.language == 'en' ? '\$100 - \$250' : '\$100 - \$250',
        widget.language == 'en'
            ? 'Donors supporting in-country logistics - travel between Panama City and the field, transporting equipment, and coordinating with local partners and institutions. Pays for fuel and boat travel. There are no roads in - everything moves by river.'
            : 'Donantes que apoyan la logística en el país: viajes entre la Ciudad de Panamá y el campo, transporte de equipos y coordinación con socios locales e instituciones. Cubre combustible y viajes en barco. No hay carreteras; todo se transporta por río.',
      ),
      (
        widget.language == 'en'
            ? 'Stewardship Supporter'
            : 'Donante de Custodia',
        widget.language == 'en' ? '\$250 - \$1,000' : '\$250 - \$1,000',
        widget.language == 'en'
            ? 'International travel for university students and professors.'
            : 'Viajes internacionales para estudiantes y profesores universitarios.',
      ),
      (
        widget.language == 'en' ? 'Wisdom Supporter' : 'Donante Visionario',
        widget.language == 'en' ? '\$1,000 - \$5,000' : '\$1,000 - \$5,000',
        widget.language == 'en'
            ? 'Workshops and participatory mapping session costs – renting locale, tables, chairs; meals and housing for participants, printing mapping materials.'
            : 'Costos de talleres y sesiones de mapeo participativo: alquiler de local, mesas, sillas; comidas y alojamiento para participantes, impresión de materiales de mapeo.',
      ),
      (
        widget.language == 'en'
            ? 'Visionary & Institutional'
            : 'Visionario e Institucional',
        widget.language == 'en' ? '> \$5,000' : '> \$5,000',
        widget.language == 'en'
            ? 'Stipends for community geographers, students, and faculty. No salaries are paid. Donor supports local costs of food, lodging, and transportation in Panama City and in the Chagres National Park.'
            : 'Estipendios para geógrafos comunitarios, estudiantes y profesores. No se pagan salarios. El donante financia costos locales de comida, alojamiento y transporte en la Ciudad de Panamá y en el Parque Nacional Chagres.',
      ),
    ];

    return Container(
      // Transparent so the surrounding green band + jungle side strips
      // show through.
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 60,
      ),
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.white),
              children: _buildCISpans(
                widget.language == 'en'
                    ? 'Support the Chagres Initiative'
                    : 'Apoya la Iniciativa Chagres',
                Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: const TextStyle(color: Color(0xFFB9C6EA), fontSize: 16),
              children: _buildCISpans(
                widget.language == 'en'
                    ? 'All donated funds are used in the Chagres Initiative Research Fund to be used exclusively for project activities.\n\nThe descriptions of each supporter category are just examples of how funds could be used.'
                    : 'Todos los fondos donados se utilizan en el Fondo de Investigación de la Iniciativa Chagres para ser utilizados exclusivamente para actividades del proyecto.\n\nLas descripciones de cada categoría de donante son solo ejemplos de cómo podrían utilizarse los fondos.',
                const TextStyle(color: Color(0xFFB9C6EA), fontSize: 16),
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Inner blue box container
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF101A2F),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 34,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                // Donation Button
                GestureDetector(
                  onTap: _openDonationPage,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: _HoverGlow(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFA0291E),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: const Color(0xFFA0291E),
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                        child: widget.language == 'en'
                            ? Text.rich(
                                TextSpan(
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Please '),
                                    const TextSpan(
                                      text: 'Click',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const TextSpan(text: ' to '),
                                    const TextSpan(
                                      text: 'Contribute',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const Text(
                                'Haga clic aquí para contribuir',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Giving Levels List
                Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: givingLevels.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 0),
                    itemBuilder: (context, index) {
                      final level = givingLevels[index];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(0.12),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(splashColor: Colors.transparent),
                          child: ExpansionTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  level.$1,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  level.$2,
                                  style: const TextStyle(
                                    color: Color(0xFF81C784),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            collapsedIconColor: const Color(0xFFB9C6EA),
                            iconColor: const Color(0xFF81C784),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                child: Text(
                                  level.$3,
                                  style: const TextStyle(
                                    color: Color(0xFFB9C6EA),
                                    fontSize: 14,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Team Section
class TeamSection extends StatelessWidget {
  final String language;

  const TeamSection({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final isPhone = screenWidth < 600;

    final content = Stack(
      children: [
        if (!isPhone)
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.12, 0.88, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/images/la_bonga_vista.jpeg',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                color: const Color(0xFF0C1328).withOpacity(0.55),
                colorBlendMode: BlendMode.srcOver,
              ),
            ),
          ),
        Container(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 20 : 60,
            24,
            isMobile ? 20 : 60,
            60,
          ),
          child: Column(
            children: [
              Text(
                language == 'en' ? 'Research Team' : 'Equipo de Investigación',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 24),
              // Team Photo Carousel
              _TeamPhotoCarousel(language: language),
              const SizedBox(height: 40),
              // La Bonga Section
              _buildTeamSection(
                context,
                language == 'en'
                    ? 'La Bonga Personnel'
                    : 'Personal de La Bonga',
                [
                  (
                    'Marcelino Guatico',
                    'Chief of La Bonga',
                    'Nokó de La Bonga',
                    '',
                    'labonga_seal.png',
                  ),
                  (
                    'Elieser Adames',
                    'President of La Bonga',
                    'Presidente de La Bonga',
                    '',
                    'labonga_seal.png',
                  ),
                ],
                language,
                isMobile,
              ),
              const SizedBox(height: 40),
              // University of Kansas Section
              _buildTeamSection(
                context,
                language == 'en'
                    ? 'University of Kansas Personnel'
                    : 'Personal de la Universidad de Kansas',
                [
                  (
                    'Dr. Peter Herlihy',
                    'Professor of Geography',
                    'Profesor de Geografía',
                    'herlihy@ku.edu',
                    'peter1.jpg',
                  ),
                  (
                    'Cap McLiney',
                    'PhD Student',
                    'Estudiante de Doctorado',
                    'cmclineyjr@ku.edu',
                    'cap.png',
                  ),
                  (
                    'Amalie Hipp',
                    'PhD Student',
                    'Estudiante de Doctorado',
                    'ahippe@ku.edu',
                    'Hipp_Headshot.jpg',
                  ),
                  (
                    'Ollie Berwanger',
                    'Undergraduate Researcher',
                    'Investigador de Pregrado',
                    'cash.berwanger@ku.edu',
                    'geog_logo.jpg',
                  ),
                  (
                    'Oliver Zigmund',
                    'Undergraduate Researcher',
                    'Investigador de Pregrado',
                    'oliverlzigmund@ku.edu',
                    'geog_logo.jpg',
                  ),
                ],
                language,
                isMobile,
              ),
            ],
          ),
        ),
      ],
    );

    return content;
  }

  Widget _buildTeamSection(
    BuildContext context,
    String title,
    List<(String, String, String, String, String)> members,
    String language,
    bool isMobile,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: members
                .map(
                  (member) => SizedBox(
                    width: isMobile
                        ? ((MediaQuery.of(context).size.width - 40) / 2) - 5
                        : 150,
                    height: isMobile
                        ? ((MediaQuery.of(context).size.width - 40) / 2) - 5
                        : 150,
                    child: _buildTeamCard(
                      context,
                      member.$1,
                      language == 'en' ? member.$2 : member.$3,
                      member.$4,
                      member.$5,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(
    BuildContext context,
    String name,
    String position,
    String email,
    String imageName,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101A2F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[700],
            backgroundImage: AssetImage('assets/images/$imageName'),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            position,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFFB9C6EA),
              fontSize: 12,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Contact Us Section
class ContactUsSection extends StatelessWidget {
  final String language;

  const ContactUsSection({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 60,
      ),
      child: Column(
        children: [
          Text(
            language == 'en' ? 'Contact Us' : 'Contáctenos',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF101A2F),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 34,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Text.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFB9C6EA),
                    ),
                    children: _buildCISpans(
                      language == 'en'
                          ? 'Have questions about the Chagres Initiative? We\'d love to hear from you.'
                          : '¿Tiene preguntas sobre la Iniciativa Chagres? Nos encantaría tener noticias suyas.',
                      Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFB9C6EA),
                      ),
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    launchUrl(Uri.parse('mailto:chagresinitiative@ku.edu'));
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0051BA),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0051BA).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      child: Text(
                        language == 'en'
                            ? 'Email us at: chagresinitiative@ku.edu'
                            : 'Envíenos un correo a: chagresinitiative@ku.edu',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Footer Section
class FooterSection extends StatelessWidget {
  final String language;
  final Function(String) onLanguageChanged;

  const FooterSection({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      color: const Color(0xFF0C1328),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 40,
      ),
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFFB9C6EA)),
              children: _buildCISpans(
                '© 2026 Chagres Initiative',
                Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFFB9C6EA)),
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => onLanguageChanged('en'),
                child: Text(
                  'English',
                  style: TextStyle(
                    color: language == 'en'
                        ? Colors.white
                        : const Color(0xFFB9C6EA),
                    fontWeight: language == 'en'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              const Text(' | ', style: TextStyle(color: Color(0xFFB9C6EA))),
              GestureDetector(
                onTap: () => onLanguageChanged('es'),
                child: Text(
                  'Español',
                  style: TextStyle(
                    color: language == 'es'
                        ? Colors.white
                        : const Color(0xFFB9C6EA),
                    fontWeight: language == 'es'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Newsletter Section
class NewsletterSection extends StatefulWidget {
  final String language;

  const NewsletterSection({super.key, required this.language});

  @override
  State<NewsletterSection> createState() => _NewsletterSectionState();
}

class _NewsletterSectionState extends State<NewsletterSection> {
  void _subscribeToSubstack() {
    launchUrl(Uri.parse('https://chagresinitiative.substack.com/'));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 60,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF101A2F),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 60,
          vertical: 50,
        ),
        child: Column(
          children: [
            Text(
              widget.language == 'en'
                  ? 'Stay Updated'
                  : 'Manténgase Actualizado',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFB9C6EA),
                ),
                children: _buildCISpans(
                  widget.language == 'en'
                      ? 'Subscribe to our Substack for the latest research updates, field reflections, and news from the Chagres Initiative.'
                      : 'Suscríbase a nuestro Substack para recibir las últimas actualizaciones de investigación, reflexiones de campo y noticias de la Iniciativa Chagres.',
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFB9C6EA),
                  ),
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _subscribeToSubstack,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0051BA),
                        const Color(0xFF0051BA).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0051BA).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  child: Text(
                    widget.language == 'en'
                        ? 'Subscribe on Substack'
                        : 'Suscribirse en Substack',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.language == 'en'
                  ? '@chagresinitiative'
                  : '@chagresinitiative',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF81C784)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Fade-in Animation Wrapper
class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeInAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}

// Decorative jungle silhouette running down one margin of the green band.
// Uses palms.jpg, heavily green-tinted, faded toward the content center,
// with a very slow vertical drift for subtle motion. Non-interactive.
class _JungleSideStrip extends StatefulWidget {
  final bool mirror;
  final double width;

  const _JungleSideStrip({required this.mirror, this.width = 260});

  @override
  State<_JungleSideStrip> createState() => _JungleSideStripState();
}

class _JungleSideStripState extends State<_JungleSideStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift;

  @override
  void initState() {
    super.initState();
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: widget.width,
        height: double.infinity,
        child: ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            begin: widget.mirror ? Alignment.centerRight : Alignment.centerLeft,
            end: widget.mirror ? Alignment.centerLeft : Alignment.centerRight,
            colors: const [
              Color(0xFFFFFFFF),
              Color(0xAAFFFFFF),
              Color(0x00FFFFFF),
            ],
            stops: const [0.0, 0.55, 1.0],
          ).createShader(rect),
          blendMode: BlendMode.dstIn,
          child: AnimatedBuilder(
            animation: _drift,
            builder: (context, child) {
              final t = Curves.easeInOut.transform(_drift.value);
              return Transform.translate(
                offset: Offset(0, (t - 0.5) * 30),
                child: child,
              );
            },
            child: Transform(
              alignment: Alignment.center,
              transform: widget.mirror
                  ? Matrix4.diagonal3Values(-1, 1, 1)
                  : Matrix4.identity(),
              child: Opacity(
                opacity: 0.38,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/palms.jpg'),
                      repeat: ImageRepeat.repeatY,
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter,
                      colorFilter: ColorFilter.mode(
                        Color(0xCC16402E),
                        BlendMode.multiply,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Adds a soft glow + gentle scale-up on hover. Shape-aware via borderRadius.
class _HoverGlow extends StatefulWidget {
  final Widget child;
  final BorderRadiusGeometry borderRadius;
  final Color glowColor;
  final double blurRadius;
  final double spreadRadius;
  final double scale;

  const _HoverGlow({
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
    this.glowColor = const Color(0xFFFFC766),
    this.blurRadius = 26,
    this.spreadRadius = 2,
    this.scale = 1.03,
  });

  @override
  State<_HoverGlow> createState() => _HoverGlowState();
}

class _HoverGlowState extends State<_HoverGlow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: _hover
            ? (Matrix4.identity()..scale(widget.scale))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: widget.glowColor.withOpacity(0.55),
                    blurRadius: widget.blurRadius,
                    spreadRadius: widget.spreadRadius,
                  ),
                ]
              : const [],
        ),
        child: widget.child,
      ),
    );
  }
}

// Scroll-triggered reveal: fades + slides the child up once its top
// edge enters ~92% of the viewport. One-shot per section.
class RevealOnScroll extends StatefulWidget {
  final Widget child;
  final double offsetY;
  final Duration duration;
  final Duration delay;

  const RevealOnScroll({
    super.key,
    required this.child,
    this.offsetY = 28,
    this.duration = const Duration(milliseconds: 750),
    this.delay = Duration.zero,
  });

  @override
  State<RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<RevealOnScroll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ScrollPosition? _position;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    WidgetsBinding.instance.addPostFrameCallback((_) => _attach());
  }

  void _attach() {
    if (!mounted) return;
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) {
      // No scrollable ancestor — just reveal immediately.
      _fire();
      return;
    }
    _position = scrollable.position;
    _position!.addListener(_check);
    _check();
  }

  void _check() {
    if (_triggered || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final screenH = MediaQuery.of(context).size.height;
    final topY = box.localToGlobal(Offset.zero).dy;
    if (topY < screenH * 0.92) _fire();
  }

  void _fire() {
    if (_triggered) return;
    _triggered = true;
    _position?.removeListener(_check);
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _position?.removeListener(_check);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_controller.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * widget.offsetY),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// Helper Widget for Zoomable Images with Keyboard Support
class ZoomableImage extends StatefulWidget {
  final String imagePath;
  final double height;
  final double width;
  final BoxFit fit;

  const ZoomableImage({
    required this.imagePath,
    this.height = 400,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    Key? key,
  }) : super(key: key);

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _showZoomDialog() {
    showDialog(
      context: context,
      builder: (context) => ZoomImageDialog(imagePath: widget.imagePath),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showZoomDialog,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: FadeInAnimation(
          child: Image.asset(
            widget.imagePath,
            height: widget.height,
            width: widget.width,
            fit: widget.fit,
          ),
        ),
      ),
    );
  }
}

// Zoomable Image Dialog with Keyboard Support
class ZoomImageDialog extends StatefulWidget {
  final String imagePath;
  final int initialIndex;
  final List<String>? imageList;

  const ZoomImageDialog({
    required this.imagePath,
    this.initialIndex = 0,
    this.imageList,
    Key? key,
  }) : super(key: key);

  @override
  State<ZoomImageDialog> createState() => _ZoomImageDialogState();
}

class _ZoomImageDialogState extends State<ZoomImageDialog> {
  late FocusNode _focusNode;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _currentIndex = widget.initialIndex;
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      child: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: _handleKeyEvent,
        child: Stack(
          children: [
            PhotoView(
              imageProvider: AssetImage(widget.imagePath),
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 2.0,
              enableRotation: false,
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Press ESC to close',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
