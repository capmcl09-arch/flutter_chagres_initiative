import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:html' as html;
import 'dart:ui' as dart_ui;
import 'dart:ui_web' as ui;
import 'dart:math' as math;

void main() {
  // Register the Google Maps iframe view factory for web
  ui.platformViewRegistry.registerViewFactory(
    'google-maps-embed',
    (int viewId) => html.IFrameElement()
      ..src = 'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3949.823992608622!2d-79.5241626!3d9.3827301!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x8fab494a734c2493%3A0xe55e405b5412d0dc!2sSan%20Juan%20de%20Pequen%C3%AD%20Ind%C3%ADgena%20(La%20Bonga)!5e1!3m2!1sen!2sus!4v1730000000000'
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
    spans.add(TextSpan(
      text: ciWord,
      style: (baseStyle ?? const TextStyle()).copyWith(fontStyle: FontStyle.italic),
    ));
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
        scaffoldBackgroundColor: const Color(0xFF070C18),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0C1328),
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0051ba),
          brightness: Brightness.dark,
          background: const Color(0xFF070C18),
          surface: const Color(0xFF101A2F),
        ),
      ),
      home: ChagresHome(
        language: _language,
        onLanguageChanged: _setLanguage,
      ),
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
  double _screenHeight = 800.0;
  
  // GlobalKey references for each section
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _methodologyKey = GlobalKey();
  final GlobalKey _fieldworkKey = GlobalKey();
  final GlobalKey _teamKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();
  final GlobalKey _reportsKey = GlobalKey();
  final GlobalKey _partnershipsKey = GlobalKey();
  final GlobalKey _givingLevelsKey = GlobalKey();

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
    precacheImage(
      const AssetImage('assets/images/jayhawk.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/palms.jpg'),
      context,
    );
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
    
    // Track active section
    _updateActiveSection();
  }

  void _updateActiveSection() {
    final Map<GlobalKey, String> sections = {
      _partnershipsKey: 'Collaborators',
      _teamKey: 'Team',
      _aboutKey: 'About',
      _methodologyKey: 'Methodology',
      _reportsKey: 'Fieldwork',
      _faqKey: 'FAQ',
      _givingLevelsKey: 'Support',
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
  
  void _scrollToSection(GlobalKey key, {double alignment = 0.50}) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        alignment: alignment,
      );
    }
  }
  
  void _scrollToTopOld(GlobalKey key) {
    _scrollToSection(key);
  }
  
  void _showLogoZoom() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black87,
        child: Stack(
          children: [
            PhotoView(
              imageProvider: const AssetImage('assets/images/chagres_initiative_logo_hq.png'),
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
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28,
                  ),
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
                if (!isMobile) SizedBox(height: 100), // Space for fixed header
                HeroSection(language: widget.language),
                PartnershipsSection(key: _partnershipsKey, language: widget.language),
                TeamSection(key: _teamKey, language: widget.language),
                AboutSection(key: _aboutKey, language: widget.language),
                _WhyDonationsSection(language: widget.language),
                MapsSection(language: widget.language),
                MeaningfulSection(language: widget.language),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Image.asset(
                      'assets/images/labonga_seal.png',
                      width: 156,
                      height: 156,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                AuthorizationSection(language: widget.language),
                MethodologySection(key: _methodologyKey, language: widget.language),
                FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 60),
                    child: Column(
                      children: [
                        Image.asset('assets/images/community_meeting.jpg'),
                        const SizedBox(height: 10),
                        const Text(
                          'The Indigenous Council Meeting of La Bonga as they listen to our team present about PRM.',
                          style: TextStyle(
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
                GallerySection(language: widget.language),
                ReportsSection(key: _reportsKey, language: widget.language),
                FAQSection(key: _faqKey, language: widget.language),
                GivingLevelsSection(key: _givingLevelsKey, language: widget.language),
                NewsletterSection(language: widget.language),
                ContactUsSection(language: widget.language),
                FooterSection(
                  language: widget.language,
                  onLanguageChanged: widget.onLanguageChanged,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              ],
            ),
          ),
          if (!isMobile)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildDesktopHeader(),
            ),
          Positioned(
            right: 0,
            top: MediaQuery.of(context).size.height * 0.62,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => launchUrl(Uri.parse('https://geog.ku.edu/donate')),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFA0291E),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(-2, 2)),
                    ],
                  ),
                  child: const RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      'Donate Now',
                      style: TextStyle(
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
        ],
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
      title: GestureDetector(
        onTap: _showLogoZoom,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: _showJayhawk
                ? Image.asset(
                    'assets/images/jayhawk.png',
                    key: const ValueKey('jayhawk'),
                    height: 48,
                    fit: BoxFit.contain,
                  )
                : Image.asset(
                    'assets/images/chagres_initiative_logo_hq.png',
                    key: const ValueKey('logo'),
                    height: 48,
                    fit: BoxFit.contain,
                  ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFF0C1328),
      elevation: 1,
      centerTitle: true,
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0C1328),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF0051BA),
            ),
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
            _reportsKey,
          ),
          _buildDrawerItem(
            widget.language == 'en' ? 'Collaborators' : 'Colaboradores',
            _partnershipsKey,
          ),
          _buildDrawerItem(
            widget.language == 'en' ? 'Support' : 'Apoyo',
            _givingLevelsKey,
          ),
          _buildDrawerItem(
            widget.language == 'en' ? 'Team' : 'Equipo',
            _teamKey,
            alignment: 0.20,
          ),
          _buildDrawerItem(
            widget.language == 'en' ? 'FAQ' : 'Preguntas Frecuentes',
            _faqKey,
          ),
          const Divider(color: Color(0xFF101A2F)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0051BA),
                ),
                onPressed: () => widget.onLanguageChanged(
                  widget.language == 'en' ? 'es' : 'en',
                ),
                child: Text(
                  widget.language == 'en' ? 'Español' : 'English',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'serif',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    String label,
    GlobalKey key, {
    double alignment = 0.50,
  }) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFB9C6EA),
          fontSize: 16,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop(); // Close drawer
        _scrollToSection(key, alignment: alignment);
      },
    );
  }

  Widget _buildDesktopHeader() {
    return Container(
      color: const Color(0xFF0C1328),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          GestureDetector(
            onTap: _showLogoZoom,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: _showJayhawk
                    ? Image.asset(
                        'assets/images/jayhawk.png',
                        key: const ValueKey('jayhawk'),
                        height: 80,
                        fit: BoxFit.contain,
                      )
                    : Image.asset(
                        'assets/images/chagres_initiative_logo_hq.png',
                        key: const ValueKey('logo'),
                        height: 80,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 40),
          // Navigation Links
          Wrap(
            spacing: 16,
            children: [
              _buildNavLink('About', _aboutKey),
              _buildNavLink('Methodology', _methodologyKey),
              _buildNavLink('Fieldwork', _reportsKey),
              _buildNavLink('Collaborators', _partnershipsKey),
              _buildNavLink('Support', _givingLevelsKey),
              _buildNavLink('Team', _teamKey, alignment: 0.20),
              _buildNavLink('FAQ', _faqKey),
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
                    widget.language == 'en' ? 'ES' : 'EN',
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String label, GlobalKey key, {double alignment = 0.50}) {
    final isActive = _activeSection == label;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _scrollToSection(key, alignment: alignment),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFFB9C6EA),
            fontSize: 17,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Hero Section - Logo centered on palms
class HeroSection extends StatelessWidget {
  final String language;

  const HeroSection({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
        // Logo — centered vertically (slightly above center) and horizontally
        Positioned(
          left: 0,
          right: 0,
          top: screenHeight * 0.18,
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: isMobile ? 340 : 700),
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 0),
              child: Image.asset(
                'assets/images/chagres_initiative_logo_hq.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        // Three phrases at centers of each third of the screen width
        if (!isMobile) ...[
          Positioned(
            left: screenWidth / 6,
            bottom: screenHeight * 0.12,
            child: Transform.translate(
              offset: const Offset(-50, 0),
              child: _buildPhrase(context, 'Water Security'),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: screenHeight * 0.12,
            child: Center(child: _buildPhrase(context, 'Rainforest Conservation')),
          ),
          Positioned(
            right: screenWidth / 6,
            bottom: screenHeight * 0.12,
            child: Transform.translate(
              offset: const Offset(50, 0),
              child: _buildPhrase(context, 'Indigenous Communities'),
            ),
          ),
        ] else
          Positioned(
            left: 0,
            right: 0,
            bottom: screenHeight * 0.22,
            child: Column(
              children: [
                _buildPhrase(context, 'Water Security'),
                const SizedBox(height: 10),
                _buildPhrase(context, 'Rainforest Conservation'),
                const SizedBox(height: 10),
                _buildPhrase(context, 'Indigenous Communities'),
              ],
            ),
          ),
        // Gradient fade at bottom blending into next section
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 120,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF070C18),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhrase(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.cinzel(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
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
        // La Bonga Vista is 4032x3024 (4:3)
        final vistaHeight = constraints.maxWidth * 3024 / 4032;
        final vistaTop = lanchaTop + lanchaHeight;

        return Stack(
      children: [
        // Dark background for content that overflows past image
        Container(width: double.infinity, color: const Color(0xFF0C1328)),
        // Background photos: hidden on phones, shown on tablets/desktop
        if (!isPhone) Positioned(
          top: 0, left: 0, right: 0,
          height: imageHeight,
          child: ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.75, 1.0],
              colors: [Colors.white, Colors.white, Colors.transparent],
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
        if (!isPhone) Positioned(
          top: lanchaTop, left: 0, right: 0,
          height: lanchaHeight,
          child: ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.15, 0.85, 1.0],
              colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
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
        if (!isPhone) Positioned(
          top: vistaTop, left: 0, right: 0,
          height: vistaHeight,
          child: ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.15, 0.85, 1.0],
              colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
            ).createShader(rect),
            blendMode: BlendMode.dstIn,
            child: Image.asset(
              'assets/images/la_bonga_vista.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
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
          Text(
            language == 'en' ? 'Collaborators' : 'Colaboradores',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          // Prominent donation appeal text
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF101A2F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF0051BA).withOpacity(0.4), width: 1.5),
            ),
            child: Text(
              language == 'en'
                  ? 'Your tax-deductible donations will contribute to our understanding and management of a geopolitical issue of USA and global importance: Water Security of the Panama Canal.\n\nFollow online and witness the research unfold on our website. You will see how your donations directly impact every aspect of the research which includes the support of Indigenous villagers and university researchers.'
                  : 'Sus donaciones deducibles de impuestos contribuirán a nuestra comprensión y gestión de un asunto geopolítico de importancia para EE.UU. y el mundo: la Seguridad Hídrica del Canal de Panamá.\n\nSíganos en línea y sea testigo del desarrollo de la investigación en nuestro sitio web. Verá cómo sus donaciones impactan directamente cada aspecto de la investigación, lo que incluye el apoyo a los aldeanos indígenas y a los investigadores universitarios.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          // Hero Strip Image
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFF81C784).withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF81C784),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF81C784).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 2),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/here_strip.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          // Spacer to push Make Dreams below the boat photo's bottom blur
          SizedBox(height: (imageHeight - 580).clamp(60.0, 800.0)),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: dart_ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
            constraints: const BoxConstraints(maxWidth: 720),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF1A4080).withOpacity(0.22),
              border: Border.all(
                color: const Color(0xFF4A90D9).withOpacity(0.28),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D2550).withOpacity(0.45),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  language == 'en'
                      ? 'Make Dreams Possible – Fund KU Research Abroad'
                      : 'Haga posibles los sueños – Financie la Investigación de KU en el Exterior',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(color: Color(0xFFB9C6EA), fontSize: 17, height: 1.7),
                    children: _buildCISpans(
                      language == 'en'
                          ? 'Your tax-deductible gift funds all Chagres Initiative activities directly including: all expenses connected to workshops and field research in Panama, as well as the activities of computer mapping and analysis at U.S. universities. No overhead, administrative fees or salaries are paid with your donation.\n\nWith U.S. Federal, NGO and now even internal university funding for international research being drastically cut, we present a novel alternative: a direct public-private research partnership.\n\nWe estimate to produce a geospatial analysis and zoning plan of the Chagres National Park will take about two years and U.S. \$150,000 to complete.\n\nSimply put, your donations make the Chagres Initiative possible, paying direct project costs of community members, KU students, and professors on the research team, paying for flights to Panama, boat and truck transportation, workshop costs, field equipment, mapping materials, and stipends to cover their food, lodging, and travel.'
                          : 'Su donación deducible de impuestos financia directamente todas las actividades de la Iniciativa Chagres, incluyendo: todos los gastos relacionados con talleres e investigación de campo en Panamá, así como las actividades de mapeo computarizado y análisis en universidades de EE.UU. Con su donación no se pagan gastos generales, honorarios administrativos ni salarios.\n\nCon los fondos federales de EE.UU., las ONG e incluso la financiación universitaria interna para la investigación internacional siendo drásticamente recortados, presentamos una alternativa novedosa: una asociación directa de investigación público-privada.\n\nEstimamos que producir un análisis geoespacial y un plan de zonificación del Parque Nacional Chagres tomará aproximadamente dos años y U.S. \$150,000 para completar.\n\nEn pocas palabras, sus donaciones hacen posible la Iniciativa Chagres, pagando los costos directos del proyecto de los miembros de la comunidad, estudiantes y profesores de KU en el equipo de investigación, pagando vuelos a Panamá, transporte en barco y camión, costos de talleres, equipos de campo, materiales de mapeo y estipendios para cubrir su alimentación, alojamiento y viaje.',
                      const TextStyle(color: Color(0xFFB9C6EA), fontSize: 17, height: 1.7),
                    ),
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
            ),
          ),
          const SizedBox(height: 40),
          // Poem Image — below boat photo seam
          Image.asset(
            'assets/images/poem.png',
            width: isMobile ? 280 : 360,
            fit: BoxFit.contain,
            opacity: const AlwaysStoppedAnimation(0.95),
          ),
          const SizedBox(height: 32),
          // Donation button — after Make Dreams section
          GestureDetector(
            onTap: () {
              launchUrl(Uri.parse('https://geog.ku.edu/donate'));
            },
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
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              child: Column(
                children: [
                  language == 'en'
                    ? Text.rich(
                        TextSpan(
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                          children: [
                            const TextSpan(text: 'Please '),
                            const TextSpan(text: 'Click', style: TextStyle(fontStyle: FontStyle.italic)),
                            const TextSpan(text: ' to '),
                            const TextSpan(text: 'Contribute', style: TextStyle(fontStyle: FontStyle.italic)),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      )
                    : const Text(
                        'Haga clic aquí para contribuir',
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                ],
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

// About Section
class AboutSection extends StatelessWidget {
  final String language;

  const AboutSection({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final isPhone = screenWidth < 600;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Natural image height at full width (1600×1066)
        final imageHeight = constraints.maxWidth * 1066.0 / 1600.0;
        // Content sits in the top 1/3 of the photo
        final topPadding = imageHeight * 0.05;

        // Shared text content widget
        final textContent = Column(
          children: [
            GestureDetector(
              onTap: () {},
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text(
                  language == 'en' ? 'About the Initiative' : 'Sobre la Iniciativa',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF101A2F).withOpacity(isPhone ? 1.0 : 0.82),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 34,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(36),
              child: Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFB9C6EA),
                    fontSize: 17,
                    height: 1.75,
                  ),
                  children: _buildCISpans(
                    language == 'en'
                        ? 'The Chagres Initiative responds to a legal request from an Indigenous Congress in Panama to help them map and conserve their lands inside the Chagres National Park (CNP), which supplies 40 percent of the freshwater used by Panama Canal operations and drinking water for 1.5 million people in Panama City.\n\nOur KU research team was invited by Indigenous leaders to help them map their land use inside the park. We use participatory research mapping (PRM) methodology that combines Indigenous geospatial knowledge (IGK) with GPS, air photography, and satellite imagery. Importantly, we train villagers as "community geographers" who learn field research skills and work alongside university researchers to produce accurate maps for conservation and development planning. Through this collaboration, the community gains the mapping tools they need for land protection, and together we produce scientifically rigorous data grounded in Indigenous knowledge and local experience.'
                        : 'La Iniciativa Chagres responde a una solicitud legal de un Congreso Indígena en Panamá para ayudarles a mapear y conservar sus tierras dentro del Parque Nacional Chagres (PNC), que suministra el 40 por ciento del agua dulce utilizada por las operaciones del Canal de Panamá y agua potable para 1,5 millones de personas en la Ciudad de Panamá.\n\nNuestro equipo de investigación de KU fue invitado por líderes indígenas para ayudarles a mapear el uso de su tierra dentro del parque. Utilizamos la metodología de mapeo participativo de investigación (PRM) que combina el conocimiento geoespacial indígena (CGI) con GPS, fotografía aérea e imágenes satelitales. Además, entrenamos a los aldeanos como "geógrafos comunitarios" que aprenden habilidades de investigación de campo y trabajan junto a investigadores universitarios para producir mapas precisos para la planificación de conservación y desarrollo. A través de esta colaboración, la comunidad obtiene las herramientas de mapeo que necesita para la protección de tierras, y juntos producimos datos científicamente rigurosos fundamentados en el conocimiento indígena y la experiencia local.',
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFB9C6EA),
                      fontSize: 17,
                      height: 1.75,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

        // Phone: no background photo, just padded text
        if (isPhone) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: textContent,
          );
        }

        // Tablet/desktop: full photo with overlaid text
        return Stack(
          children: [
            // Full ship photo, natural size, soft edges
            ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.08, 0.92, 1.0],
                colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/images/container_ship_gatun.jpg',
                width: double.infinity,
                fit: BoxFit.fitWidth,
                filterQuality: FilterQuality.high,
                color: const Color(0xFF0C1328).withOpacity(0.50),
                colorBlendMode: BlendMode.srcOver,
              ),
            ),
            // Text overlaid in the top portion of the photo
            Positioned(
              top: topPadding,
              left: isMobile ? 20 : 60,
              right: isMobile ? 20 : 60,
              child: textContent,
            ),
          ],
        );
      },
    );
  }
}

// Why Donations Section
class _WhyDonationsSection extends StatelessWidget {
  final String language;
  const _WhyDonationsSection({required this.language});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF101A2F),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.40),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              language == 'en' ? 'Why are Donations Necessary?' : '¿Por qué son necesarias las donaciones?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              language == 'en'
                  ? 'Simply put, as a novel private-public research funding alternative, your support makes the Chagres Initiative possible.\n\nFederal and NGO funding sources for international research on conservation, development, and non-traditional security (NTS) threats—like "Panama Canal Water Security"—are being cut from Trump Administration budgets. Therefore, we propose a public-private crowdsourcing approach allowing tax-deductible contributions.\n\nWe are launching fundraising to begin the project this Summer 2026 estimating three years and \$150,000 goal. Donations (through KU Endowment) cover direct project costs only.\n\nYour donations pay direct project costs to map and zone CNP lands for development, conservation, and watershed governance. The timeline reflects multiple field research periods and lab-based analysis. PRM requires sustained collaboration, repeated visits, and training. Donations cover travel, transportation, workshops, honoraria, field equipment, and mapping materials.\n\nWe aim to connect you, the donors, with meaningful geographic research, linking those concerned with environmental stewardship, Indigenous knowledge, and Panama Canal water security with those conducting the research.'
                  : 'En pocas palabras, como una alternativa novedosa de financiamiento de investigación privado-pública, su apoyo hace posible la Iniciativa Chagres.\n\nLas fuentes de financiamiento federales y de ONG para investigación internacional sobre conservación, desarrollo y amenazas a la seguridad no tradicional (SNT), como la "Seguridad Hídrica del Canal de Panamá", están siendo recortadas por los presupuestos de la Administración Trump. Por lo tanto, proponemos un enfoque de financiamiento colectivo público-privado que permite contribuciones deducibles de impuestos.\n\nEstamos lanzando una campaña de recaudación de fondos para iniciar el proyecto este verano de 2026, estimando tres años y una meta de \$150,000. Las donaciones (a través de KU Endowment) cubren solo los costos directos del proyecto.\n\nSus donaciones pagan los costos directos del proyecto para mapear y zonificar las tierras del PNC para el desarrollo, la conservación y la gobernanza de cuencas hidrográficas. El cronograma refleja múltiples períodos de investigación de campo y análisis de laboratorio. PRM requiere colaboración sostenida, visitas repetidas y capacitación. Las donaciones cubren viajes, transporte, talleres, honorarios, equipos de campo y materiales de mapeo.\n\nNuestro objetivo es conectarle a usted, los donantes, con investigaciones geográficas significativas, vinculando a quienes se preocupan por la gestión ambiental, el conocimiento indígena y la seguridad hídrica del Canal de Panamá con quienes llevan a cabo la investigación.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFB9C6EA),
                fontSize: 18,
                height: 1.75,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Meaningful Section
class MeaningfulSection extends StatefulWidget {
  final String language;

  const MeaningfulSection({super.key, required this.language});

  @override
  State<MeaningfulSection> createState() => _MeaningfulSectionState();
}

class _MeaningfulSectionState extends State<MeaningfulSection> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    
    final principles = [
      (
        widget.language == 'en' ? '1. Authorized by Indigenous Congress' : '1. Autorizado por el Congreso Indígena',
        widget.language == 'en'
            ? 'This project is grounded in decades of trust and expertise built by KU geography professors and students doing participatory research mapping (PRM) projects in Panama and Central America. At their governing Congreso Local in June 2025, Indigenous Emberá and Wounaan leaders from Chagres National Park (CNP) recognized our "KU know-how" from previous mapping projects with their relatives. The congreso then voted unanimously to invite us to map their lands and help them develop a management plan acceptable to the Panamanian government.'
            : 'Este proyecto se basa en décadas de confianza y experiencia construida por profesores y estudiantes de geografía de KU realizando proyectos de mapeo participativo de investigación (PRM) en Panamá y Centroamérica. En su Congreso Local en junio de 2025, los líderes indígenas Emberá y Wounaan del Parque Nacional Chagres (PNC) reconocieron nuestro "know-how de KU" de proyectos de mapeo anteriores con sus parientes. El congreso luego votó unánimemente para invitarnos a mapear sus tierras y ayudarles a desarrollar un plan de manejo aceptable para el gobierno panameño.',
      ),
      (
        widget.language == 'en' ? '2. "Living Research" in Indigenous Rainforest Communities of the Panama Canal Watershed' : '2. "Investigación Viva" en Comunidades Indígenas de la Selva Tropical de la Cuenca del Canal de Panamá',
        widget.language == 'en'
            ? 'Rather than confining findings to academic journals or static reports, this initiative maintains a transparent and evolving public platform and collaborates directly with government agencies.'
            : 'En lugar de confinar los hallazgos a revistas académicas o informes estáticos, esta iniciativa mantiene una plataforma pública transparente y en evolución y colabora directamente con agencias gubernamentales.',
      ),
      (
        widget.language == 'en' ? '3. Training Community Geographers as Co-Producers of Scientific Results' : '3. Formación de Geógrafos Comunitarios como Co-Productores de Resultados Científicos',
        widget.language == 'en'
            ? 'Unlike other projects, our results create community resources of sustained value: we formally certify community representatives as geographers who receive training, and do hands-on fieldwork, learn and use GPS, basic cartography, heads-up imagery analysis, and other geographic methods, including drone use for forest management. These "community geographers" — perhaps not surprisingly — are empowered as ideal co-producers and co-authors of project maps and data. All publication authorships are shared among team members and final cartographic information remain under the ownership of the local communities.'
            : 'A diferencia de otros proyectos, nuestros resultados crean recursos comunitarios de valor sostenido: certificamos formalmente a representantes comunitarios como geógrafos que reciben formación y realizan trabajo de campo práctico, aprenden y utilizan GPS, cartografía básica, análisis de imágenes aéreas y otros métodos geográficos, incluyendo el uso de drones para la gestión forestal. Estos "geógrafos comunitarios" — quizás no sorprendentemente — están empoderados como co-productores y co-autores ideales de mapas y datos del proyecto. Todas las autorías de publicaciones se comparten entre los miembros del equipo y la información cartográfica final permanece bajo la propiedad de las comunidades locales.',
      ),
    ];
    
    return Container(
      color: const Color(0xFF0C1328),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 60,
      ),
      child: Column(
        children: [
          Text(
            widget.language == 'en'
                ? 'What Makes This Project Uniquely Meaningful?'
                : '¿Qué hace que este proyecto sea único?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: principles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 0),
              itemBuilder: (context, index) {
                final principle = principles[index];
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
                    data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(
                        principle.$1,
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Text(
                            principle.$2,
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
    );
  }
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
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
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
                      : 'Durante nuestra expedición exploratoria a la comunidad indígena Emberá/Wounaan de La Bonga Pequení en la Cuenca del Canal de Panamá el verano pasado de 2025, los líderes comunitarios nos invitaron a regresar y presentar nuestra metodología de investigación participativa (PRM) a su congreso rector porque entendieron el potencial del proyecto.\n\nEn su Congreso Local en junio de 2025, los líderes indígenas Emberá y Wounaan de comunidades dentro del Parque Nacional Chagres (PNC) reconocieron el "know-how de KU" de proyectos de mapeo exitosos anteriores con sus parientes en la provincia oriental del Darién ¡en la década de 1990! El Congreso Local votó unánimemente para pedir a nuestro equipo de geógrafos de KU que mapearan sus tierras y les ayudaran a desarrollar un plan de manejo aceptable para el gobierno panameño.',
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
                      viewType: widget.language == 'en' ? _pdfViewerEnId : _pdfViewerEsId,
                    ),
                  ),
                ]
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
            ('Stage One: Co-design', 'Define mapping goals with community leadership.'),
            ('Stage Two: Training', 'Through instructional exercises, "community geographers" learn the use of GPS, mapping tools, and data-documentation techniques.'),
            ('Stage Three: Field Verification and Mapping', 'Trained community geographers collect ground-truth points and data through shared site visits to do sketch mapping and questionnaire applications in communities.'),
            ('Stage Four: Plot Field Data onto Cartographic Sheets', 'Plot field data onto standard cartographic sheets in community workshops. Designing Indigenous Land-use Management and zoning in workshops.'),
            ('Stage Five: GIS and Computer Map Production', 'KU students with professors digitize and standardize outputs for planning and governance use.'),
          ]
        : [
            ('Etapa Uno: Codiseño', 'Definir objetivos de mapeo con el liderazgo comunitario.'),
            ('Etapa Dos: Capacitación', 'A través de ejercicios de instrucción, los "geógrafos comunitarios" aprenden el uso de GPS, herramientas de mapeo y técnicas de documentación de datos.'),
            ('Etapa Tres: Verificación de Campo y Mapeo', 'Los geógrafos comunitarios capacitados recopilan puntos de verificación terrestre y datos a través de visitas compartidas al sitio para hacer mapas esquemáticos y aplicaciones de cuestionarios en las comunidades.'),
            ('Etapa Cuatro: Trazar Datos de Campo en Hojas Cartográficas', 'Trazar datos de campo en hojas cartográficas estándar en talleres comunitarios. Diseño de la Gestión del Uso de Tierras Indígenas y zonificación en talleres.'),
            ('Etapa Cinco: Producción de Mapas SIG y Computarizados', 'Estudiantes de KU con profesores digitalizan y estandarizan los resultados para uso de planificación y gobernanza.'),
          ];

    final inner = Container(
      color: const Color(0xFF0C1328),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 60,
      ),
      child: Column(
        children: [
          Text(
            widget.language == 'en'
                ? 'Stages of Participatory Research Mapping (PRM)'
                : 'Etapas del Mapeo de Investigación Participativa',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Text(
              widget.language == 'en'
                  ? 'Unlike most research, PRM releases the research function to trained "community geographers" who co-design and implement the project as they interpret geo-spatial information alongside KU geographers and students.'
                  : 'A diferencia de la mayoría de las investigaciones, el PRM delega la función de investigación a "geógrafos comunitarios" capacitados que co-diseñan e implementan el proyecto mientras interpretan información geoespacial junto a geógrafos y estudiantes de KU.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFB9C6EA),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 0),
              itemBuilder: (context, index) {
                final stage = stages[index];
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
                    data: Theme.of(context).copyWith(splashColor: Colors.transparent),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    return inner;
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
    ('Community leadership engagement', 'Participación del liderazgo comunitario'),
    ('Site analysis at Panamanian Geographic Institute', 'Análisis del sitio en el Instituto Geográfico de Panamá'),
    ('Rainforest lizard', 'Lagarto de la selva tropical'),
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
                widget.language == 'en' ? 'Fieldwork & Landscape' : 'Trabajo de Campo y Paisaje',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 24),
              child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 800),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        widget.language == 'en'
                            ? _captions[_currentIndex % _captions.length].$1
                            : _captions[_currentIndex % _captions.length].$2,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFB9C6EA),
                            ),
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
      'Formal signing of Indigenous Local Congress inviting KU geographers to do participatory mapping of their communities in the Chagres National Park to develop a conservation zoning plan. Photo shows Emberá Chief Marcelino Guático and Community President Elieser Adames signing the legal request (pedido) formalizing the KU Chagres Initiative (Taylor Tappan and Cap McLiney are also shown).',
      'Firma formal del Congreso Local Indígena invitando a los geógrafos de KU a realizar el mapeo participativo de sus comunidades en el Parque Nacional Chagres para desarrollar un plan de zonificación de conservación. La foto muestra al Jefe Emberá Marcelino Guático y al Presidente Comunitario Elieser Adames firmando la solicitud legal (pedido) que formaliza la Iniciativa Chagres de KU (Taylor Tappan y Cap McLiney también aparecen en la foto).',
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
                    widget.language == 'en' ? _captions[idx].$1 : _captions[idx].$2,
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
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
                  launchUrl(Uri.parse(
                    'https://www.google.com/maps/place/San+Juan+de+Pequní+Indígena+(+La+Bonga)/@9.3827301,-79.5241626,17z/data=!3m1!4b1!4m6!3m5!1s0x8fab494a734c2493:0xe55e405b5412d0dc!8m2!3d9.3827301!4d-79.5215877!16s%2Fg%2F11mtjt0g7z?entry=ttu',
                  ));
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
                final displayWidth = math.min(constraints.maxWidth, displayHeight * imageAspectRatio);
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
              final colWidth = (constraints.maxWidth - gap - cardPadding * 2) / 2;
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
    return const HtmlElementView(
      viewType: 'google-maps-embed',
    );
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
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.language == 'en'
                ? 'Explore our gallery of Substack posts and field reflections. Official research reports will be available as PDFs here.'
                : 'Explora nuestra galería de posts de Substack y reflexiones de campo. Los informes de investigación oficiales estarán disponibles como PDF aquí.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFB9C6EA),
            ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedTab == 0 ? const Color(0xFF0051BA) : const Color(0xFF101A2F),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedTab == 1 ? const Color(0xFF0051BA) : const Color(0xFF101A2F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.language == 'en' ? 'Official Reports' : 'Informes Oficiales',
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
                  : 'Actualizaciones narrativas del campo, talleres de mapeo participativo y actividades de compromiso de cuencas hidrográficas.',
            )
          else
            _buildReportCard(
              context,
              widget.language == 'en' ? 'Official Reports' : 'Informes Oficiales',
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
            ('Why does the health of Chagres National Park matter for people in the United States?', 'Chagres National Park provides approximately 40 percent of the freshwater used by Panama Canal operations and drinking water for 1.5 million people in Panama City. The Canal remains one of the most strategically important global trade corridors, moving a significant portion of U.S.-bound maritime commerce.\n\nRecent droughts have demonstrated that water scarcity is one of the canal\'s greatest operational threats. Long-term watershed health directly affects trade reliability, regional diplomatic stability, and economic security.'),
            ('Who and what legal authority authorizes this project?', 'This initiative proceeds only with community consent and institutional coordination. During a reconnaissance expedition in Summer 2025, the research team met with the Indigenous community of San Juan Pequeñí, participated in a formal Local Congress, and received written approval.\n\nThis authorization aligns with Panama\'s 2008 Law 72 governing Collective Indigenous Lands. The project continues only through collaborative agreement with community leadership.'),
            ('How does "mapping" help protect an area like this?', 'National park boundaries alone do not ensure forest protection or water security. Effective stewardship requires understanding the ecological and social processes occurring within those boundaries.\n\nParticipatory research mapping translates Indigenous geographic knowledge into structured formats that can support zoning, monitoring, and long-term governance planning. At a fundamental level, it is difficult to protect what is not clearly understood.'),
            ('How are community members involved and compensated?', 'Community representatives are trained and certified as local geographers in GPS data collection and mapping techniques. Participants are compensated for their time and expertise.'),
            ('How long will the project take?', 'We estimate the Chagres Initiative will have 3 overlapping phases requiring about three years in total to complete depending on funding availability:\n\nYear 1-2: Participatory research mapping and geospatial database development.\nYear 1-2: Consensus-driven zoning and development of community land-use guidelines.\nYear 2-3: Final map production, synthesis, and integration into management planning frameworks.\n\nThe participatory research mapping approach is iterative, with alternating workshops and field research in Panama followed by GIS and computer mapping analyzes at the universities to obtain the most precise cartographic and spatial data on resource use in the Chagres National Park for developing an Indigenous and state approved management plan for land use in the park.'),
            ('How will donated funds be used?', 'Your support funds all field-based research and community collaboration. Included are the workshops, equipment (GPS, drones, Starlink), and expenses of local geographers, researchers and students.'),
            ('Is this project political?', 'The project is non-partisan and research-driven. Its focus is watershed stewardship, participatory governance, and environmental monitoring.'),
            ('Will the data be publicly available?', 'Final authorship will be shared by team members, community and governmental participants. Sensitive knowledge remains under community control.'),
            ('Can this model be replicated elsewhere?', 'Yes. This is a new framework for community-based research with a novel public-private funding formula combined with 21st century geospatial and A.I. innovations designed to engage the public ranging from Indigenous villages to metropolitan centers. We hope to connect people of all backgrounds and educations with our research.\n\nWe hope to channel the power of tax-deductible donations and connect the people and institutions that make them with the on-the-ground and in-the-university realities of fieldwork on a strategic, geopolitical issue of global importance: Water Security of the Panama Canal.'),
            ('Hasn\'t the whole world been mapped already?', 'No. There is a difference between remote imagery of an area from satellites and the kinds of maps we are making. The level of detail combining physical geography with cultural-historical information in the community is unique and critical to our process.'),
          ]
        : [
            ('¿Por qué importa la salud del Parque Nacional Chagres?', 'El Parque Nacional Chagres proporciona aproximadamente el 40 por ciento del agua dulce utilizada en las operaciones del Canal de Panamá y agua potable para 1,5 millones de personas en la Ciudad de Panamá. El Canal sigue siendo uno de los corredores comerciales globales más estratégicamente importantes.\n\nLas sequías recientes han demostrado que la escasez de agua es una de las mayores amenazas operativas del Canal. La salud de la cuenca a largo plazo afecta directamente la confiabilidad del comercio, la estabilidad diplomática regional y la seguridad económica.'),
            ('¿Quién autoriza este proyecto?', 'Esta iniciativa procede solo con consentimiento comunitario y coordinación institucional. Durante una expedición de reconocimiento en verano de 2025, el equipo de investigación se reunió con la comunidad indígena de San Juan Pequeñí, participó en un Congreso Local formal y recibió aprobación escrita.\n\nEsta autorización se alinea con la Ley 72 de 2008 de Panamá que rige las Tierras Colectivas Indígenas. El proyecto continúa solo a través de acuerdo colaborativo con el liderazgo comunitario.'),
            ('¿Cómo ayuda el mapeo a proteger un área?', 'Los límites del parque nacional por sí solos no garantizan la protección forestal ni la seguridad hídrica. El manejo efectivo requiere comprender los procesos ecológicos y sociales que ocurren dentro de esos límites.\n\nEl mapeo participativo de investigación traduce el conocimiento geográfico indígena a formatos estructurados que pueden apoyar la zonificación, el monitoreo y la planificación de gobernanza a largo plazo. En un nivel fundamental, es difícil proteger lo que no se entiende claramente.'),
            ('¿Cómo se compensan a los miembros de la comunidad?', 'Los representantes comunitarios son capacitados y certificados como geógrafos locales en recopilación de datos GPS y técnicas de mapeo. Los participantes reciben compensación por su tiempo y experiencia.'),
            ('¿Cuánto tiempo tomará el proyecto?', 'Estimamos que la Iniciativa Chagres tendrá 3 fases superpuestas que requerirán aproximadamente tres años en total para completarse dependiendo de la disponibilidad de fondos:\n\nAño 1-2: Mapeo participativo de investigación y desarrollo de base de datos geoespacial.\nAño 1-2: Zonificación impulsada por consenso y desarrollo de directrices de uso del suelo comunitario.\nAño 2-3: Producción final del mapa, síntesis e integración en marcos de planificación de manejo.\n\nEl enfoque de mapeo participativo de investigación es iterativo, con talleres e investigación de campo alternados en Panamá seguidos de análisis de SIG y mapeo computarizado en las universidades para obtener los datos cartográficos y espaciales más precisos sobre el uso de recursos en el Parque Nacional Chagres para desarrollar un plan de manejo de uso del suelo aprobado por las comunidades indígenas y el estado.'),
            ('¿Cómo se usarán los fondos donados?', 'Su apoyo financia toda la investigación de campo y la colaboración comunitaria. Se incluyen los talleres, equipos (GPS, drones, Starlink) y los gastos de geógrafos locales, investigadores y estudiantes.'),
            ('¿Es este proyecto político?', 'El proyecto es apartidista e impulsado por la investigación. Su enfoque es el manejo de cuencas hidrográficas, gobernanza participativa y monitoreo ambiental.'),
            ('¿Estarán los datos disponibles públicamente?', 'La autoría final será compartida por los miembros del equipo, participantes comunitarios y gubernamentales. El conocimiento sensible permanece bajo control comunitario.'),
            ('¿Se puede replicar este modelo en otros lugares?', 'Sí. Este es un nuevo marco para la investigación comunitaria con una fórmula de financiación público-privada novedosa combinada con innovaciones geoespaciales y de I.A. del siglo XXI diseñadas para involucrar al público desde aldeas indígenas hasta centros metropolitanos. Esperamos conectar a personas de todos los orígenes y niveles de educación con nuestra investigación.\n\nEsperamos canalizar el poder de las donaciones deducibles de impuestos y conectar a las personas e instituciones que las realizan con las realidades sobre el terreno y en la universidad del trabajo de campo en un tema estratégico y geopolítico de importancia global: la Seguridad Hídrica del Canal de Panamá.'),
            ('¿No ha sido mapeado ya todo el mundo?', 'No. Hay una diferencia entre las imágenes satelitales de un área desde satélites y los tipos de mapas que estamos haciendo. El nivel de detalle que combina geografía física con información cultural-histórica en la comunidad es único y crítico para nuestro proceso.'),
          ];

    return Container(
      color: const Color(0xFF0C1328),
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
                language == 'en' ? 'Frequently Asked Questions' : 'Preguntas Frecuentes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
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
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        widget.language == 'en' ? 'Community Supporter' : 'Apoyo Comunitario',
        widget.language == 'en' ? '< \$100' : '< \$100',
        widget.language == 'en'
            ? 'Donors funding field essentials - first aid kits, Skynet link, dry bags, notebooks, river travel, batteries, tents, housing when working far from infrastructure.'
            : 'Donantes que financian elementos esenciales de campo: botiquines de primeros auxilios, enlace Skynet, bolsas secas, cuadernos, viajes por río, baterías, tiendas de campaña, alojamiento en infraestructura remota.',
      ),
      (
        widget.language == 'en' ? 'Action Supporter' : 'Apoyo de Acción',
        widget.language == 'en' ? '\$100 - \$250' : '\$100 - \$250',
        widget.language == 'en'
            ? 'Donors supporting in-country logistics - travel between Panama City and the field, transporting equipment, and coordinating with local partners and institutions. Pays for fuel and boat travel. There are no roads in - everything moves by river.'
            : 'Donantes que apoyan la logística en el país: viajes entre la Ciudad de Panamá y el campo, transporte de equipos y coordinación con socios locales e instituciones. Paga combustible y viajes en barco. No hay carreteras - todo se mueve por río.',
      ),
      (
        widget.language == 'en' ? 'Stewardship Supporter' : 'Apoyo de Administración',
        widget.language == 'en' ? '\$250 - \$1,000' : '\$250 - \$1,000',
        widget.language == 'en'
            ? 'International travel for university students and professors.'
            : 'Viajes internacionales para estudiantes y profesores universitarios.',
      ),
      (
        widget.language == 'en' ? 'Wisdom Supporter' : 'Apoyo de Sabiduría',
        widget.language == 'en' ? '\$1,000 - \$5,000' : '\$1,000 - \$5,000',
        widget.language == 'en'
            ? 'Workshops and participatory mapping session costs – renting locale, tables, chairs; meals and housing for participants, printing mapping materials.'
            : 'Costos de talleres y sesiones de mapeo participativo: alquiler de local, mesas, sillas; comidas y alojamiento para participantes, impresión de materiales de mapeo.',
      ),
      (
        widget.language == 'en' ? 'Visionary & Institutional' : 'Visionario e Institucional',
        widget.language == 'en' ? '> \$5,000' : '> \$5,000',
        widget.language == 'en'
            ? 'Stipends for community geographers, students, and faculty. No salaries are paid. Donor supports local costs of food, lodging, and transportation in Panama City and in the Chagres National Park.'
            : 'Estípendios para geógrafos comunitarios, estudiantes y profesores. No se pagan salarios. El donante financia costos locales de comida, alojamiento y transporte en la Ciudad de Panamá y en el Parque Nacional Chagres.',
      ),
    ];

    return Container(
      color: const Color(0xFF0C1328),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 60,
      ),
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
              children: _buildCISpans(
                widget.language == 'en' ? 'Support the Chagres Initiative' : 'Apoya la Iniciativa Chagres',
                Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                color: Color(0xFFB9C6EA),
                fontSize: 16,
              ),
              children: _buildCISpans(
                widget.language == 'en'
                    ? 'All donated funds are used in the Chagres Initiative Research Fund to be used exclusively for project activities.\n\nThe descriptions of each supporter category are just examples of how funds could be used.'
                    : 'Todos los fondos donados se utilizan en el Fondo de Investigación de la Iniciativa Chagres para ser utilizados exclusivamente para actividades del proyecto.\n\nLas descripciones de cada categoría de donante son solo ejemplos de cómo podrían utilizarse los fondos.',
                const TextStyle(
                  color: Color(0xFFB9C6EA),
                  fontSize: 16,
                ),
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
                  onTap: () {
                    launchUrl(Uri.parse('https://geog.ku.edu/donate'));
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFA0291E),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: const Color(0xFFA0291E),
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      child: widget.language == 'en'
                        ? Text.rich(
                            TextSpan(
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              children: [
                                const TextSpan(text: 'Please '),
                                const TextSpan(text: 'Click', style: TextStyle(fontStyle: FontStyle.italic)),
                                const TextSpan(text: ' to '),
                                const TextSpan(text: 'Contribute', style: TextStyle(fontStyle: FontStyle.italic)),
                              ],
                            ),
                          )
                        : const Text(
                            'Haga clic aquí para contribuir',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
                    separatorBuilder: (context, index) => const SizedBox(height: 0),
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
                          data: Theme.of(context).copyWith(splashColor: Colors.transparent),
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
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        if (!isPhone) Positioned.fill(
          child: Image.asset(
            'assets/images/la_bonga_vista.jpeg',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            color: const Color(0xFF0C1328).withOpacity(0.55),
            colorBlendMode: BlendMode.srcOver,
          ),
        ),
        Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 60,
      ),
      child: Column(
        children: [
          Text(
            language == 'en' ? 'Research Team' : 'Equipo de Investigación',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          // Team Photo Carousel
          _TeamPhotoCarousel(language: language),
          const SizedBox(height: 40),
          // La Bonga Section
          _buildTeamSection(
            context,
            language == 'en' ? 'La Bonga Personnel' : 'Personal de La Bonga',
            [
              ('Marcelino Guatico', 'Chief of La Bonga', 'Nokó de La Bonga', '', 'labonga_seal.png'),
              ('Elieser Adames', 'President of La Bonga', 'Presidente de La Bonga', '', 'labonga_seal.png'),
            ],
            language,
            isMobile,
          ),
          const SizedBox(height: 40),
          // University of Kansas Section
          _buildTeamSection(
            context,
            language == 'en' ? 'University of Kansas Personnel' : 'Personal de la Universidad de Kansas',
            [
              ('Dr. Peter Herlihy', 'Professor of Geography', 'Profesor de Geografía', 'herlihy@ku.edu', 'peter1.jpg'),
              ('Cap McLiney', 'PhD Student', 'Estudiante de Doctorado', 'cmclineyjr@ku.edu', 'cap.png'),
              ('Amalie Hipp', 'PhD Student', 'Estudiante de Doctorado', 'ahippe@ku.edu', 'Hipp_Headshot.jpg'),
              ('Ollie Berwanger', 'Undergraduate Researcher', 'Investigador de Pregrado', 'cash.berwanger@ku.edu', 'geog_logo.jpg'),
              ('Oliver Zigmund', 'Undergraduate Researcher', 'Investigador de Pregrado', 'oliverlzigmund@ku.edu', 'geog_logo.jpg'),
            ],
            language,
            isMobile,
          ),
          const SizedBox(height: 40),
          // UT Arlington Section
          _buildTeamSection(
            context,
            language == 'en' ? 'University of Texas at Arlington Personnel' : 'Personal de la Universidad de Texas en Arlington',
            [
              ('Dr. Taylor Tappan', 'Assistant Professor of Geography', 'Profesor Asistente de Geografía', 'taylor.tappan@uta.edu', 'taylor.jpg'),
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
                    width: isMobile ? ((MediaQuery.of(context).size.width - 40) / 2) - 5 : 150,
                    height: isMobile ? ((MediaQuery.of(context).size.width - 40) / 2) - 5 : 150,
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
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
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
            language == 'en' ? 'Contact Us' : 'Contáctanos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
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
                          : '¿Tienes preguntas sobre la Iniciativa Chagres? Nos encantaría escucharte.',
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
                            : 'Envíanos un correo a: chagresinitiative@ku.edu',
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB9C6EA),
              ),
              children: _buildCISpans(
                '© 2026 Chagres Initiative',
                Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFB9C6EA),
                ),
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
                    fontWeight: language == 'en' ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              const Text(
                ' | ',
                style: TextStyle(color: Color(0xFFB9C6EA)),
              ),
              GestureDetector(
                onTap: () => onLanguageChanged('es'),
                child: Text(
                  'Español',
                  style: TextStyle(
                    color: language == 'es'
                        ? Colors.white
                        : const Color(0xFFB9C6EA),
                    fontWeight: language == 'es' ? FontWeight.bold : FontWeight.normal,
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
              ),
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF81C784),
              ),
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
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
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
      builder: (context) => ZoomImageDialog(
        imagePath: widget.imagePath,
      ),
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
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28,
                  ),
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
