import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// AstroSage-style "Planet Significators" tab
/// Shows for each house: which planets signify it via KP rules
class HouseSignificatorsTab extends StatelessWidget {
  final Map<String, dynamic> houseSignificators;
  final Map<String, dynamic> kpPlanets;

  const HouseSignificatorsTab({
    super.key,
    required this.houseSignificators,
    required this.kpPlanets,
  });

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

  static const _houseNames = [
    'Tanu (Self, Body)', 'Dhana (Wealth)', 'Sahaj (Siblings)',
    'Matru (Mother)', 'Putra (Children)', 'Ripu (Enemies)',
    'Yuvati (Spouse)', 'Mrityu (Longevity)', 'Bhagya (Luck)',
    'Karma (Career)', 'Labha (Gains)', 'Vyaya (Expenses)',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldBg,
      child: ListView(
        padding: const EdgeInsets.all(14),
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
            child: const Text(
              'KP House Significators — Planets that signify each house based on occupancy and star lord placement',
              style: TextStyle(fontSize: 11, color: AppColors.textMedium, height: 1.5),
            ),
          ),

          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(children: const [
              Expanded(flex: 2, child: Text('Hs',   style: _hStyle)),
              Expanded(flex: 4, child: Text('Sign / Lord', style: _hStyle)),
              Expanded(flex: 4, child: Text('Occupants', style: _hStyle)),
              Expanded(flex: 5, child: Text('Significators', style: _hStyle)),
            ]),
          ),

          // Rows
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
              children: List.generate(12, (i) {
                final hNum = i + 1;
                final data = houseSignificators[hNum.toString()] as Map<String, dynamic>?;
                if (data == null) return const SizedBox.shrink();
                return _houseRow(i, hNum, data);
              }),
            ),
          ),

          const SizedBox(height: 20),

          // House cards (expanded view)
          ...List.generate(12, (i) {
            final hNum = i + 1;
            final data = houseSignificators[hNum.toString()] as Map<String, dynamic>?;
            if (data == null) return const SizedBox.shrink();
            return _houseCard(i, hNum, data);
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _houseRow(int index, int hNum, Map<String, dynamic> data) {
    final bg = index.isOdd ? Colors.white : const Color(0xFFFFFBF5);
    final occupants = (data['occupant_abbrevs'] as List<dynamic>? ?? []).join(', ');
    final sigsStr = (data['significators_abbrevs'] as List<dynamic>? ?? []).join(', ');
    final signLord = data['sign_lord_abbrev']?.toString() ?? '-';
    final sign = data['sign']?.toString() ?? '-';
    final color = _houseThemes[index % _houseThemes.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(children: [
        Expanded(flex: 2, child: Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text('$hNum', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        )),
        Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(sign, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
          Text(signLord, style: const TextStyle(fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.bold)),
        ])),
        Expanded(flex: 4, child: Text(
          occupants.isEmpty ? '—' : occupants,
          style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: occupants.isEmpty ? AppColors.textLight : const Color(0xFF1565C0),
          ),
        )),
        Expanded(flex: 5, child: Text(
          sigsStr.isEmpty ? '—' : sigsStr,
          style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: sigsStr.isEmpty ? AppColors.textLight : const Color(0xFF2E7D32),
          ),
        )),
      ]),
    );
  }

  Widget _houseCard(int index, int hNum, Map<String, dynamic> data) {
    final color = _houseThemes[index % _houseThemes.length];
    final sl = data['sign_lord']?.toString() ?? '-';
    final nl = data['nakshatra_lord']?.toString() ?? '-';
    final sb = data['sub_lord']?.toString() ?? '-';
    final houseName = _houseNames[index];

    // All significators combined
    final allSigs = List<String>.from(data['significators'] ?? []);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
            border: Border(bottom: BorderSide(color: color.withOpacity(0.2))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text('$hNum', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('House $hNum', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                        Text(houseName, style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
                      ],
                    ),
                  ),
                ],
              ),
              if (allSigs.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: allSigs.map((s) => _sigChip(s, color)).toList(),
                ),
              ],
            ],
          ),
        ),

        // Details
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(children: [
            _detRow('Sign', data['sign']?.toString() ?? '-', Icons.place),
            _detRow('Sign Lord (SL)', sl, Icons.star_rounded),
            _detRow('Nakshatra Lord (NL)', nl, Icons.brightness_2_rounded),
            _detRow('Sub Lord (SB)', sb, Icons.blur_circular_rounded),
            _detRow('Level 1 (Grade A)', (data['grade_a'] as List<dynamic>? ?? []).join(', '), Icons.looks_one_rounded),
            _detRow('Level 2 (Grade B)', (data['grade_b'] as List<dynamic>? ?? []).join(', '), Icons.looks_two_rounded),
            _detRow('Level 3 (Grade C)', (data['grade_c'] as List<dynamic>? ?? []).join(', '), Icons.looks_3_rounded),
            _detRow('Level 4 (Grade D)', (data['grade_d'] as List<dynamic>? ?? []).join(', '), Icons.looks_4_rounded),
          ]),
        ),
      ]),
    );
  }

  Widget _sigChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _detRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icon, size: 14, color: AppColors.textLight),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
      ]),
    );
  }

  static const _hStyle = TextStyle(
    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12,
  );
}
