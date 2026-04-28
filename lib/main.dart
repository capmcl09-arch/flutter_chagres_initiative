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

const String _donationPageUrl =
    'https://launchku.org/campaigns/chagres-initiative-safeguarding-panama-canal-water-security-through-indigenous-rainforest-stewardship';

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
TextSpan _buildAboutDonationsSpans(String language) {
  const baseStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    height: 1.6,
    fontWeight: FontWeight.w500,
  );
  final ciStyle = baseStyle.copyWith(
    color: const Color(0xFF7FB069),
    fontWeight: FontWeight.w800,
    fontStyle: FontStyle.italic,
  );
  final lkuStyle = baseStyle.copyWith(
    color: const Color(0xFF5FB5FF),
    fontWeight: FontWeight.w800,
  );

  if (language == 'en') {
    return TextSpan(
      style: baseStyle,
      children: [
        const TextSpan(
          text:
              'Your tax-deductible donations will contribute to our understanding and management of a geopolitical issue of USA and global importance: Water Security of the Panama Canal.\n\nThe ',
        ),
        TextSpan(text: 'Chagres Initiative', style: ciStyle),
        const TextSpan(text: ' is a '),
        TextSpan(text: 'Launch KU', style: lkuStyle),
        const TextSpan(
          text:
              ' project. LaunchKU is the KU Endowment\'s crowdfunding platform, helping faculty and students raise funds for their work to benefit KU.\n\nFollow online and witness the research unfold on our website. You will see how your donations directly impact every aspect of the research which includes the support of Indigenous villagers and university researchers.',
        ),
      ],
    );
  }
  return TextSpan(
    style: baseStyle,
    children: [
      const TextSpan(
        text:
            'Sus donaciones deducibles de impuestos contribuirán a nuestra comprensión y gestión de un asunto geopolítico de importancia para EE.UU. y el mundo: la Seguridad Hídrica del Canal de Panamá.\n\nLa ',
      ),
      TextSpan(text: 'Iniciativa Chagres', style: ciStyle),
      const TextSpan(text: ' es un proyecto de '),
      TextSpan(text: 'Launch KU', style: lkuStyle),
      const TextSpan(
        text:
            '. LaunchKU es la plataforma de crowdfunding del KU Endowment, que ayuda a profesores y estudiantes a recaudar fondos para sus proyectos en beneficio de KU.\n\nSíganos en línea y sea testigo del desarrollo de la investigación en nuestro sitio web. Verá cómo sus donaciones impactan directamente cada aspecto de la investigación, lo que incluye el apoyo a los pobladores indígenas y a los investigadores universitarios.',
      ),
    ],
  );
}

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
    precacheImage(const AssetImage('assets/images/jayhawk.png'), context);
    precacheImage(const AssetImage('assets/images/ku_signature.png'), context);
    precacheImage(const AssetImage('assets/images/Launch_KU.png'), context);
    precacheImage(
      const AssetImage('assets/images/Spanish_PRM_Explain.png'),
      context,
    );
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

    // Track active section
    _updateActiveSection();
  }

  void _updateActiveSection() {
    final Map<GlobalKey, String> sections = {
      _partnershipsKey: 'About Donations',
      _teamKey: 'Team',
      _aboutKey: 'About',
      _methodologyKey: 'Methodology',
      _fieldworkKey: 'Fieldwork',
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

  void _scrollToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null || !_scrollController.hasClients) return;
    final box = ctx.findRenderObject();
    if (box is! RenderBox) return;
    final viewport = RenderAbstractViewport.of(box);
    final reveal = viewport.getOffsetToReveal(box, 0.0).offset;
    final isMobile = MediaQuery.of(this.context).size.width < 900;
    // Desktop has a 100px fixed header overlay; add a small gap so the title
    // clears the ribbon. Mobile uses a Scaffold AppBar so the body already
    // begins below it.
    final headerOffset = isMobile ? 0.0 : 124.0;
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
                HeroSection(
                  language: widget.language,
                  onLogoTap: _showLogoZoom,
                ),
                _WorkingDraftBanner(language: widget.language),
                RevealOnScroll(
                  child: AboutSection(
                    key: _aboutKey,
                    language: widget.language,
                  ),
                ),
                // Stats band (5 figures) lifted out of the green band so it
                // lands directly after About.
                Container(
                  width: double.infinity,
                  color: const Color(0xFF0C1328),
                  child: RevealOnScroll(
                    child: _SealWithStats(language: widget.language),
                  ),
                ),
                RevealOnScroll(
                  child: _WhyDonationsBand(
                    language: widget.language,
                    isMobile: isMobile,
                  ),
                ),
                RevealOnScroll(
                  child: MappingMethodSection(language: widget.language),
                ),
                RevealOnScroll(
                  child: SatellitePrmStorySection(language: widget.language),
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
                        child: MeaningfulSection(language: widget.language),
                      ),
                    ],
                  ),
                ),
                // Transition back to navy for Partnerships.
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
                            child: MapsSection(language: widget.language),
                          ),
                          RevealOnScroll(
                            child: AuthorizationSection(
                              language: widget.language,
                            ),
                          ),
                          RevealOnScroll(
                            child: MethodologySection(
                              key: _methodologyKey,
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
                          RevealOnScroll(
                            child: ReportsSection(
                              key: _reportsKey,
                              language: widget.language,
                            ),
                          ),
                          RevealOnScroll(
                            child: FAQSection(
                              key: _faqKey,
                              language: widget.language,
                            ),
                          ),
                          RevealOnScroll(
                            child: GivingLevelsSection(
                              key: _givingLevelsKey,
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
    final signatureHeight = isMobile ? 26.0 : 42.0;
    final launchHeight = isMobile ? 26.0 : 42.0;
    final gap = isMobile ? 10.0 : 14.0;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: _showJayhawk
          ? Row(
              key: const ValueKey('ku_launch_signature'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _showLogoZoom,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Image.asset(
                      'assets/images/ku_signature.png',
                      height: signatureHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(width: gap),
                GestureDetector(
                  onTap: _openDonationPage,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Image.asset(
                      'assets/images/Launch_KU.png',
                      height: launchHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            )
          : GestureDetector(
              key: const ValueKey('logo_with_jayhawk'),
              onTap: _showLogoZoom,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/chagres_initiative_logo_hq.png',
                      height: isMobile ? 48 : 80,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: isMobile ? 10 : 14),
                    Image.asset(
                      'assets/images/jayhawk.png',
                      height: isMobile ? 40 : 64,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
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
            widget.language == 'en'
                ? 'About Donations'
                : 'Acerca de las Donaciones',
            _partnershipsKey,
          ),
          _buildDrawerItem(
            widget.language == 'en' ? 'Support' : 'Apoyo',
            _givingLevelsKey,
          ),
          _buildDrawerItem(
            widget.language == 'en' ? 'Team' : 'Equipo',
            _teamKey,
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
                  style: const TextStyle(fontSize: 16, fontFamily: 'serif'),
                ),
              ),
            ),
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
      color: const Color(0xFF0C1328),
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
              _buildNavLink('About Donations', _partnershipsKey),
              _buildNavLink('Support', _givingLevelsKey),
              _buildNavLink('Team', _teamKey),
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
      'About Donations' => 'Acerca de las Donaciones',
      'Support' => 'Apoyo',
      'Team' => 'Equipo',
      'FAQ' => 'Preguntas Frecuentes',
      _ => label,
    };
  }
}

// Hero Section - Logo centered on palms
class HeroSection extends StatelessWidget {
  final String language;
  final VoidCallback? onLogoTap;

  const HeroSection({super.key, required this.language, this.onLogoTap});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final topInset = MediaQuery.paddingOf(context).top;
    final logoWidth = isMobile ? screenWidth * 0.92 : screenWidth * 0.68;
    final heroTopPadding = isMobile ? topInset + 56 : screenHeight * 0.09;

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
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onLogoTap,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: logoWidth,
                        maxHeight: isMobile
                            ? screenHeight * 0.34
                            : screenHeight * 0.44,
                      ),
                      child: Image.asset(
                        'assets/images/chagres_initiative_logo_hq.png',
                        fit: isMobile ? BoxFit.contain : BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 28),
                Column(
                  children: [
                    _buildPhrase(
                      context,
                      language == 'en' ? 'Water Security' : 'Seguridad Hídrica',
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
                          ? 'Indigenous Communities'
                          : 'Comunidades Indígenas',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Gradient fade at bottom blending into next section
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 160,
          child: IgnorePointer(
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
      ],
    );
  }

  Widget _buildPhrase(BuildContext context, String text) {
    return _HeroPhrasePill(text: text);
  }
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
                  Text(
                    language == 'en'
                        ? 'About Donations'
                        : 'Acerca de las Donaciones',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  // Prominent donation appeal text
                  Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101A2F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF0051BA).withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text.rich(
                          _buildAboutDonationsSpans(language),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
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
                      ],
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 28,
                        ),
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
                                style: const TextStyle(
                                  color: Color(0xFFB9C6EA),
                                  fontSize: 17,
                                  height: 1.7,
                                ),
                                children: _buildCISpans(
                                  language == 'en'
                                      ? 'Your tax-deductible gift funds all Chagres Initiative activities directly including: all expenses connected to workshops and field research in Panama, as well as the activities of computer mapping and analysis at U.S. universities. No overhead, administrative fees or salaries are paid with your donation.\n\nWith U.S. Federal, NGO and now even internal university funding for international research being drastically cut, we present a novel alternative: a direct public-private research partnership.\n\nWe estimate to produce a geospatial analysis and zoning plan of the Chagres National Park will take about three years and U.S. \$550,000 to complete.\n\nSimply put, your donations make the Chagres Initiative possible, paying direct project costs of community members, KU students, and professors on the research team, paying for flights to Panama, boat and truck transportation, workshop costs, field equipment, mapping materials, and stipends to cover their food, lodging, and travel.'
                                      : 'Su donación deducible de impuestos financia directamente todas las actividades de la Iniciativa Chagres, incluyendo: todos los gastos relacionados con talleres e investigación de campo en Panamá, así como las actividades de mapeo computarizado y análisis en universidades de EE.UU. Con su donación no se pagan gastos generales, honorarios administrativos ni salarios.\n\nAnte los drásticos recortes en los fondos federales de EE.UU., los de las ONG e incluso la financiación universitaria interna para la investigación internacional, presentamos una alternativa novedosa: una asociación directa de investigación público-privada.\n\nEstimamos que producir un análisis geoespacial y un plan de zonificación del Parque Nacional Chagres requerirá aproximadamente tres años y unos US\$550,000.\n\nEn pocas palabras, sus donaciones hacen posible la Iniciativa Chagres, ya que pagan los costos directos del proyecto para los miembros de la comunidad, los estudiantes y profesores de KU del equipo de investigación, así como vuelos a Panamá, transporte en barco y camión, costos de talleres, equipos de campo, materiales de mapeo y estipendios que cubren alimentación, alojamiento y transporte.',
                                  const TextStyle(
                                    color: Color(0xFFB9C6EA),
                                    fontSize: 17,
                                    height: 1.7,
                                  ),
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
                child: Builder(
                  builder: (context) {
                    final titleStyle = Theme.of(
                      context,
                    ).textTheme.displaySmall?.copyWith(color: Colors.white);
                    return Text.rich(
                      TextSpan(
                        style: titleStyle,
                        children: _buildCISpans(
                          language == 'en'
                              ? 'About the Chagres Initiative'
                              : 'Sobre la Iniciativa Chagres',
                          titleStyle,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: const Color(
                  0xFF101A2F,
                ).withOpacity(isPhone ? 1.0 : 0.82),
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
                        ? 'The Chagres Initiative responds to a legal request from an Indigenous Congress in Panama to help them map and conserve their lands inside the Chagres National Park (CNP), which supplies 40 percent of the freshwater used by Panama Canal operations and drinking water for more than 2 million people in Panama City and Colón.\n\nOur KU research team was invited by Indigenous leaders to help them map their land use inside the park. We use participatory research mapping (PRM) methodology that combines Indigenous geospatial knowledge (IGK) with GPS, air photography, and satellite imagery. Importantly, we train villagers as "community geographers" who learn field research skills and work alongside university researchers to produce accurate maps for conservation and development planning. Through this collaboration, the community gains the mapping tools they need for land protection, and together we produce scientifically rigorous data grounded in Indigenous knowledge and local experience.'
                        : 'La Iniciativa Chagres responde a una solicitud legal de un Congreso Indígena en Panamá para ayudarles a mapear y conservar sus tierras dentro del Parque Nacional Chagres (PNC), que suministra el 40 por ciento del agua dulce utilizada por las operaciones del Canal de Panamá y agua potable para más de 2 millones de personas en la Ciudad de Panamá y Colón.\n\nNuestro equipo de investigación de KU fue invitado por líderes indígenas para ayudarles a mapear el uso de su tierra dentro del parque. Utilizamos la metodología de mapeo participativo de investigación (PRM) que combina el conocimiento geoespacial indígena (CGI) con GPS, fotografía aérea e imágenes satelitales. Es importante señalar que capacitamos a los pobladores como "geógrafos comunitarios" que aprenden habilidades de investigación de campo y trabajan junto a investigadores universitarios para producir mapas precisos para la planificación de conservación y desarrollo. A través de esta colaboración, la comunidad obtiene las herramientas de mapeo que necesita para la protección de tierras, y juntos producimos datos científicamente rigurosos fundamentados en el conocimiento indígena y la experiencia local.',
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
                colors: [
                  Colors.transparent,
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
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

// Mapping Method Section — large-scale showcase of the PRM diagram.
class MappingMethodSection extends StatelessWidget {
  final String language;

  const MappingMethodSection({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final isPhone = screenWidth < 600;

    final horizontalPad = isPhone ? 20.0 : (isMobile ? 40.0 : 60.0);
    final verticalPad = isPhone ? 60.0 : 110.0;
    final prmExplainImagePath = language == 'en'
        ? 'assets/images/PRM_Explain.png'
        : 'assets/images/Spanish_PRM_Explain.png';

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
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPad,
              vertical: verticalPad,
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
                      child: Text(
                        language == 'en'
                            ? 'PRM blends Indigenous geospatial knowledge with GPS, aerial photography, and satellite imagery. The diagram below shows how lived experience becomes a shared tool for stewardship, dialogue, and protection — step by step.'
                            : 'El PRM combina el conocimiento geoespacial indígena con GPS, fotografía aérea e imágenes satelitales. El siguiente diagrama muestra cómo la experiencia vivida se convierte, paso a paso, en una herramienta compartida para la administración, el diálogo y la protección.',
                        style: TextStyle(
                          color: const Color(0xFFE5ECF5),
                          fontSize: isPhone ? 15 : 17,
                          height: 1.7,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: isPhone ? 36 : 60),
                    MouseRegion(
                      cursor: SystemMouseCursors.zoomIn,
                      child: GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) =>
                              ZoomImageDialog(imagePath: prmExplainImagePath),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              isPhone ? 12 : 20,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.45),
                                blurRadius: 34,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              isPhone ? 12 : 20,
                            ),
                            child: Image.asset(
                              prmExplainImagePath,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isPhone ? 14 : 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.zoom_in,
                          color: const Color(0xFF9EC77A),
                          size: isPhone ? 16 : 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          language == 'en'
                              ? 'Click the diagram to zoom in'
                              : 'Haz clic en el diagrama para ampliar',
                          style: TextStyle(
                            color: const Color(0xFF9EC77A),
                            fontSize: isPhone ? 13 : 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isPhone ? 20 : 28),
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
                    SizedBox(height: isPhone ? 28 : 42),
                    _ImageryPrmSideBySide(language: language),
                    SizedBox(height: isPhone ? 24 : 34),
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

// Why Donations Section
class _WhyDonationsSection extends StatelessWidget {
  final String language;
  const _WhyDonationsSection({required this.language});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 48,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0E261C).withOpacity(0.84),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFF81C784).withOpacity(0.32),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.40),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: const Color(0xFF08130E).withOpacity(0.18),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 40,
          vertical: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              language == 'en'
                  ? 'Why are Donations Necessary?'
                  : '¿Por qué son necesarias las donaciones?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Builder(
              builder: (context) {
                final whyStyle = Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(
                      color: const Color(0xFFB9C6EA),
                      fontSize: 18,
                      height: 1.75,
                    );
                return Text.rich(
                  TextSpan(
                    style: whyStyle,
                    children: _buildCISpans(
                      language == 'en'
                          ? 'Simply put, as a novel private-public research funding alternative, your support makes the Chagres Initiative possible.\n\nFederal and NGO funding sources for international research on conservation, development, and non-traditional security (NTS) threats—like "Panama Canal Water Security"—are being cut under the current U.S. administration. Therefore, we propose a public-private crowdsourcing approach allowing tax-deductible contributions.\n\nWe are launching fundraising to begin the project this Summer 2026 estimating three years and \$550,000 goal. Donations (through KU Endowment) cover direct project costs only.\n\nYour donations pay direct project costs to map and zone CNP lands for development, conservation, and watershed governance. The timeline reflects multiple field research periods and lab-based analysis. PRM requires sustained collaboration, repeated visits, and training. Donations cover travel, transportation, workshops, honoraria, field equipment, and mapping materials.\n\nWe aim to connect you, the donors, with meaningful geographic research, linking those concerned with environmental stewardship, Indigenous knowledge, and Panama Canal water security with those conducting the research.'
                          : 'En pocas palabras, como una novedosa alternativa de financiamiento público-privado para la investigación, su apoyo hace posible la Iniciativa Chagres.\n\nLas fuentes de financiamiento federales y de ONG para investigación internacional sobre conservación, desarrollo y amenazas a la seguridad no tradicional (SNT), como la "Seguridad Hídrica del Canal de Panamá", están siendo recortadas bajo la actual administración de Estados Unidos. Por lo tanto, proponemos un enfoque de financiamiento colectivo público-privado que permite contribuciones deducibles de impuestos.\n\nEstamos lanzando una campaña de recaudación de fondos para iniciar el proyecto este verano de 2026, estimando tres años y una meta de \$550,000. Las donaciones (a través de KU Endowment) cubren solo los costos directos del proyecto.\n\nSus donaciones pagan los costos directos del proyecto para mapear y zonificar las tierras del PNC para el desarrollo, la conservación y la gobernanza de cuencas hidrográficas. El cronograma refleja múltiples períodos de investigación de campo y análisis de laboratorio. PRM requiere colaboración sostenida, visitas repetidas y capacitación. Las donaciones cubren viajes, transporte, talleres, honorarios, equipos de campo y materiales de mapeo.\n\nNuestro objetivo es conectarles a ustedes, los donantes, con investigaciones geográficas significativas, vinculando a quienes se preocupan por la gestión ambiental, el conocimiento indígena y la seguridad hídrica del Canal de Panamá con quienes llevan a cabo la investigación.',
                      whyStyle,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WhyDonationsBand extends StatelessWidget {
  final String language;
  final bool isMobile;

  const _WhyDonationsBand({required this.language, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
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
              Column(children: [_WhyDonationsSection(language: language)]),
            ],
          ),
        ),
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
      ],
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
        widget.language == 'en'
            ? '1. Authorized by Indigenous Congress'
            : '1. Autorizado por el Congreso Indígena',
        widget.language == 'en'
            ? 'This project is grounded in decades of trust and expertise built by KU geography professors and students doing participatory research mapping (PRM) projects in Panama and Central America. At their governing Congreso Local in June 2025, Indigenous Emberá and Wounaan leaders from Chagres National Park (CNP) recognized our "KU know-how" from previous mapping projects with their relatives. The congreso then voted unanimously to invite us to map their lands and help them develop a management plan acceptable to the Panamanian government.'
            : 'Este proyecto se basa en décadas de confianza y experiencia construida por profesores y estudiantes de geografía de KU realizando proyectos de mapeo participativo de investigación (PRM) en Panamá y Centroamérica. En su Congreso Local en junio de 2025, los líderes indígenas Emberá y Wounaan del Parque Nacional Chagres (PNC) reconocieron nuestro "know-how de KU" de proyectos de mapeo anteriores con sus parientes. El congreso luego votó unánimemente para invitarnos a mapear sus tierras y ayudarles a desarrollar un plan de manejo aceptable para el gobierno panameño.',
      ),
      (
        widget.language == 'en'
            ? '2. "Living Research" in Indigenous Rainforest Communities of the Panama Canal Watershed'
            : '2. "Investigación Viva" en Comunidades Indígenas del Bosque Tropical de la Cuenca del Canal de Panamá',
        widget.language == 'en'
            ? 'Rather than confining findings to academic journals or static reports, this initiative maintains a transparent and evolving public platform and collaborates directly with government agencies.'
            : 'En lugar de confinar los hallazgos a revistas académicas o informes estáticos, esta iniciativa mantiene una plataforma pública transparente y en evolución y colabora directamente con agencias gubernamentales.',
      ),
      (
        widget.language == 'en'
            ? '3. Training Community Geographers as Co-Producers of Scientific Results'
            : '3. Formación de Geógrafos Comunitarios como Co-Productores de Resultados Científicos',
        widget.language == 'en'
            ? 'Unlike other projects, our results create community resources of sustained value: we formally certify community representatives as geographers who receive training, and do hands-on fieldwork, learn and use GPS, basic cartography, heads-up imagery analysis, and other geographic methods, including drone use for forest management. These "community geographers" — perhaps not surprisingly — are empowered as ideal co-producers and co-authors of project maps and data. All publication authorships are shared among team members and final cartographic information remain under the ownership of the local communities.'
            : 'A diferencia de otros proyectos, nuestros resultados crean recursos comunitarios de valor sostenido: certificamos formalmente a representantes comunitarios como geógrafos que reciben formación y realizan trabajo de campo práctico, aprenden y utilizan GPS, cartografía básica, análisis de imágenes aéreas y otros métodos geográficos, incluyendo el uso de drones para la gestión forestal. Estos "geógrafos comunitarios" — como era de esperar — se convierten en los co-productores y co-autores ideales de los mapas y datos del proyecto. La autoría de todas las publicaciones se comparte entre los miembros del equipo, y la información cartográfica final queda en propiedad de las comunidades locales.',
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 60,
        isMobile ? 20 : 24,
        isMobile ? 16 : 60,
        48,
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
                      ? 'What Makes This Project Uniquely Meaningful?'
                      : '¿Qué hace que este proyecto sea único?',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: principles.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.white.withOpacity(0.08),
                    ),
                    itemBuilder: (context, index) {
                      final principle = principles[index];
                      return Theme(
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.transparent,
                          dividerColor: Colors.transparent,
                        ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
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
                const SizedBox(height: 36),
                communitiesStat,
                const SizedBox(height: 36),
                birdStat,
                const SizedBox(height: 28),
                plantStat,
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
            child: Column(
              children: [
                communitiesStat,
                const SizedBox(height: 56),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Center(child: waterStat)),
                    const SizedBox(width: 24),
                    Expanded(child: Center(child: peopleStat)),
                    const SizedBox(width: 24),
                    Expanded(child: Center(child: birdStat)),
                    const SizedBox(width: 24),
                    Expanded(child: Center(child: plantStat)),
                  ],
                ),
              ],
            ),
          );

    // Faint jungle backdrop — same palms texture, green tint, and ~0.38 opacity
    // used by the side strips, softly faded at the top/bottom edges so it
    // blends into the surrounding green band.
    return Stack(
      alignment: Alignment.center,
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
                stops: [0.0, 0.12, 0.88, 1.0],
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
        content,
      ],
    );
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 168,
            height: 168,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF5FB5FF).withOpacity(0.08),
              border: Border.all(
                color: const Color(0xFF5FB5FF).withOpacity(0.35),
                width: 2.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: CustomPaint(painter: painter),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: GoogleFonts.inter(
              color: const Color(0xFF7CC4FF),
              fontSize: 62,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFB9C6EA),
              fontSize: 17,
              height: 1.5,
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
              'Stage One: Co-design',
              'Define mapping goals with community leadership.',
            ),
            (
              'Stage Two: Training',
              'Through instructional exercises, "community geographers" learn the use of GPS, mapping tools, and data-documentation techniques.',
            ),
            (
              'Stage Three: Field Verification and Mapping',
              'Trained community geographers collect ground-truth points and data through shared site visits to do sketch mapping and questionnaire applications in communities.',
            ),
            (
              'Stage Four: Plot Field Data onto Cartographic Sheets',
              'Plot field data onto standard cartographic sheets in community workshops. Designing Indigenous Land-use Management and zoning in workshops.',
            ),
            (
              'Stage Five: GIS and Computer Map Production',
              'KU students with professors digitize and standardize outputs for planning and governance use.',
            ),
          ]
        : [
            (
              'Etapa Uno: Codiseño',
              'Definir objetivos de mapeo con el liderazgo comunitario.',
            ),
            (
              'Etapa Dos: Capacitación',
              'A través de ejercicios de instrucción, los "geógrafos comunitarios" aprenden el uso de GPS, herramientas de mapeo y técnicas de documentación de datos.',
            ),
            (
              'Etapa Tres: Verificación de Campo y Mapeo',
              'Los geógrafos comunitarios capacitados recopilan puntos de verificación en terreno y datos mediante visitas conjuntas al sitio para realizar mapas esquemáticos y aplicar cuestionarios en las comunidades.',
            ),
            (
              'Etapa Cuatro: Trazar Datos de Campo en Hojas Cartográficas',
              'Trazar datos de campo en hojas cartográficas estándar en talleres comunitarios. Diseño del manejo del uso de tierras indígenas y zonificación en talleres.',
            ),
            (
              'Etapa Cinco: Producción de Mapas SIG y Computarizados',
              'Estudiantes de KU con profesores digitalizan y estandarizan los resultados para uso de planificación y gobernanza.',
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
              'We estimate the Chagres Initiative will have 3 overlapping phases requiring about three years in total to complete depending on funding availability:\n\nYear 1-2: Participatory research mapping and geospatial database development.\nYear 1-2: Consensus-driven zoning and development of community land-use guidelines.\nYear 2-3: Final map production, synthesis, and integration into management planning frameworks.\n\nThe participatory research mapping approach is iterative, with alternating workshops and field research in Panama followed by GIS and computer mapping analyzes at the universities to obtain the most precise cartographic and spatial data on resource use in the Chagres National Park for developing an Indigenous and state approved management plan for land use in the park.',
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
              'Estimamos que la Iniciativa Chagres tendrá 3 fases superpuestas que requerirán aproximadamente tres años en total para completarse dependiendo de la disponibilidad de fondos:\n\nAño 1-2: Mapeo participativo de investigación y desarrollo de base de datos geoespacial.\nAño 1-2: Zonificación impulsada por consenso y desarrollo de directrices de uso del suelo comunitario.\nAño 2-3: Producción final del mapa, síntesis e integración en marcos de planificación de manejo.\n\nEl enfoque de mapeo participativo de investigación es iterativo, con talleres e investigación de campo alternados en Panamá seguidos de análisis de SIG y mapeo computarizado en las universidades para obtener los datos cartográficos y espaciales más precisos sobre el uso de recursos en el Parque Nacional Chagres para desarrollar un plan de manejo de uso del suelo aprobado por las comunidades indígenas y el estado.',
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
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 60,
            vertical: 60,
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

class _WorkingDraftBanner extends StatelessWidget {
  final String language;
  const _WorkingDraftBanner({required this.language});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      width: double.infinity,
      color: const Color(0xFF0C1328),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 14,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 14 : 20,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF5B83D).withOpacity(0.10),
              border: Border.all(
                color: const Color(0xFFF5B83D).withOpacity(0.55),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.construction,
                  color: Color(0xFFF5B83D),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    language == 'en'
                        ? 'While the project has launched and the fundraising platform is live, this website is still under construction and should be considered a working draft.'
                        : 'Aunque el proyecto ya se lanzó y la plataforma de recaudación de fondos está activa, este sitio web aún se encuentra en construcción y debe considerarse un borrador en desarrollo.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: isMobile ? 13 : 14,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
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
