import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

void main() {
  // Register the Google Maps iframe view factory for web
  ui.platformViewRegistry.registerViewFactory(
    'google-maps-embed',
    (int viewId) => html.IFrameElement()
      ..src = 'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3949.823992608622!2d-79.5241626!3d9.3827301!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x8fab494a734c2493%3A0xe55e405b5412d0dc!2sSan%20Juan%20de%20Pequen%C3%AD%20Ind%C3%ADgena%20(La%20Bonga)!5e0!3m2!1sen!2sus!4v1730000000000'
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
  
  // GlobalKey references for each section
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _methodologyKey = GlobalKey();
  final GlobalKey _fieldworkKey = GlobalKey();
  final GlobalKey _teamKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();
  final GlobalKey _donateKey = GlobalKey();
  final GlobalKey _reportsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
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
    
    // Track active section
    _updateActiveSection();
  }

  void _updateActiveSection() {
    final Map<GlobalKey, String> sections = {
      _teamKey: 'Team',
      _aboutKey: 'About',
      _methodologyKey: 'Methodology',
      _reportsKey: 'Fieldwork',
      _faqKey: 'FAQ',
      _donateKey: 'Donate',
    };

    String newActiveSection = '';
    double closestDistance = double.infinity;
    
    // Find the section closest to the top of the viewport (around 150px)
    for (var entry in sections.entries) {
      final context = entry.key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          final offset = box.localToGlobal(Offset.zero);
          final distanceFromTop = (offset.dy - 150).abs();
          
          // Prioritize sections that are above the viewport marker (150px)
          if (offset.dy < 150 && offset.dy > -box.size.height) {
            if (distanceFromTop < closestDistance) {
              closestDistance = distanceFromTop;
              newActiveSection = entry.value;
            }
          }
        }
      }
    }
    
    // If no section found above marker, use the first one visible
    if (newActiveSection.isEmpty) {
      for (var entry in sections.entries) {
        final context = entry.key.currentContext;
        if (context != null) {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null) {
            final offset = box.localToGlobal(Offset.zero);
            if (offset.dy < 300) {
              newActiveSection = entry.value;
              break;
            }
          }
        }
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
              imageProvider: const AssetImage('assets/images/Oval_Logo.png'),
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
                TeamSection(key: _teamKey, language: widget.language),
                AboutSection(key: _aboutKey, language: widget.language),
                MeaningfulSection(language: widget.language),
                AuthorizationSection(language: widget.language),
                MethodologySection(key: _methodologyKey, language: widget.language),
                FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Image.asset('assets/images/community_meeting.jpg'),
                  ),
                ),
                GallerySection(language: widget.language),
                MapsSection(language: widget.language),
                ReportsSection(key: _reportsKey, language: widget.language),
                FAQSection(key: _faqKey, language: widget.language),
                DonateSection(key: _donateKey, language: widget.language),
                NewsletterSection(language: widget.language),
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
          child: Image.asset(
            'assets/images/Oval_Logo.png',
            height: 48,
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
                  'assets/images/Oval_Logo.png',
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
            widget.language == 'en' ? 'Donate' : 'Donar',
            _donateKey,
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
              child: Image.asset(
                'assets/images/Oval_Logo.png',
                height: 80,
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
              _buildNavLink('Donate', _donateKey),
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

// Hero Section
class HeroSection extends StatelessWidget {
  final String language;

  const HeroSection({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: isMobile ? 40 : 60,
      ),
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
      child: Column(
        children: [
          Text(
            language == 'en'
                ? 'Chagres Initiative'
                : 'La Iniciativa Chagres',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontFamily: 'serif',
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: const Offset(1.5, 1.5),
                  blurRadius: 3.0,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 0 : 100,
            ),
            child: Text(
              language == 'en'
                  ? 'A KU and UT-Arlington Geographic, Participatory Research Mapping Project with the Indigenous Community of San Juan Pequení Indígena La Bonga, Panama'
                  : 'Un Proyecto de Mapeo Participativo del Departamento de Geografía de KU con la Comunidad Indígena de San Juan Pequení Indígena La Bonga, Panamá',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFFB9C6EA),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 30),
          // Hero Strip Image
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF81C784),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/images/here_strip.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Poem Image
          Image.asset(
            'assets/images/poem.png',
            width: isMobile ? 280 : 360,
            fit: BoxFit.contain,
            opacity: const AlwaysStoppedAnimation(0.95),
          ),
          const SizedBox(height: 40),
          // Donation Section - Oval with transparent crimson background
          GestureDetector(
            onTap: () {
              launchUrl(Uri.parse('https://geog.ku.edu/donate'));
            },
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                color: const Color(0xFFE8000D).withOpacity(0.50),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: const Color(0xFFE8000D).withOpacity(0.7),
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Column(
                children: [
                  Text(
                    language == 'en'
                        ? 'You can be part of our team by donating.'
                        : 'Puedes ser parte de nuestro equipo donando.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            language == 'en'
                ? 'Your tax-deductible donation directly supports paid Indigenous research collaborators, participatory mapping workshops, watershed monitoring equipment, and field support for KU and UT-Arlington student researchers working to map Chagres National Park.'
                : 'Tu donación deducible de impuestos apoya directamente a los colaboradores de investigación indígena remunerados, talleres de mapeo participativo, equipos de monitoreo de cuencas y apoyo de campo para investigadores estudiantes.',
            style: const TextStyle(
              color: Color(0xFFB9C6EA),
              fontSize: 17,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// About Section
class AboutSection extends StatelessWidget {
  final String language;

  const AboutSection({super.key, required this.language});

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
                language == 'en' ? 'About the Initiative' : 'Sobre la Iniciativa',
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 34,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            padding: const EdgeInsets.all(30),
            child: Text(
              language == 'en'
                  ? 'The Chagres Initiative is a community-based participatory zoning and monitoring effort in the Río Pequení sub-basin of Chagres National Park, the most strategically important watershed in the Panama Canal system. The park supplies an estimated 40 percent of the water used in Canal operations and about 80 percent of Panama City\'s drinking water. Yet limited on-the-ground monitoring and enforcement in remote areas has enabled illegal settlement and deforestation, while the Emberá community of San Juan Pequení Indígena La Bonga remains in legal limbo as it seeks collective land recognition under Panama\'s 2008 Law 72. Working with Indigenous leaders, neighboring campesino residents, and Canal institutions, the project combines participatory research mapping with GIS and remote sensing to co-produce consensus land-use zones and locally grounded monitoring tools that can strengthen watershed governance and Canal water security.'
                  : 'La Iniciativa Chagres es un esfuerzo comunitario participativo de zonificación y monitoreo en la subcuenca del Río Pequení del Parque Nacional Chagres, la cuenca más estratégicamente importante del sistema del Canal de Panamá. El parque proporciona aproximadamente el 40 por ciento del agua utilizada en las operaciones del Canal y aproximadamente el 80 por ciento del agua potable de la Ciudad de Panamá. Sin embargo, el monitoreo limitado en el terreno y la ejecución en áreas remotas ha permitido asentamientos ilegales y deforestación, mientras que la comunidad Emberá de San Juan Pequení Indígena La Bonga permanece en un limbo legal mientras busca reconocimiento de tierras colectivas bajo la Ley 72 de 2008 de Panamá. Trabajando con líderes indígenas, residentes campesinos vecinos e instituciones del Canal, el proyecto combina mapeo participativo de investigación con SIG y teledetección para coproducir zonas de uso del suelo por consenso y herramientas de monitoreo locales que pueden fortalecer la gobernanza de cuencas hidrográficas y la seguridad del agua del Canal.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFB9C6EA),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Image.asset(
            'assets/images/labonga_seal.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

// Meaningful Section
class MeaningfulSection extends StatelessWidget {
  final String language;

  const MeaningfulSection({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    
    return Container(
      color: const Color(0xFF0C1328),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 60,
      ),
      child: Column(
        children: [
          Text(
            language == 'en'
                ? 'What Makes This Project Uniquely Meaningful?'
                : '¿Qué hace que este proyecto sea único?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrincipleCard(
                  context,
                  language == 'en' ? '1. Co-Produced, Not Extractive' : '1. Co-Producido, No Extractivo',
                  language == 'en'
                      ? 'This project is built on a partnership with the Indigenous community of San Juan Pequeñí La Bonga, Panama. Community members are not research subjects; they are paid collaborators and co-producers of spatial knowledge.'
                      : 'Este proyecto se basa en una asociación con la comunidad indígena de San Juan Pequeñí La Bonga, Panamá. Los miembros de la comunidad no son sujetos de investigación; son colaboradores pagados y coproductores de conocimiento espacial.',
                ),
                const SizedBox(height: 20),
                _buildPrincipleCard(
                  context,
                  language == 'en' ? '2. Public-Facing, Living Research' : '2. Investigación Pública y Viva',
                  language == 'en'
                      ? 'Rather than confining findings to academic journals or static reports, this initiative maintains a transparent and evolving public platform.'
                      : 'En lugar de confinar hallazgos a revistas académicas o informes estáticos, esta iniciativa mantiene una plataforma pública transparente y en evolución.',
                ),
                const SizedBox(height: 20),
                _buildPrincipleCard(
                  context,
                  language == 'en'
                      ? '3. Institutionally Anchored, Grassroots Supported'
                      : '3. Anclado Institucionalmente',
                  language == 'en'
                      ? 'The project is endorsed by the University of Kansas Department of Geography and the KU Center for Latin American and Caribbean Studies.'
                      : 'El proyecto está respaldado por el Departamento de Geografía de la Universidad de Kansas y el Centro de Estudios Latinoamericanos y del Caribe de KU.',
                ),
                const SizedBox(height: 20),
                _buildPrincipleCard(
                  context,
                  language == 'en' ? '4. Applied and Accountable' : '4. Aplicado y Responsable',
                  language == 'en'
                      ? 'The research is designed to produce tangible outcomes: participatory zoning frameworks, watershed monitoring strategies, and spatial tools.'
                      : 'La investigación está diseñada para producir resultados tangibles: marcos de zonificación participativa, estrategias de monitoreo de cuencas hidrográficas y herramientas espaciales.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrincipleCard(
    BuildContext context,
    String title,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFFB9C6EA),
          ),
        ),
      ],
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
    
    return Padding(
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
                      ? 'During our team\'s visit to La Bonga during the summer of 2025, we presented openly the participatory research methodology to the community in Spanish. After understanding the potential of such a project, they unanimously voted in support of our project.'
                      : 'Durante la visita de nuestro equipo a La Bonga en el verano de 2025, presentamos abiertamente la metodología de investigación participativa a la comunidad en español. Después de entender el potencial de tal proyecto, votaron unánimemente en apoyo de nuestro proyecto.',
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
class MethodologySection extends StatelessWidget {
  final String language;

  const MethodologySection({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    
    final stages = language == 'en'
        ? [
            ('Stage One: Co-design', 'Define mapping goals collaboratively with community leadership.'),
            ('Stage Two: Training', 'Equip local researchers with GPS, mapping, and documentation tools.'),
            ('Stage Three: Field Verification', 'Collect ground-truth points through shared site visits.'),
            ('Stage Four: GIS Production', 'Digitize and standardize outputs for planning and governance use.'),
          ]
        : [
            ('Etapa Uno: Codiseño', 'Definir objetivos de mapeo colaborativamente con el liderazgo comunitario.'),
            ('Etapa Dos: Capacitación', 'Capacitar a investigadores locales con herramientas de GPS, mapeo y documentación.'),
            ('Etapa Tres: Verificación de Campo', 'Recopilar puntos de verdad a través de visitas compartidas al sitio.'),
            ('Etapa Cuatro: Producción SIG', 'Digitalizar y estandarizar los resultados para uso de planificación y gobernanza.'),
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
                language == 'en'
                    ? 'Stages of Participatory Research Mapping (PRM)'
                    : 'Etapas del Mapeo de Investigación Participativa',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: isMobile ? 1 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            children: stages
                .map(
                  (stage) => Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF101A2F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          stage.$1,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontFamily: 'serif',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stage.$2,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFB9C6EA),
                            fontFamily: 'serif',
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
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
    'assets/images/signing.jpeg',
  ];
  final List<(String, String)> _captions = [
    ('River lancha transport', 'Transporte en lancha por el río'),
    ('Field tour in watershed', 'Gira de campo en la cuenca hidrográfica'),
    ('Indigenous cultural performance', 'Presentación cultural indígena'),
    ('Community member portrait', 'Retrato de miembro de la comunidad'),
    ('Community leadership engagement', 'Participación del liderazgo comunitario'),
    ('Site analysis at Panamanian Geographic Institute', 'Análisis del sitio en el Instituto Geográfico de Panamá'),
    ('Rainforest lizard', 'Lagarto de la selva tropical'),
    ('Rainforest monkey', 'Mono de la selva tropical'),
    ('Chief Marcelino Guatico and President Elieser signing letter of endorsement', 'Jefe Marcelino Guatico y Presidente Elieser firmando carta de apoyo'),
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
          SizedBox(
            width: double.infinity,
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
        ],
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
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF101A2F),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 450,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ZoomableImage(
                      imagePath: 'assets/images/chagres_broadermap.jpg',
                      height: 450,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  language == 'en'
                      ? 'This overview map situates the Río Pequení watershed within Chagres National Park - the geographic setting for our participatory research mapping work with the community of La Bonga.'
                      : 'Este mapa de descripción general sitúa la cuenca del Río Pequení dentro del Parque Nacional Chagres - el escenario geográfico para nuestro trabajo de mapeo de investigación participativa con la comunidad de La Bonga.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFB9C6EA),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 400,
                  child: _GoogleMapEmbed(),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
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
                ),
              ],
            ),
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
                ? 'Ongoing field reflections, research updates, and official project documentation from the Chagres Initiative.'
                : 'Reflexiones continuas de campo, actualizaciones de investigación y documentación oficial del proyecto de la Iniciativa Chagres.',
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
            ('Why does the health of Chagres National Park matter for people in the United States?', 'Chagres National Park provides approximately 40 percent of the freshwater used in Panama Canal operations and roughly 80 percent of the drinking water for Panama City. The Canal remains one of the most strategically important global trade corridors, moving a significant portion of U.S.-bound maritime commerce.\n\nRecent droughts have demonstrated that water scarcity is the Canal\'s greatest operational vulnerability. Long-term watershed health directly affects trade reliability, regional diplomatic stability, and economic security.'),
            ('Who and what legal authority authorizes this project?', 'This initiative proceeds only with community consent and institutional coordination. During a reconnaissance expedition in Summer 2025, the research team met with the Indigenous community of San Juan Pequeñí, participated in a formal Local Congress, and received written approval.\n\nThis authorization aligns with Panama\'s 2008 Law 72 governing Collective Indigenous Lands. The project continues only through collaborative agreement with community leadership.'),
            ('How does mapping help protect an area like this?', 'National park boundaries alone do not ensure protection. Effective stewardship requires understanding the ecological and social processes occurring within those boundaries.\n\nParticipatory research mapping translates Indigenous geographic knowledge into structured formats that can support zoning, monitoring, and long-term governance planning. At a fundamental level, it is difficult to protect what is not clearly understood.'),
            ('How are community members involved and compensated?', 'Community members are trained as local geographers in GPS data collection and mapping techniques. Participants are compensated for their time and expertise.'),
            ('How long will the project take?', 'The project is designed in three phases, depending on funding:\n\nYear 1: Participatory mapping and geospatial database development.\n\nYear 2: Consensus-driven zoning and development of community land-use guidelines.\n\nYear 3: Final map production, synthesis, and integration into management planning frameworks.\n\nThis phased approach prioritizes thoroughness and long-term impact over speed.'),
            ('How will donated funds be used?', 'Donated funds directly support field-based research and community collaboration. Primary expenditures include workshops, equipment (GPS, drones, starlink), local geographer compensation, and researcher travel.\n\nAdministrative costs are minimized through institutional partnership with the University of Kansas. The project prioritizes directing resources toward community engagement and conservation outcomes.'),
            ('Is this project political?', 'The project is non-partisan and research-driven. Its focus is watershed stewardship, participatory governance, and environmental monitoring.'),
            ('Will the data be publicly available?', 'Final outputs will be shared publicly. Sensitive knowledge remains under community control in accordance with data sovereignty principles.'),
            ('Can this model be replicated elsewhere?', 'Yes. The framework combines participatory GIS, zoning, and institutional collaboration in a structured format designed to be adaptable to other protected areas.'),
            ('Hasn\'t the whole world been mapped already?', 'No. There is a difference between remote imagery of an area from satellites and the kinds of maps we are making. The level of detail combining physical geography with cultural-historical information in the community is unique and critical to our process.'),
          ]
        : [
            ('¿Por qué importa la salud del Parque Nacional Chagres?', 'El Parque Nacional Chagres proporciona aproximadamente el 40 por ciento del agua dulce utilizada en las operaciones del Canal de Panamá y aproximadamente el 80 por ciento del agua potable para la Ciudad de Panamá. El Canal sigue siendo uno de los corredores comerciales globales más estratégicamente importantes.\n\nLas sequías recientes han demostrado que la escasez de agua es la mayor vulnerabilidad operativa del Canal. La salud de la cuenca a largo plazo afecta directamente la confiabilidad del comercio, la estabilidad diplomática regional y la seguridad económica.'),
            ('¿Quién autoriza este proyecto?', 'Esta iniciativa procede solo con consentimiento comunitario y coordinación institucional. Durante una expedición de reconocimiento en verano de 2025, el equipo de investigación se reunió con la comunidad indígena de San Juan Pequeñí, participó en un Congreso Local formal y recibió aprobación escrita.\n\nEsta autorización se alinea con la Ley 72 de 2008 de Panamá que rige las Tierras Colectivas Indígenas. El proyecto continúa solo a través de acuerdo colaborativo con el liderazgo comunitario.'),
            ('¿Cómo ayuda el mapeo a proteger un área?', 'Los límites del parque nacional por sí solos no garantizan la protección. El manejo efectivo requiere comprender los procesos ecológicos y sociales que ocurren dentro de esos límites.\n\nEl mapeo participativo de investigación traduce el conocimiento geográfico indígena a formatos estructurados que pueden apoyar la zonificación, el monitoreo y la planificación de gobernanza a largo plazo. En un nivel fundamental, es difícil proteger lo que no se entiende claramente.'),
            ('¿Cómo se compensan a los miembros de la comunidad?', 'Los miembros de la comunidad se capacitan como geógrafos locales en recopilación de datos GPS y técnicas de mapeo. Los participantes reciben compensación por su tiempo y experiencia.'),
            ('¿Cuánto tiempo tomará el proyecto?', 'El proyecto está diseñado en tres fases, dependiendo de la financiación:\n\nAño 1: Mapeo participativo y desarrollo de base de datos geoespacial.\n\nAño 2: Zonificación impulsada por consenso y desarrollo de directrices de uso del suelo comunitario.\n\nAño 3: Producción final del mapa, síntesis e integración en marcos de planificación de manejo.\n\nEste enfoque graduado prioriza la minuciosidad e impacto a largo plazo sobre la velocidad.'),
            ('¿Cómo se usarán los fondos donados?', 'Los fondos donados apoyan directamente la investigación de campo y la colaboración comunitaria. Los gastos principales incluyen talleres, equipos (GPS, drones, starlink), compensación de geógrafos locales y viajes de investigadores.\n\nLos costos administrativos se minimizan a través de asociación institucional con la Universidad de Kansas. El proyecto prioriza dirigir recursos hacia el compromiso comunitario y resultados de conservación.'),
            ('¿Es este proyecto político?', 'El proyecto es apartidista e impulsado por la investigación. Su enfoque es el manejo de cuencas hidrográficas, gobernanza participativa y monitoreo ambiental.'),
            ('¿Estarán los datos disponibles públicamente?', 'Los resultados finales se compartirán públicamente. El conocimiento sensible permanece bajo control comunitario de acuerdo con los principios de soberanía de datos.'),
            ('¿Se puede replicar este modelo en otros lugares?', 'Sí. El marco combina SIG participativo, zonificación y colaboración institucional en un formato estructurado diseñado para ser adaptable a otras áreas protegidas.'),
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
          Text(
            answer,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFFB9C6EA),
              height: 1.6,
            ),
          ),
        ],
        shape: Border.all(color: Colors.transparent),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
      ),
    );
  }
}

// Donate Section
class DonateSection extends StatelessWidget {
  final String language;

  const DonateSection({super.key, required this.language});

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
                language == 'en'
                    ? 'Support the Chagres Initiative'
                    : 'Apoye la Iniciativa Chagres',
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
                Text(
                  language == 'en'
                      ? 'The Chagres Geographic Fund directly supports equitable, community-based research partnerships in Panama.'
                      : 'El Fondo Geográfico Chagres apoya directamente asociaciones de investigación equitativas y basadas en la comunidad en Panamá.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFB9C6EA),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildListItem(
                      language == 'en'
                          ? 'Workshops Expenses (GPS, Drones, Starlink, mapping materials, meals)'
                          : 'Gastos de Talleres (GPS, Drones, Starlink, materiales de mapeo, comidas)',
                    ),
                    _buildListItem(
                      language == 'en'
                          ? 'Local Geographer Honorariums and Travel'
                          : 'Honorarios y Viajes de Geógrafos Locales',
                    ),
                    _buildListItem(
                      language == 'en'
                          ? 'Researcher and Student Travel Expenses'
                          : 'Gastos de Viaje de Investigadores y Estudiantes',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    launchUrl(Uri.parse('https://geog.ku.edu/donate'));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8000D),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    language == 'en'
                        ? 'Donate to the Chagres Geographic Fund'
                        : 'Donar al Fondo Geográfico Chagres',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 12, top: 4),
            child: Icon(
              Icons.check_circle,
              size: 16,
              color: Color(0xFFE8000D),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFB9C6EA),
                fontSize: 17,
              ),
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
    final isMobile = MediaQuery.of(context).size.width < 900;
    
    return Container(
      color: const Color(0xFF0C1328),
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
          // Team Photo
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/team.jpg',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    language == 'en'
                        ? 'The Original Research Team from KU: Taylor Tappan, Sam Morrow, Peter Herlihy and Cap McLiney'
                        : 'El Equipo de Investigación Original de KU: Taylor Tappan, Sam Morrow, Peter Herlihy y Cap McLiney',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF9BB1D6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
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
              ('Sam Morrow', 'MA Student', 'Estudiante de Maestría', 'sam.morrow@ku.edu', 'sam.jpg'),
              ('Amali Hipp', 'PhD Student', 'Estudiante de Doctorado', 'ahippe@ku.edu', 'Hipp_Headshot.jpg'),
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
              ('Dr. Taylor Tappan', 'Associate Professor of Geography', 'Profesor Asociado de Geografía', 'taylor.tappan@uta.edu', 'taylor.jpg'),
            ],
            language,
            isMobile,
          ),
        ],
      ),
    );
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
            alignment: WrapAlignment.start,
            spacing: 10,
            runSpacing: 10,
            children: members
                .map(
                  (member) => SizedBox(
                    width: isMobile ? ((MediaQuery.of(context).size.width - 40) / 2) - 5 : 170,
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
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[700],
            backgroundImage: AssetImage('assets/images/$imageName'),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            position,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFFB9C6EA),
              fontSize: 16,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          if (email.isNotEmpty)
            GestureDetector(
              onTap: () {
                launchUrl(Uri(
                  scheme: 'mailto',
                  path: email,
                ));
              },
              child: Text(
                email,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF0051BA),
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
          Text(
            '© 2026 The Chagres Initiative - KU Department of Geography',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFFB9C6EA),
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
  final _emailController = TextEditingController();
  bool _isSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submitEmail() {
    if (_emailController.text.isNotEmpty) {
      setState(() => _isSubmitted = true);
      // In a real app, you would send this to your backend
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isSubmitted = false);
          _emailController.clear();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      color: const Color(0xFF101A2F),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 60,
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
          Text(
            widget.language == 'en'
                ? 'Subscribe to receive the latest updates about the Chagres Initiative.'
                : 'Suscríbase para recibir las últimas actualizaciones sobre la Iniciativa Chagres.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFB9C6EA),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: widget.language == 'en' ? 'Your email' : 'Tu correo',
                      hintStyle: const TextStyle(color: Color(0xFF666666)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF0051BA)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF0051BA),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _submitEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0051BA),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  child: Text(
                    _isSubmitted
                        ? (widget.language == 'en' ? '✓' : '✓')
                        : (widget.language == 'en' ? 'Subscribe' : 'Suscribirse'),
                    style: const TextStyle(color: Colors.white),
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
