import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// AstroSage-style "Planet Signification" tab
/// Shows for each planet: which houses it signifies via KP rules
class PlanetSignificationTab extends StatelessWidget {
  final Map<String, dynamic> planetSignificators;
  final Map<String, dynamic> kpPlanets;

  const PlanetSignificationTab({
    super.key,
    required this.planetSignificators,
    required this.kpPlanets,
  });

  static const _lordAbbrev = {
    'Surya': 'Su', 'Chandra': 'Mo', 'Mangal': 'Ma', 'Budha': 'Me',
    'Guru': 'Ju', 'Shukra': 'Ve', 'Shani': 'Sa', 'Rahu': 'Ra', 'Ketu': 'Ke',
    'Sun': 'Su', 'Moon': 'Mo', 'Mars': 'Ma', 'Mercury': 'Me',
    'Jupiter': 'Ju', 'Venus': 'Ve', 'Saturn': 'Sa',
  };

  String _lordAbb(String? lord) => _lordAbbrev[lord] ?? (lord?.substring(0, 2) ?? '-');

  static const _planetOrder = [
    'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'
  ];

  static const _abbrev = {
    'Sun': 'Su', 'Moon': 'Mo', 'Mars': 'Ma', 'Mercury': 'Me',
    'Jupiter': 'Ju', 'Venus': 'Ve', 'Saturn': 'Sa', 'Rahu': 'Ra', 'Ketu': 'Ke'
  };

  static const _planetNames = {
    'Sun': 'Sun', 'Moon': 'Moon', 'Mars': 'Mars', 'Mercury': 'Mercury',
    'Jupiter': 'Jupiter', 'Venus': 'Venus', 'Saturn': 'Saturn', 'Rahu': 'Rahu', 'Ketu': 'Ketu'
  };

  static const _planetIcons = {
    'Sun': '☀️', 'Moon': '🌙', 'Mars': '♂', 'Mercury': '☿',
    'Jupiter': '♃', 'Venus': '♀', 'Saturn': '♄', 'Rahu': '☊', 'Ketu': '☋'
  };

  static const _houseThemes = [
    Color(0xFFE53935), // H1 - red
    Color(0xFF8E24AA), // H2 - purple
    Color(0xFF1E88E5), // H3 - blue
    Color(0xFF00897B), // H4 - teal
    Color(0xFF43A047), // H5 - green
    Color(0xFFE67E22), // H6 - orange
    Color(0xFFE53935), // H7
    Color(0xFF8E24AA), // H8
    Color(0xFF1E88E5), // H9
    Color(0xFF00897B), // H10
    Color(0xFF43A047), // H11
    Color(0xFFE67E22), // H12
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldBg,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // Table 1: Combined Significations (Both Planet & NL)
          _buildTableSection(
            title: 'Combined KP Planet Signification',
            subtitle: 'Houses signified by each planet (Planet + Nakshatra Lord combined)',
            houseKey: 'houses',
            tableType: 'combined',
          ),
          
          const SizedBox(height: 24),
          
          // Table 2: Planet Only Significations
          _buildTableSection(
            title: 'Planet Houses (Occupant & Lord)',
            subtitle: 'Houses signified ONLY by the Planet itself',
            houseKey: 'planet_houses',
            tableType: 'planet_only',
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTableSection({
    required String title,
    required String subtitle,
    required String houseKey,
    required String tableType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Banner
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppColors.textMedium, height: 1.4),
              ),
            ],
          ),
        ),

        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(children: [
            if (tableType == 'combined' || tableType == 'planet_only')
              const Expanded(flex: 3, child: Text('Planet', style: _hStyle)),
            if (tableType == 'combined' || tableType == 'nl_only')
              const Expanded(flex: 2, child: Text('NL', style: _hStyle)),
            const Expanded(flex: 7, child: Text('Houses Signified', style: _hStyle)),
          ]),
        ),

        // Table Body
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
            border: Border.all(color: AppColors.primary.withOpacity(0.35)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.06),
                blurRadius: 10, offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: List.generate(_planetOrder.length, (idx) {
              final pName = _planetOrder[idx];
              final pData = (planetSignificators[pName] ?? planetSignificators[pName.toLowerCase()]) as Map<String, dynamic>?;
              return _planetRow(idx, pName, pData, houseKey, tableType);
            }),
          ),
        ),
      ],
    );
  }

  Widget _planetRow(int index, String planet, Map<String, dynamic>? data, String houseKey, String tableType) {
    final bg = index.isOdd ? Colors.white : const Color(0xFFFFFBF5);
    final abbrev = _abbrev[planet] ?? planet.substring(0, 2);
    final fullName = _planetNames[planet] ?? planet;
    final icon = _planetIcons[planet] ?? '★';
    
    final kpPlanetData = kpPlanets[planet] as Map<String, dynamic>?;
    final String nlRaw = kpPlanetData?['nakshatra_lord']?.toString() ?? '-';
    final String nlAbb = _lordAbb(nlRaw);

    // Retrieve houses list from response using the specific houseKey
    final houses = (data?[houseKey] as List<dynamic>? ?? []).map((e) => (e as num).toInt()).toList();
    houses.sort();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(children: [
        // Planet column
        if (tableType == 'combined' || tableType == 'planet_only')
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      abbrev,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    Text(
                      fullName,
                      style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // NL column
        if (tableType == 'combined' || tableType == 'nl_only')
          Expanded(
            flex: 2,
            child: Row(
              children: [
                if (tableType == 'nl_only')
                  const Icon(Icons.star_border_rounded, size: 14, color: Color(0xFF1565C0)),
                if (tableType == 'nl_only')
                  const SizedBox(width: 6),
                Text(
                  nlAbb,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ),

        // Houses Signified column (Modern chip layout)
        Expanded(
          flex: 7,
          child: houses.isEmpty
              ? const Text('—', style: TextStyle(color: AppColors.textLight, fontSize: 12))
              : Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: houses.map((h) {
                    final color = _houseThemes[(h - 1) % _houseThemes.length];
                    return Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: color.withOpacity(0.6), width: 1),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$h',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ]),
    );
  }

  static const _hStyle = TextStyle(
    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12,
  );
}
