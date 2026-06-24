import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/kundli_controller.dart';
import '../theme/app_theme.dart';
import '../theme/custom_shadows.dart';
import 'kundli/chart_tab.dart';
import 'kundli/planets_tab.dart';
import 'kundli/cusps_tab.dart';
import 'kundli/dasha_tab.dart';
import 'kundli/yoga_tab.dart';
import 'kundli/lal_kitab_tab.dart';
import 'kundli/personal_details_tab.dart';
import 'kundli/reports_tab.dart';
import 'kundli/varshphal_tab.dart';
import 'kundli/predictions_tab.dart';

class PremiumKundliScreen extends StatefulWidget {
  const PremiumKundliScreen({super.key});

  @override
  State<PremiumKundliScreen> createState() => _PremiumKundliScreenState();
}

class _PremiumKundliScreenState extends State<PremiumKundliScreen> {
  bool _showLottie = true;

  // 12 directions data mapping
  final List<Map<String, dynamic>> _directionConfigs = [
    {
      'direction': 'East (E)',
      'house': '1st House',
      'icon': Icons.wb_sunny_rounded,
      'color': Colors.orange,
      'significance': 'Self, vitality, health & social connection.',
      'guideline': 'Keep this zone light, open and well-lit. Avoid heavy metal items.'
    },
    {
      'direction': 'North-East (NE)',
      'house': '2nd House',
      'icon': Icons.psychology_rounded,
      'color': Colors.blue,
      'significance': 'Mental clarity, wisdom & wealth accumulation.',
      'guideline': 'Perfect for prayer, meditation or study. Keep completely clean & clutter-free.'
    },
    {
      'direction': 'North-North-East (NNE)',
      'house': '3rd House',
      'icon': Icons.health_and_safety_rounded,
      'color': Colors.teal,
      'significance': 'Health, immunity, communication & courage.',
      'guideline': 'Excellent zone for storing medicines. Do not place waste bins or heavy storage here.'
    },
    {
      'direction': 'North (N)',
      'house': '4th House',
      'icon': Icons.monetization_on_rounded,
      'color': Colors.green,
      'significance': 'New opportunities, wealth & domestic peace.',
      'guideline': 'Placing a water element or green plants here invites career growth.'
    },
    {
      'direction': 'North-North-West (NNW)',
      'house': '5th House',
      'icon': Icons.favorite_rounded,
      'color': Colors.purple,
      'significance': 'Attraction, relationships, intellect & children.',
      'guideline': 'Promotes love and harmony. Keep clean and decorated with beautiful items.'
    },
    {
      'direction': 'North-West (NW)',
      'house': '6th House',
      'icon': Icons.support_rounded,
      'color': Colors.indigo,
      'significance': 'Support, banking, debts & physical healing.',
      'guideline': 'Ideal for a guest bedroom or storage of finished goods. Avoid clutter.'
    },
    {
      'direction': 'West (W)',
      'house': '7th House',
      'icon': Icons.handshake_rounded,
      'color': Colors.blueGrey,
      'significance': 'Partnerships, marriage, business & profits.',
      'guideline': 'Represents gains and savings. Keep this area stable, clean and balanced.'
    },
    {
      'direction': 'South-West (SW)',
      'house': '8th House',
      'icon': Icons.shield_rounded,
      'color': Colors.red,
      'significance': 'Stability, longevity, relationships & skill.',
      'guideline': 'Best zone for the master bedroom. Do not place water features or toilets here.'
    },
    {
      'direction': 'South-South-West (SSW)',
      'house': '9th House',
      'icon': Icons.delete_sweep_rounded,
      'color': Colors.brown,
      'significance': 'Disposal, expenditure, letting go & fortune.',
      'guideline': 'Ideal for toilet, kitchen sink or waste disposal. Avoid studying or sleeping here.'
    },
    {
      'direction': 'South (S)',
      'house': '10th House',
      'icon': Icons.work_rounded,
      'color': Colors.deepOrange,
      'significance': 'Fame, career, recognition & relaxation.',
      'guideline': 'Best for a home office or bedroom. Keep this zone heavy and elevated.'
    },
    {
      'direction': 'South-South-East (SSE)',
      'house': '11th House',
      'icon': Icons.bolt_rounded,
      'color': Colors.amber,
      'significance': 'Confidence, strength, elder siblings & gains.',
      'guideline': 'Boosts mental and physical energy. Avoid placing blue or black colors here.'
    },
    {
      'direction': 'South-East (SE)',
      'house': '12th House',
      'icon': Icons.local_fire_department_rounded,
      'color': Colors.redAccent,
      'significance': 'Cash flow, fire element, expenditure & travels.',
      'guideline': 'Ideal place for kitchen or electrical main board. Avoid water elements directly here.'
    },
  ];

