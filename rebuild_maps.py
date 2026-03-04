with open('lib/main.dart', 'r') as f:
    content = f.read()

start = content.find('class MapsSection extends StatelessWidget {')
if start < 0:
    print("NOT FOUND")
    exit(1)

# Count braces to find end
brace_count = 0
i = start
while i < len(content):
    if content[i] == '{':
        brace_count += 1
    elif content[i] == '}':
        brace_count -= 1
        if brace_count == 0:
            end = i + 1
            break
    i += 1

replacement = '''class MapsSection extends StatelessWidget {
  final String language;

  const MapsSection({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 60,
      ),
      child: Column(
        children: [
          Text(
            language == 'en' ? 'Project Map            language == 'en' ? 'Project Map            language == 'en' ? 'Project Mapl?            language == 'en' ?: Colors            language),
                                                                   ner(
                              oration(
              color: const Color(0xFF101A2F),
              borderRadius: BorderRadiu              borderRa      ),
            padding:            padding:    ),
            child: Column(
              children: [
                ClipRRect(
                          diu                          diu                          dipect                                                    diu                       age.asset(
                      'assets/images/chagres_broadermap.jpg',
                      fit: BoxFit.cover,
                                                                               const SizedBox(height: 16),
                     
                    nguage == '                            'This ov                    nguage == '                            'This ov                    nguage == '                    atory research mapping work with the community of La Bonga.'
                      : 'Este mapa de descripción general sitúa la cuenca del Río                       : 'Este ional Chagres - el escenario geográfico para nuestro t                      : 'Este mapa de descripción  la comunidad de La Bonga.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xF                    color: const Color(0xF                    color: const Color(0xF                    color: const Color(0xF                    color: const Color(0xF                               color: const C     borderRadius: BorderRadius.circular(12),
                    chi                    chi                    chi                    chi                    chi             ,
                ElevatedButton(
                  onPressed: () {
                    launchUrl(Uri.parse(
                      'https://www.google.com/maps/place/San+Juan+de+Pequní+Indígena+(+La+Bonga)/@9.3827301,-79.5241626,17z/data=!3m1!4b1!4m6!3m5!1s0x8fab494a7                      'https://www.google.com/maps/place/San+Juan+de+Pequní+Indígena+(+La+Bonga)/@9.3827301,-79.5241626,17z/data=!3m1!4b1!4m6!3m5!1s0x8fab494a7                      'https://www.google.com/maps/place/San+Juan+de+Pequní+Indígena+oo                      'https://www.google.com/maps/place/San+Juan+de+Pequ              ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}'''

result = content[:start] + replacement + content[end:]

with open('lib/main.dart', 'w') as f:
    f.write(result)

print('SUCCESS')