  static const rashiList = [
    'Mesh','Vrishabh','Mithun','Kark','Singh','Kanya',
    'Tula','Vrischik','Dhanu','Makar','Kumbh','Meen'
  ];

  static const abbrev = {
    'Sun':'Su','Moon':'Mo','Mars':'Ma','Mercury':'Me',
    'Jupiter':'Ju','Venus':'Ve','Saturn':'Sa','Rahu':'Ra','Ketu':'Ke'
  };

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _showLottie = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<KundliController>();
    final data = c.kundliData.value;

    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Premium Kundli')),
        body: const Center(child: Text('No premium data available')),
      );
    }

    final planets   = data['planets']   as Map<String, dynamic>;
    final ascendant = data['ascendant'];
    final kpPlanets   = data['kp_planets']   as Map<String, dynamic>? ?? planets;
    final kpAscendant = data['kp_ascendant'] ?? ascendant;
    final dasha     = data['dasha']     as List<dynamic>? ?? [];
    final charDasha = data['char_dasha'] as List<dynamic>? ?? [];
    final yoginiDasha = data['yogini_dasha'] as List<dynamic>? ?? [];
    final mahadashaPhala = data['mahadasha_phala'] as List<dynamic>? ?? [];
    final yogas     = data['yogas']     as List<dynamic>? ?? [];
    final doshas    = data['doshas']    as Map<String, dynamic>? ?? {};
    final numerology  = data['numerology']  as Map<String, dynamic>? ?? {};
    final lalKitab    = data['lal_kitab']   as Map<String, dynamic>? ?? {};
    final personalDetails = data['personal_details'] as Map<String, dynamic>? ?? {};
    final predictions = data['predictions'] as List<dynamic>? ?? [];

    // Get planets in each house to display alongside directions
    int lagnaIdx = rashiList.indexOf(ascendant['rashi'] ?? '');
    if (lagnaIdx == -1) lagnaIdx = 0;

    // Planets grouped by their Rashi (sign) for the directions Vastu analysis
    final List<List<String>> planetsInRashis = List.generate(12, (_) => []);
    planets.forEach((key, value) {
      if (!abbrev.containsKey(key) || value is! Map) return;
      final pRashiIdx = rashiList.indexOf(value['rashi'] ?? '');
      if (pRashiIdx >= 0 && pRashiIdx < 12) {
        planetsInRashis[pRashiIdx].add(key);
      }
    });

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: Row(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'] ?? '',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    const Text(
                      'Premium Astro-Vastu Kundli',
                      style: TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
                onPressed: () => Get.back(),
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kundli Chart directly (without card container/border/title)
                SizedBox(
                  height: 540,
                  child: ChartTab(
                    ascendant: ascendant,
                    planets: planets,
                    kpAscendant: kpAscendant,
                    kpPlanets: kpPlanets,
                    showDirections: true,
                  ),
                ),

                // Other details with padding below the chart
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Premium Banner Card
                      _buildPremiumHeader(data),
                      const SizedBox(height: 12),

                      // Chandra (Moon) House Sign Card
                      _buildMoonHouseSignCard(planets, lagnaIdx),
                      const SizedBox(height: 12),

                      // Naam Rashi (Name Sign) House Sign Card
                      _buildNameHouseSignCard(data['name'] ?? '', lagnaIdx, planets),
                      const SizedBox(height: 12),

                      // Name Astrology Section (Only in Premium Kundli)
                      _buildNameAnalysisCard(data['name'] ?? '', lagnaIdx, planets),
                      const SizedBox(height: 12),

                      // 12 Directions Vastu Section
                      _buildDirectionsSection(planetsInRashis, lagnaIdx),
                      const SizedBox(height: 12),

                      // Personal Details Section
                      _buildSectionCard(
                        title: 'Personal Details',
                        icon: Icons.person_outline_rounded,
                        child: SizedBox(
                          height: 400,
                          child: PersonalDetailsTab(personalDetails: personalDetails),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Planets Section
                      _buildSectionCard(
                        title: 'Planet Degrees & Positions',
                        icon: Icons.stars_rounded,
                        child: SizedBox(
                          height: 480,
                          child: PlanetsTab(planets: planets, ascendant: ascendant),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Cusps Section
                      _buildSectionCard(
                        title: 'Cusps & KP System Details',
                        icon: Icons.border_all_rounded,
                        child: SizedBox(
                          height: 480,
                          child: CuspsTab(kpAscendant: kpAscendant),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Dasha Timeline
                      _buildSectionCard(
                        title: 'Dasha / Planetary Periods',
                        icon: Icons.timelapse_rounded,
                        child: SizedBox(
                          height: 500,
                          child: DashaTab(
                            dasha: dasha,
                            charDasha: charDasha,
                            yoginiDasha: yoginiDasha,
                            mahadashaPhala: mahadashaPhala,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Yogas Section
                      _buildSectionCard(
                        title: 'Yogas & Astrological Combinations',
                        icon: Icons.auto_awesome_rounded,
                        child: SizedBox(
                          height: 480,
                          child: YogaTab(yogas: yogas),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Lal Kitab Remedies
                      _buildSectionCard(
                        title: 'Lal Kitab & Remedies',
                        icon: Icons.book_rounded,
                        child: SizedBox(
                          height: 480,
                          child: LalKitabTab(lalKitab: lalKitab),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Reports & Doshas
                      _buildSectionCard(
                        title: 'Vedic Reports (Doshas & Numerology)',
                        icon: Icons.analytics_rounded,
                        child: SizedBox(
                          height: 480,
                          child: ReportsTab(doshas: doshas, numerology: numerology),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Kundli Predictions Section
                      _buildSectionCard(
                        title: 'Kundli Predictions / फलादेश',
                        icon: Icons.description_rounded,
                        child: SizedBox(
                          height: 480,
                          child: PredictionsTab(predictions: predictions),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Varshphal Report Section
                      _buildSectionCard(
                        title: 'Varshphal / Annual Predictions',
                        icon: Icons.calendar_month_rounded,
                        child: const SizedBox(
                          height: 600,
                          child: VarshphalTab(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showLottie)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showLottie = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Lottie.network(
                    'https://assets9.lottiefiles.com/packages/lf20_u4yrau.json',
                    width: 350,
                    height: 350,
                    repeat: false,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.flare_rounded, color: Colors.amber, size: 100);
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPremiumHeader(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE0A920), Color(0xFFE07B20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: CustomShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PREMIUM ANALYSIS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Owner Access',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data['name'] ?? '',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            'Birth details: ${data['date']} • ${data['time']} • ${data['place'] ?? 'Unknown'}',
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const Divider(color: Colors.white30, height: 24),
          const Text(
            'This premium report contains advanced Vastu direction calculations mapping your 12 houses to cosmic zones, combined with your birth chart and planetary locations.',
            style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionsSection(List<List<String>> planetsInRashis, int lagnaIdx) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFFFE0B2), width: 1.2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          leading: const Icon(Icons.explore_rounded, color: Colors.amber),
          title: const Text(
            '12 Directions & Astro-Vastu Analysis',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mapping of 12 Houses to Vastu directions and placement of planets:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF555555), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 12,
                    separatorBuilder: (context, index) => const Divider(height: 24, color: AppColors.divider),
                    itemBuilder: (context, idx) {
                      final config = _directionConfigs[idx];
                      final planetsInDir = planetsInRashis[idx];
                      final directionColor = config['color'] as Color;
                      final int houseIdx = (idx - lagnaIdx + 12) % 12;
                      final int houseNum = houseIdx + 1;
                      final String houseSuffix = houseNum == 1 ? 'st' : houseNum == 2 ? 'nd' : houseNum == 3 ? 'rd' : 'th';

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: directionColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(config['icon'] as IconData, color: directionColor, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      config['direction'] as String,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: directionColor.darken(20),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$houseNum$houseSuffix House (${config['rashi']})',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Significance: ${config['significance']}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Vastu Guideline: ${config['guideline']}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Text(
                                      'Planets Present: ',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black),
                                    ),
                                    if (planetsInDir.isEmpty)
                                      const Text(
                                        'None (Clean & Stable Energy)',
                                        style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                                      )
                                    else
                                      Wrap(
                                        spacing: 6,
                                        children: planetsInDir.map((p) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade50,
                                              border: Border.all(color: Colors.orange.shade200),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              p,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange.shade900,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    bool isExpanded = false,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 1.0),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          leading: Icon(icon, color: AppColors.primary),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameAnalysisCard(String name, int lagnaIdx, Map<String, dynamic> planets) {
    if (name.isEmpty) return const SizedBox();
    final details = _calculateNaamRashiDetails(name);
    if (details.isEmpty) return const SizedBox();

    // Get actual Moon nakshatra/lord from birth chart
    final moon = planets['Moon'] as Map<String, dynamic>? ?? {};
    final birthNakshatra = moon['nakshatra'] as String? ?? details['nakshatra'] ?? '';
    final birthNakshatraLord = moon['nakshatra_lord'] as String? ?? details['nakshatra_lord'] ?? '';

    // Rashi color mapping
    Color rashiColor;
    final rashiName = details['rashi']?.split(' ').first ?? '';
    switch (rashiName) {
      case 'Mesh': rashiColor = const Color(0xFFE53935); break;
      case 'Vrishabh': rashiColor = const Color(0xFF8E24AA); break;
      case 'Mithun': rashiColor = const Color(0xFF1E88E5); break;
      case 'Kark': rashiColor = const Color(0xFF00897B); break;
      case 'Singh': rashiColor = const Color(0xFFE67E22); break;
      case 'Kanya': rashiColor = const Color(0xFF43A047); break;
      case 'Tula': rashiColor = const Color(0xFF1565C0); break;
      case 'Vrischik': rashiColor = const Color(0xFFAD1457); break;
      case 'Dhanu': rashiColor = const Color(0xFF6D4C41); break;
      case 'Makar': rashiColor = const Color(0xFF546E7A); break;
      case 'Kumbh': rashiColor = const Color(0xFF00838F); break;
      case 'Meen': rashiColor = const Color(0xFF558B2F); break;
      default: rashiColor = const Color(0xFFE07B20);
    }

    // House ordinals and significances
    const houseOrdinals = {
      1: '1st', 2: '2nd', 3: '3rd', 4: '4th', 5: '5th', 6: '6th',
      7: '7th', 8: '8th', 9: '9th', 10: '10th', 11: '11th', 12: '12th'
    };
    const houseSignificances = {
      1: 'Self, Personality, Health, Aura',
      2: 'Wealth, Speech, Family, Values',
      3: 'Courage, Communication, Siblings, Travel',
      4: 'Happiness, Mother, Home, Vehicles',
      5: 'Intellect, Children, Love, Creativity',
      6: 'Daily Work, Health, Service, Competitions',
      7: 'Marriage, Partnerships, Public Image',
      8: 'Longevity, Transformation, Secrets, Intuition',
      9: 'Dharma, Luck, Father, Higher Education',
      10: 'Career, Recognition, Action, Status',
      11: 'Income, Gains, Social Circle, Desires',
      12: 'Losses, Spiritual Connection, Sleep, Foreign Travel'
    };

    // Name Rashi house in chart
    final naamRashiIdx = rashiList.indexOf(rashiName);
    String naamRashiHouseSign = '-';
    if (naamRashiIdx != -1) {
      final h = (naamRashiIdx - lagnaIdx + 12) % 12 + 1;
      naamRashiHouseSign = '${houseOrdinals[h]} House — ${houseSignificances[h]}';
    }

    // Name Nakshatra house sign — find which Rashi contains birth nakshatra, then map to house
    String naamNakshatraHouseSign = '-';
    String nakRashiFound = '';
    for (final entry in rashiNakshatras.entries) {
      for (final nak in entry.value) {
        if (_isMatchingNakshatra(birthNakshatra, nak['name']!)) {
          nakRashiFound = entry.key;
          break;
        }
      }
      if (nakRashiFound.isNotEmpty) break;
    }
    if (nakRashiFound.isNotEmpty) {
      final nakRashiIdx = rashiList.indexOf(nakRashiFound);
      if (nakRashiIdx != -1) {
        final h = (nakRashiIdx - lagnaIdx + 12) % 12 + 1;
        naamNakshatraHouseSign = '${houseOrdinals[h]} House — ${houseSignificances[h]}';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 12),
          child: Row(
            children: [
              const Icon(Icons.spellcheck_rounded, color: Colors.black, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Name Astrology (Naam Rashi & Nakshatra)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Details Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              _buildDetailRow('Active Name Analyzed', name, valueColor: const Color(0xFFE07B20)),
              _buildDetailRow('Naam Rashi (Name Sign)', details['rashi'] ?? '', valueColor: rashiColor),
              _buildDetailRow('Rashi Lord (Sign Ruler)', details['lord'] ?? '', valueColor: rashiColor.darken(15)),
              _buildDetailRow('Naam Nakshatra (Birth)', birthNakshatra),
              _buildDetailRow('Nakshatra Lord', birthNakshatraLord),
              _buildDetailRow('Name Rashi House Sign', naamRashiHouseSign, valueColor: const Color(0xFFE07B20)),
              _buildDetailRow('Name Nakshatra House Sign', naamNakshatraHouseSign, isLast: true),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Premium Note Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF8F2), Color(0xFFFFF2E6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFE0B2), width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.stars_rounded, color: Colors.amber.shade800, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'AURA & DESTINY NOTE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.amber.shade900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Your birth chart moon sign governs your inner self, while your active name "$name" represents your social vibration. Your name vibrates with ${details['rashi']} energy. The Naam Nakshatra ($birthNakshatra, lord: $birthNakshatraLord) shapes your destiny and aura in profound ways.',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF5D4037),
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _calculateNaamRashiDetails(String name) {
    if (name.isEmpty) return {};
    String firstLetter = name.trim().substring(0, 1).toUpperCase();
    
    switch (firstLetter) {
      case 'A':
      case 'L':
      case 'E':
      case 'I':
        return {
          'rashi': 'Mesh (Aries)',
          'lord': 'Mars (Mangal)',
          'nakshatra': 'Aswini',
          'nakshatra_lord': 'Ketu',
          'element': 'Fire (Agni)',
          'house_significance': '1st House (Self, Physique, Aura)',
          'direction': 'East (E)',
        };
      case 'B':
      case 'V':
      case 'U':
      case 'O':
        return {
          'rashi': 'Vrishabh (Taurus)',
          'lord': 'Venus (Shukra)',
          'nakshatra': 'Rohini',
          'nakshatra_lord': 'Moon',
          'element': 'Earth (Prithvi)',
          'house_significance': '2nd House (Wealth, Speech, Family)',
          'direction': 'South (S)',
        };
      case 'K':
      case 'G':
      case 'C':
      case 'H':
        return {
          'rashi': 'Mithun (Gemini)',
          'lord': 'Mercury (Budh)',
          'nakshatra': 'Mrigashira',
          'nakshatra_lord': 'Mars',
          'element': 'Air (Vayu)',
          'house_significance': '3rd House (Valour, Communication, Siblings)',
          'direction': 'West (W)',
        };
      case 'D':
        return {
          'rashi': 'Kark (Cancer)',
          'lord': 'Moon (Chandra)',
          'nakshatra': 'Pushya',
          'nakshatra_lord': 'Saturn',
          'element': 'Water (Jal)',
          'house_significance': '4th House (Happiness, Mother, Vehicles)',
          'direction': 'North (N)',
        };
      case 'M':
      case 'T':
        return {
          'rashi': 'Singh (Leo)',
          'lord': 'Sun (Surya)',
          'nakshatra': 'Magha',
          'nakshatra_lord': 'Ketu',
          'element': 'Fire (Agni)',
          'house_significance': '5th House (Intellect, Creativity, Love)',
          'direction': 'East (E)',
        };
      case 'P':
      case 'S':
        return {
          'rashi': 'Kanya (Virgo)',
          'lord': 'Mercury (Budh)',
          'nakshatra': 'Hasta',
          'nakshatra_lord': 'Moon',
          'element': 'Earth (Prithvi)',
          'house_significance': '6th House (Daily work, Healing, Service)',
          'direction': 'South (S)',
        };
      case 'R':
        return {
          'rashi': 'Tula (Libra)',
          'lord': 'Venus (Shukra)',
          'nakshatra': 'Swati',
          'nakshatra_lord': 'Rahu',
          'element': 'Air (Vayu)',
          'house_significance': '7th House (Partnerships, Marriage, Public)',
          'direction': 'West (W)',
        };
      case 'N':
      case 'Y':
        return {
          'rashi': 'Vrischik (Scorpio)',
          'lord': 'Mars (Mangal)',
          'nakshatra': 'Anuradha',
          'nakshatra_lord': 'Saturn',
          'element': 'Water (Jal)',
          'house_significance': '8th House (Intuition, Transformation, Secret knowledge)',
          'direction': 'North (N)',
        };
      case 'F':
      case 'W':
        return {
          'rashi': 'Dhanu (Sagittarius)',
          'lord': 'Jupiter (Guru)',
          'nakshatra': 'Moola',
          'nakshatra_lord': 'Ketu',
          'element': 'Fire (Agni)',
          'house_significance': '9th House (Dharma, Luck, Higher learning)',
          'direction': 'East (E)',
        };
      case 'J':
        return {
          'rashi': 'Makar (Capricorn)',
          'lord': 'Saturn (Shani)',
          'nakshatra': 'Shravana',
          'nakshatra_lord': 'Moon',
          'element': 'Earth (Prithvi)',
          'house_significance': '10th House (Career, Recognition, Action)',
          'direction': 'South (S)',
        };
      case 'Z':
      case 'X':
        return {
          'rashi': 'Kumbh (Aquarius)',
          'lord': 'Saturn (Shani)',
          'nakshatra': 'Shatabhisha',
          'nakshatra_lord': 'Rahu',
          'element': 'Air (Vayu)',
          'house_significance': '11th House (Social network, Gains, Ambitions)',
          'direction': 'West (W)',
        };
      default:
        return {
          'rashi': 'Meen (Pisces)',
          'lord': 'Jupiter (Guru)',
          'nakshatra': 'Revati',
          'nakshatra_lord': 'Mercury',
          'element': 'Water (Jal)',
          'house_significance': '12th House (Spiritual connection, Losses, Sleep)',
          'direction': 'North (N)',
        };
    }
  }

  static const rashiHindi = {
    'Mesh': 'मेष', 'Vrishabh': 'वृषभ', 'Mithun': 'मिथुन', 'Kark': 'कर्क',
    'Singh': 'सिंह', 'Kanya': 'कन्या', 'Tula': 'तुला', 'Vrischik': 'वृश्चिक',
    'Dhanu': 'धनु', 'Makar': 'मकर', 'Kumbh': 'कुंभ', 'Meen': 'मीन'
  };

  static const rashiLordsHindi = {
    'Mesh': 'मंगल', 'Vrishabh': 'शुक्र', 'Mithun': 'बुध', 'Kark': 'चंद्र',
    'Singh': 'सूर्य', 'Kanya': 'बुध', 'Tula': 'शुक्र', 'Vrischik': 'मंगल',
    'Dhanu': 'गुरु', 'Makar': 'शनि', 'Kumbh': 'शनि', 'Meen': 'गुरु'
  };

  static const Map<String, List<Map<String, String>>> rashiNakshatras = {
    'Mesh': [
      {'name': 'अश्विनी', 'letters': 'चू, चे, चो, ला', 'lord': 'केतु'},
      {'name': 'भरणी', 'letters': 'ली, लू, ले, लो', 'lord': 'शुक्र'},
      {'name': 'कृत्तिका 1 चरण', 'letters': 'अ, [आ]', 'lord': 'सूर्य'},
    ],
    'Vrishabh': [
      {'name': 'कृत्तिका 3 चरण', 'letters': 'ई, उ, ए, [ऊ, ऐ]', 'lord': 'सूर्य'},
      {'name': 'रोहिणी', 'letters': 'ओ, वा, वी, वू, [औ, बा, बी, बू]', 'lord': 'चंद्र'},
      {'name': 'मृगशिरा 2 चरण', 'letters': 'वे, वो, [बे, बो]', 'lord': 'मंगल'},
    ],
    'Mithun': [
      {'name': 'मृगशिरा 2 चरण', 'letters': 'का, की', 'lord': 'मंगल'},
      {'name': 'आर्द्रा', 'letters': 'कू, घ, ङ, छ', 'lord': 'राहु'},
      {'name': 'पुनर्वसु 3 चरण', 'letters': 'के, को, हा', 'lord': 'गुरु'},
    ],
    'Kark': [
      {'name': 'पुनर्वसु 1 चरण', 'letters': 'ही', 'lord': 'गुरु'},
      {'name': 'पुष्य', 'letters': 'हू, हे, हो, डा', 'lord': 'शनि'},
      {'name': 'आश्लेषा', 'letters': 'डी, डू, डे, डो, [ढी, ढू, ढे, ढो]', 'lord': 'बुध'},
    ],
    'Singh': [
      {'name': 'मघा', 'letters': 'मा, मी, मू, मे', 'lord': 'केतु'},
      {'name': 'पूर्वाफाल्गुनी', 'letters': 'मो, टा, टी, टू', 'lord': 'शुक्र'},
      {'name': 'उत्तराफाल्गुनी 1 चरण', 'letters': 'टे', 'lord': 'सूर्य'},
    ],
    'Kanya': [
      {'name': 'उत्तराफाल्गुनी 3 चरण', 'letters': 'टो, पा, पी', 'lord': 'सूर्य'},
      {'name': 'हस्त', 'letters': 'पू, ष, ण, ठ, [ठे]', 'lord': 'चंद्र'},
      {'name': 'चित्रा 2 चरण', 'letters': 'पे, पो', 'lord': 'मंगल'},
    ],
    'Tula': [
      {'name': 'चित्रा 2 चरण', 'letters': 'रा, री', 'lord': 'मंगल'},
      {'name': 'स्वाती', 'letters': 'रू, रे, रो, ता', 'lord': 'राहु'},
      {'name': 'विशाखा 3 चरण', 'letters': 'ती, तू, ते', 'lord': 'गुरु'},
    ],
    'Vrischik': [
      {'name': 'विशाखा 1 चरण', 'letters': 'तो', 'lord': 'गुरु'},
      {'name': 'अनुराधा', 'letters': 'ना, नी, नू, ने', 'lord': 'शनि'},
      {'name': 'ज्येष्ठा', 'letters': 'नो, या, यी, यू', 'lord': 'बुध'},
    ],
    'Dhanu': [
      {'name': 'मूल', 'letters': 'ये, यो, bh, bh', 'lord': 'केतु'},
      {'name': 'पूर्वाषाढ़ा', 'letters': 'भू, धा, फा, ढा, [धी, धू, फ़ा]', 'lord': 'शुक्र'},
      {'name': 'उत्तराषाढ़ा 1 चरण', 'letters': 'भे', 'lord': 'सूर्य'},
    ],
    'Makar': [
      {'name': 'उत्तराषाढ़ा 3 चरण', 'letters': 'भो, जा, जी', 'lord': 'सूर्य'},
      {'name': 'श्रवण', 'letters': 'खी, खू, खे, खो', 'lord': 'चंद्र'},
      {'name': 'धनिष्ठा 2 चरण', 'letters': 'गा, गी', 'lord': 'मंगल'},
    ],
    'Kumbh': [
      {'name': 'धनिष्ठा 2 चरण', 'letters': 'गू, गे', 'lord': 'मंगल'},
      {'name': 'शतभिषा', 'letters': 'गो, सा, सी, सू, [शा, शी, शू, श]', 'lord': 'राहु'},
      {'name': 'पूर्वाभाद्रपद 3 चरण', 'letters': 'से, सो, दा', 'lord': 'गुरु'},
    ],
    'Meen': [
      {'name': 'पूर्वाभाद्रपद 1 चरण', 'letters': 'दी', 'lord': 'गुरु'},
      {'name': 'उत्तराभाद्रपद', 'letters': 'दू, थ, झ, ञ, [था, थी, थू, थे, थो]', 'lord': 'शनि'},
      {'name': 'रेवती', 'letters': 'दे, दो, चा, ची', 'lord': 'बुध'},
    ],
  };

  bool _isMatchingNakshatra(String engNak, String hindiNak) {
    String normalizedEng = engNak.replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase();
    String normalizedHindi = hindiNak.replaceAll(RegExp(r'[0-9\s\-\u2014]'), '').replaceAll('चरण', '');
    
    if (normalizedEng == 'pphalguni' && normalizedHindi.contains('पूर्वाफाल्गुनी')) return true;
    if (normalizedEng == 'uphalguni' && normalizedHindi.contains('उत्तराफाल्गुनी')) return true;
    if (normalizedEng == 'pashadha' && normalizedHindi.contains('पूर्वाषाढ़ा')) return true;
    if (normalizedEng == 'uashadha' && normalizedHindi.contains('उत्तराषाढ़ा')) return true;
    if (normalizedEng == 'pbhadra' && normalizedHindi.contains('पूर्वाभाद्रपद')) return true;
    if (normalizedEng == 'ubhadra' && normalizedHindi.contains('उत्तराभाद्रपद')) return true;
    if (normalizedEng == 'moola' && normalizedHindi.contains('मूल')) return true;
    if (normalizedEng == 'swati' && normalizedHindi.contains('स्वाती')) return true;

    final Map<String, String> translation = {
      'ashwini': 'अश्विनी', 'bharani': 'भरणी', 'krittika': 'कृत्तिका',
      'rohini': 'रोहिणी', 'mrigashira': 'मृगशिरा', 'ardra': 'आर्द्रा',
      'punarvasu': 'पुनर्वसु', 'pushya': 'पुष्य', 'ashlesha': 'आश्लेषा',
      'magha': 'मघा', 'hasta': 'हस्त', 'chitra': 'चित्रा',
      'anuradha': 'अनुराधा', 'jyeshtha': 'ज्येष्ठा', 'shravana': 'श्रवण',
      'dhanishtha': 'धनिष्ठा', 'shatabhisha': 'शतभिषा', 'revati': 'रेवती'
    };

    if (translation.containsKey(normalizedEng)) {
      return normalizedHindi.contains(translation[normalizedEng]!);
    }
    return false;
  }

  String _formatDegree(dynamic deg) {
    if (deg == null) return '-';
    final d = (deg as num).toDouble();
    final degrees = d.floor();
    final minsTotal = ((d - degrees) * 60);
    final minutes = minsTotal.floor();
    final seconds = ((minsTotal - minutes) * 60).round();
    return "${degrees.toString().padLeft(2, '0')}°${minutes.toString().padLeft(2, '0')}'${seconds.toString().padLeft(2, '0')}\"";
  }

  Widget _detRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildMoonHouseSignCard(Map<String, dynamic> planets, int lagnaIdx) {
    final chandra = planets['Moon'] as Map<String, dynamic>?;
    if (chandra == null) return const SizedBox();

    final moonRashi = chandra['rashi'] as String? ?? 'Mesh';
    final moonRashiHindi = rashiHindi[moonRashi] ?? moonRashi;
    final moonRashiLordHindi = rashiLordsHindi[moonRashi] ?? '';
    final moonNakshatra = chandra['nakshatra'] as String? ?? '';
    final moonPada = chandra['pada'] as int? ?? 1;

    final nakList = rashiNakshatras[moonRashi] ?? [];
    
    String moonFirstLetter = '-';
    int activeNakIdx = -1;
    for (int idx = 0; idx < nakList.length; idx++) {
      if (_isMatchingNakshatra(moonNakshatra, nakList[idx]['name']!)) {
        activeNakIdx = idx;
        final lettersStr = nakList[idx]['letters']!;
        moonFirstLetter = lettersStr.split(',').first.replaceAll('[', '').replaceAll(']', '').trim();
        break;
      }
    }

    final Color orange = AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: orange.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: orange.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [orange.withOpacity(0.85), const Color(0xFFFFB0C0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'चंद्र (Moon)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'घर ${chandra['house'] ?? '-'}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _detRow('राशि', '$moonRashiHindi ($moonRashiLordHindi)'),
                _detRow('नक्षत्र', '$moonNakshatra पद $moonPada'),
                _detRow('नक्षत्र स्वामी', chandra['nakshatra_lord'] ?? '-'),
                _detRow('नामाक्षर', moonFirstLetter),
                _detRow('अंश', _formatDegree(chandra['degree'])),
                _detRow('गति (Speed)', '${(chandra['speed'] as num? ?? 0).toStringAsFixed(4)}°/day'),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: orange.withOpacity(0.02),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$moonRashiHindi राशि के सभी नक्षत्र और नामाक्षर:',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                ...nakList.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  final isCurrent = idx == activeNakIdx;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCurrent ? orange.withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrent ? orange : Colors.grey.shade200,
                        width: isCurrent ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCurrent ? Icons.stars_rounded : Icons.radio_button_off_rounded,
                          color: isCurrent ? orange : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${item['name']} (${item['letters']}) — ${item['lord']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: isCurrent ? orange : Colors.black87,
                            ),
                          ),
                        ),
                        if (isCurrent)
                          Text(
                            'सक्रिय',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: orange),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameHouseSignCard(String name, int lagnaIdx, [Map<String, dynamic>? planets]) {
    if (name.isEmpty) return const SizedBox();
    final details = _calculateNaamRashiDetails(name);
    if (details.isEmpty) return const SizedBox();

    final rashiName = details['rashi']?.split(' ').first ?? 'Mesh';
    final nameRashiHindi = rashiHindi[rashiName] ?? rashiName;
    final nameRashiLordHindi = rashiLordsHindi[rashiName] ?? '';
    // Use Moon's actual nakshatra from birth chart if available
    final moon = planets?['Moon'] as Map<String, dynamic>? ?? {};
    final nameNakshatra = (moon['nakshatra'] as String?)?.isNotEmpty == true
        ? moon['nakshatra'] as String
        : details['nakshatra'] ?? '';
    final nameNakshatraLord = (moon['nakshatra_lord'] as String?)?.isNotEmpty == true
        ? moon['nakshatra_lord'] as String
        : details['nakshatra_lord'] ?? '';
    
    final naamRashiIdx = rashiList.indexOf(rashiName);
    int houseNum = 1;
    if (naamRashiIdx != -1) {
      houseNum = (naamRashiIdx - lagnaIdx + 12) % 12 + 1;
    }

    final nakList = rashiNakshatras[rashiName] ?? [];
    
    String nameFirstLetter = name.trim().substring(0, 1).toUpperCase();
    int activeNakIdx = -1;
    for (int idx = 0; idx < nakList.length; idx++) {
      if (_isMatchingNakshatra(nameNakshatra, nakList[idx]['name']!)) {
        activeNakIdx = idx;
        break;
      }
    }

    final Color orange = AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: orange.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: orange.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [orange.withOpacity(0.85), const Color(0xFFFFCC80)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'नाम राशि ($name)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'घर $houseNum',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _detRow('राशि', '$nameRashiHindi ($nameRashiLordHindi)'),
                _detRow('नक्षत्र', nameNakshatra),
                _detRow('नक्षत्र स्वामी', nameNakshatraLord),
                _detRow('नामाक्षर', nameFirstLetter),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: orange.withOpacity(0.02),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$nameRashiHindi राशि के सभी नक्षत्र और नामाक्षर:',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                ...nakList.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  final isCurrent = idx == activeNakIdx;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCurrent ? orange.withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrent ? orange : Colors.grey.shade200,
                        width: isCurrent ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCurrent ? Icons.stars_rounded : Icons.radio_button_off_rounded,
                          color: isCurrent ? orange : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${item['name']} (${item['letters']}) — ${item['lord']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: isCurrent ? orange : Colors.black87,
                            ),
                          ),
                        ),
                        if (isCurrent)
                          Text(
                            'सक्रिय',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: orange),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension ColorBrightness on Color {
  Color darken([int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB(
      alpha,
      (red * f).round(),
      (green * f).round(),
      (blue * f).round(),
    );
  }
}
