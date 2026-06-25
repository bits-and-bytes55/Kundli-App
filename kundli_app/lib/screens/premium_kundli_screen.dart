import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/kundli_controller.dart';
import '../theme/app_theme.dart';
import '../theme/custom_shadows.dart';
import 'kundli/chart_tab.dart';
import 'kundli/planets_tab.dart';
import 'kundli/planets_sub_tab.dart';
import 'kundli/cusps_tab.dart';
import 'kundli/planet_signification_tab.dart';
import 'kundli/house_significators_tab.dart';
import 'kundli/kp_tab.dart';
import 'kundli/ashtakvarga_tab.dart';
import 'kundli/shad_bala_tab.dart';
import 'kundli/gochar_tab.dart';
import 'kundli/dasha_tab.dart';
import 'kundli/yoga_tab.dart';
import 'kundli/lal_kitab_tab.dart';
import 'kundli/personal_details_tab.dart';
import 'kundli/reports_tab.dart';
import 'kundli/varshphal_tab.dart';
import 'kundli/predictions_tab.dart';
import 'kundli/shodashvarga_tab.dart';
import 'kundli/graha_sthiti_tab.dart';
import 'kundli/avakahada_tab.dart';
import 'kundli/prastharashtakvarga_tab.dart';
import 'kundli/chalit_table_tab.dart';
import 'kundli/friendship_tab.dart';
import 'kundli/numerology_premium_section.dart';


class PremiumKundliScreen extends StatefulWidget {
  final int initialTabIdx;
  const PremiumKundliScreen({super.key, this.initialTabIdx = 0});

  @override
  State<PremiumKundliScreen> createState() => _PremiumKundliScreenState();
}

class _PremiumKundliScreenState extends State<PremiumKundliScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showLottie = true;

  final List<Tab> _tabs = const [
    Tab(text: 'Premium'),
    Tab(text: 'Basic'),
    Tab(text: 'Chart'),
    Tab(text: 'Graha Sthiti'),
    Tab(text: 'Planets'),
    Tab(text: 'Planets-Sub'),
    Tab(text: 'Cusps'),
    Tab(text: 'Planet Sig.'),
    Tab(text: 'House Sig.'),
    Tab(text: 'KP System'),
    Tab(text: 'Ashtakvarga'),
    Tab(text: 'Shad Bala'),
    Tab(text: 'Gochar'),
    Tab(text: 'Dasha'),
    Tab(text: 'Varshphal'),
    Tab(text: 'Avakahada'),
    Tab(text: 'Chalit Table'),
    Tab(text: 'Prasthara'),
    Tab(text: 'Friendship'),
    Tab(text: 'Yogas'),
    Tab(text: 'Shodashvarga'),
    Tab(text: 'Lal Kitab'),
    Tab(text: 'Predictions'),
    Tab(text: 'Reports'),
  ];

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
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: widget.initialTabIdx);
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _showLottie = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    final shodashvarga = data['shodashvarga'] as Map<String, dynamic>? ?? {};
    final avakahada   = data['avakahada']   as Map<String, dynamic>? ?? {};
    final planetSignificators = data['planet_significators'] as Map<String, dynamic>? ?? {};
    final houseSignificators = data['house_significators'] as Map<String, dynamic>? ?? {};
    final ashtakvarga = data['ashtakvarga'] as List<dynamic>? ?? [];
    final prastharaAshtakvarga = data['prasthara_ashtakavarga'] as Map<String, dynamic>? ?? {};
    final shadBala = data['shad_bala'] as Map<String, dynamic>? ?? {};
    final ghatak = data['ghatak'] as Map<String, dynamic>? ?? {};
    final favourable = data['favourable'] as Map<String, dynamic>? ?? {};
    final friendship = data['friendship'] as Map<String, dynamic>? ?? {};
    final chalitTable = data['chalit_table'] as List<dynamic>? ?? [];

    int lagnaIdx = rashiList.indexOf(ascendant['rashi'] ?? '');
    if (lagnaIdx == -1) lagnaIdx = 0;

    return Stack(
      children: [
        Scaffold(
          key: _scaffoldKey,
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
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.amber,
              indicatorWeight: 3,
              tabs: _tabs,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // 0 - Premium Tab (Everything that was previously the body)
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPremiumHeader(data),
                          const SizedBox(height: 12),
                          _buildMoonHouseSignCard(planets, lagnaIdx),
                          const SizedBox(height: 12),
                          _buildNameHouseSignCard(data['name'] ?? '', lagnaIdx, planets),
                          const SizedBox(height: 12),
                          _buildNameAnalysisCard(data['name'] ?? '', lagnaIdx, planets),
                          const SizedBox(height: 12),
                          NumerologyPremiumSection(
                            personalDetails: personalDetails,
                            name: data['name'] ?? '',
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 1 - Basic Details
              PersonalDetailsTab(personalDetails: personalDetails),
              // 2 - Chart
              ChartTab(ascendant: ascendant, planets: planets, kpAscendant: kpAscendant, kpPlanets: kpPlanets, showDirections: true),
              // 3 - Graha Sthiti
              GrahaSthitiTab(planets: planets, ascendant: ascendant),
              // 4 - Planets
              PlanetsTab(planets: planets, ascendant: ascendant),
              // 5 - Planets-Sub
              PlanetsSubTab(kpPlanets: kpPlanets, kpAscendant: kpAscendant),
              // 6 - Cusps
              CuspsTab(kpAscendant: kpAscendant),
              // 7 - Planet Sig.
              PlanetSignificationTab(planetSignificators: planetSignificators, kpPlanets: kpPlanets),
              // 8 - House Sig.
              HouseSignificatorsTab(houseSignificators: houseSignificators, kpPlanets: kpPlanets),
              // 9 - KP System
              KpTab(kpPlanets: kpPlanets, kpAscendant: kpAscendant),
              // 10 - Ashtakvarga
              AshtakvargaTab(ashtakvarga: ashtakvarga),
              // 11 - Shad Bala
              ShadBalaTab(shadBala: shadBala),
              // 12 - Gochar
              GocharTab(birthAscendant: ascendant, birthPlanets: planets),
              // 13 - Dasha
              DashaTab(dasha: dasha, charDasha: charDasha, yoginiDasha: yoginiDasha, mahadashaPhala: mahadashaPhala),
              // 14 - Varshphal
              const VarshphalTab(),
              // 15 - Avakahada
              AvakahadaTab(avakahada: avakahada, ascendant: ascendant, ghatak: ghatak, favourable: favourable),
              // 16 - Chalit Table
              ChalitTableTab(chalitTable: chalitTable),
              // 17 - Prasthara
              PrastharashtakvargaTab(prastharaAshtakvarga: prastharaAshtakvarga),
              // 18 - Friendship
              FriendshipTab(friendship: friendship),
              // 19 - Yogas
              YogaTab(yogas: yogas),
              // 20 - Shodashvarga
              ShodashvargaTab(shodashvarga: shodashvarga),
              // 21 - Lal Kitab
              LalKitabTab(lalKitab: lalKitab),
              // 22 - Predictions
              PredictionsTab(predictions: predictions),
              // 23 - Reports
              ReportsTab(doshas: doshas, numerology: numerology),
            ],
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

  // Widget _buildDirectionsSection(List<List<String>> planetsInRashis, int lagnaIdx) {
  //   return Card(
  //     elevation: 0,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(12),
  //       side: const BorderSide(color: Color(0xFFFFE0B2), width: 1.2),
  //     ),
  //     child: Theme(
  //       data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
  //       child: ExpansionTile(
  //         initiallyExpanded: true,
  //         leading: const Icon(Icons.explore_rounded, color: Colors.amber),
  //         title: const Text(
  //           '12 Directions & Astro-Vastu Analysis',
  //           style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black),
  //         ),
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const Text(
  //                   'Mapping of 12 Houses to Vastu directions and placement of planets:',
  //                   style: TextStyle(fontSize: 12, color: Color(0xFF555555), fontWeight: FontWeight.w500),
  //                 ),
  //                 const SizedBox(height: 16),
  //                 ListView.separated(
  //                   shrinkWrap: true,
  //                   physics: const NeverScrollableScrollPhysics(),
  //                   itemCount: 12,
  //                   separatorBuilder: (context, index) => const Divider(height: 24, color: AppColors.divider),
  //                   itemBuilder: (context, idx) {
  //                     final config = _directionConfigs[idx];
  //                     final planetsInDir = planetsInRashis[idx];
  //                     final directionColor = config['color'] as Color;
  //                     final int houseIdx = (idx - lagnaIdx + 12) % 12;
  //                     final int houseNum = houseIdx + 1;
  //                     final String houseSuffix = houseNum == 1 ? 'st' : houseNum == 2 ? 'nd' : houseNum == 3 ? 'rd' : 'th';

  //                     return Row(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Container(
  //                           padding: const EdgeInsets.all(10),
  //                           decoration: BoxDecoration(
  //                             color: directionColor.withOpacity(0.1),
  //                             shape: BoxShape.circle,
  //                           ),
  //                           child: Icon(config['icon'] as IconData, color: directionColor, size: 24),
  //                         ),
  //                         const SizedBox(width: 14),
  //                         Expanded(
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Row(
  //                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                                 children: [
  //                                   Expanded(
  //                                     child: Text(
  //                                       config['direction'] as String,
  //                                       style: TextStyle(
  //                                         fontSize: 15,
  //                                         fontWeight: FontWeight.w900,
  //                                         color: directionColor.darken(20),
  //                                       ),
  //                                       softWrap: true,
  //                                     ),
  //                                   ),
  //                                   const SizedBox(width: 8),
  //                                   Container(
  //                                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  //                                     decoration: BoxDecoration(
  //                                       color: Colors.amber.shade100,
  //                                       borderRadius: BorderRadius.circular(12),
  //                                     ),
  //                                     child: Text(
  //                                       '$houseNum$houseSuffix House (${config['rashi']})',
  //                                       style: TextStyle(
  //                                         fontSize: 11,
  //                                         fontWeight: FontWeight.bold,
  //                                         color: Colors.amber.shade900,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                               const SizedBox(height: 6),
  //                               Text(
  //                                 'Significance: ${config['significance']}',
  //                                 style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87),
  //                               ),
  //                               const SizedBox(height: 4),
  //                               Text(
  //                                 'Vastu Guideline: ${config['guideline']}',
  //                                 style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
  //                               ),
  //                               const SizedBox(height: 6),
  //                               Row(
  //                                 children: [
  //                                   const Text(
  //                                     'Planets Present: ',
  //                                     style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black),
  //                                   ),
  //                                   if (planetsInDir.isEmpty)
  //                                     const Text(
  //                                       'None (Clean & Stable Energy)',
  //                                       style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
  //                                     )
  //                                   else
  //                                     Wrap(
  //                                       spacing: 6,
  //                                       children: planetsInDir.map((p) {
  //                                         return Container(
  //                                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  //                                           decoration: BoxDecoration(
  //                                             color: Colors.orange.shade50,
  //                                             border: Border.all(color: Colors.orange.shade200),
  //                                             borderRadius: BorderRadius.circular(8),
  //                                           ),
  //                                           child: Text(
  //                                             p,
  //                                             style: TextStyle(
  //                                               fontSize: 10,
  //                                               fontWeight: FontWeight.bold,
  //                                               color: Colors.orange.shade900,
  //                                             ),
  //                                           ),
  //                                         );
  //                                       }).toList(),
  //                                     ),
  //                                 ],
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     );
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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

    // Use Name Rashi's default Nakshatra and Lord
    final nameNakshatra = details['nakshatra'] ?? '';
    final nameNakshatraLord = details['nakshatra_lord'] ?? '';

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

    // Name Rashi house in chart
    final naamRashiIdx = rashiList.indexOf(rashiName);

    // --- New Computations ---
    final nameRashiHouseNum = naamRashiIdx != -1 ? ((naamRashiIdx - lagnaIdx + 12) % 12 + 1) : 0;
    
    int moonHouseFromName = 0;
    if (planets['Moon'] != null) {
      String moonRashiStr = planets['Moon']['rashi'] ?? '';
      int moonRashiIdx = rashiList.indexWhere((r) => r.toLowerCase() == moonRashiStr.toLowerCase());
      if (moonRashiIdx != -1 && naamRashiIdx != -1) {
        moonHouseFromName = ((naamRashiIdx - moonRashiIdx + 12) % 12) + 1;
      }
    }

    Set<int> rashiSignified = {};
    if (details['lord'] != null && details['lord']!.isNotEmpty) {
      String lord = details['lord']!.split(' ').first;
      final ownership = {
        'Sun': [4], 'Moon': [3], 'Mars': [0, 7], 'Mercury': [2, 5],
        'Jupiter': [8, 11], 'Venus': [1, 6], 'Saturn': [9, 10]
      };
      for (int rIdx in (ownership[lord] ?? [])) {
        rashiSignified.add(((rIdx - lagnaIdx + 12) % 12) + 1);
      }
      if (planets[lord] != null && planets[lord]['house'] != null) {
        rashiSignified.add(planets[lord]['house'] as int);
      }
    }
    
    Set<int> nakSignified = {};
    if (nameNakshatraLord.isNotEmpty) {
      String nLord = nameNakshatraLord;
      final ownership = {
        'Sun': [4], 'Moon': [3], 'Mars': [0, 7], 'Mercury': [2, 5],
        'Jupiter': [8, 11], 'Venus': [1, 6], 'Saturn': [9, 10]
      };
      for (int rIdx in (ownership[nLord] ?? [])) {
        nakSignified.add(((rIdx - lagnaIdx + 12) % 12) + 1);
      }
      if (planets[nLord] != null && planets[nLord]['house'] != null) {
        nakSignified.add(planets[nLord]['house'] as int);
      }
    }
    
    String rashiStr = "-";
    if (rashiSignified.isNotEmpty) {
      var l = rashiSignified.toList()..sort();
      rashiStr = l.join(', ');
    }

    String nakStr = "-";
    if (nakSignified.isNotEmpty) {
      var l = nakSignified.toList()..sort();
      nakStr = l.join(', ');
    }
    
    Set<int> totalActiveSet = {};
    if (nameRashiHouseNum > 0) totalActiveSet.add(nameRashiHouseNum);
    if (moonHouseFromName > 0) totalActiveSet.add(moonHouseFromName);
    totalActiveSet.addAll(rashiSignified);
    totalActiveSet.addAll(nakSignified);
    
    List<int> sortedActive = totalActiveSet.toList()..sort();

    final Map<String, String> engToHindi = {
      'A': 'अ / आ', 'B': 'ब / भ', 'C': 'च / छ', 'D': 'द / ड', 'E': 'ए',
      'F': 'फ', 'G': 'ग / घ', 'H': 'ह', 'I': 'इ / ई', 'J': 'ज / झ',
      'K': 'क / ख', 'L': 'ल', 'M': 'म', 'N': 'न', 'O': 'ओ',
      'P': 'प', 'Q': 'क़', 'R': 'र', 'S': 'स / श', 'T': 'त / ट',
      'U': 'उ / ऊ', 'V': 'व', 'W': 'व', 'X': 'क्स', 'Y': 'य', 'Z': 'ज़'
    };
    String firstLetter = name.trim().isNotEmpty ? name.trim().substring(0, 1).toUpperCase() : '';
    String hindiLetter = engToHindi[firstLetter] ?? '';
    String nameDisplay = name + (hindiLetter.isNotEmpty ? ' ($firstLetter / $hindiLetter)' : '');

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
                  'Name Astrology & Active Houses',
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


        // Simple List without Card background
        Column(
          children: [
            _buildSimpleRow('Active Name Analyzed', nameDisplay, valueColor: const Color(0xFFE07B20)),
            _buildSimpleRow('Naam Rashi (Name Sign)', details['rashi'] ?? '', valueColor: rashiColor),
            _buildSimpleRow('Rashi Lord (Sign Ruler)', details['lord'] ?? '', valueColor: rashiColor.darken(15)),
            _buildSimpleRow('Naam Nakshatra', nameNakshatra),
            _buildSimpleRow('Nakshatra Lord', nameNakshatraLord),
            
            // New Fields
            _buildSimpleRow('लग्न से नाम किस भाव में है', '${nameRashiHouseNum > 0 ? nameRashiHouseNum : "-"}वाँ भाव'),
            _buildSimpleRow('चंद्र से नाम किस भाव में है', '${moonHouseFromName > 0 ? moonHouseFromName : "-"}वाँ भाव'),
            _buildSimpleRow('नाम राशि से Signified Houses', rashiStr),
            _buildSimpleRow('नाम नक्षत्र से Signified Houses', nakStr),
            _buildSimpleRow('Total Active Houses', sortedActive.isNotEmpty ? '${sortedActive.join(', ')} ✔️' : '-', valueColor: Colors.green.shade700, isLast: true),
          ],
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
                'Your birth chart moon sign governs your inner self, while your active name "$name" represents your social vibration. Your name vibrates with ${details['rashi']} energy. The active houses influence your destiny and aura in profound ways.',
                style: const TextStyle(
                  fontSize: 11,
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

  Widget _buildSimpleRow(String label, String value, {Color? valueColor, bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: valueColor ?? Colors.black87,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, thickness: 0.5, color: Colors.orange.shade200),
      ],
    );
  }

  Map<String, String> _calculateNaamRashiDetails(String name) {
    if (name.isEmpty) return {};
    String firstLetter = name.trim().substring(0, 1).toUpperCase();
    
    final Map<String, Map<String, String>> letterMapping = {
      'A': {'rashi': 'Mesh (Aries)', 'lord': 'Mars (Mangal)', 'nakshatra': 'Krittika', 'nakshatra_lord': 'Sun'},
      'L': {'rashi': 'Mesh (Aries)', 'lord': 'Mars (Mangal)', 'nakshatra': 'Ashwini', 'nakshatra_lord': 'Ketu'},
      'E': {'rashi': 'Mesh (Aries)', 'lord': 'Mars (Mangal)', 'nakshatra': 'Krittika', 'nakshatra_lord': 'Sun'},
      'I': {'rashi': 'Mesh (Aries)', 'lord': 'Mars (Mangal)', 'nakshatra': 'Krittika', 'nakshatra_lord': 'Sun'},
      
      'B': {'rashi': 'Vrishabh (Taurus)', 'lord': 'Venus (Shukra)', 'nakshatra': 'Rohini', 'nakshatra_lord': 'Moon'},
      'V': {'rashi': 'Vrishabh (Taurus)', 'lord': 'Venus (Shukra)', 'nakshatra': 'Rohini', 'nakshatra_lord': 'Moon'},
      'U': {'rashi': 'Vrishabh (Taurus)', 'lord': 'Venus (Shukra)', 'nakshatra': 'Krittika', 'nakshatra_lord': 'Sun'},
      'O': {'rashi': 'Vrishabh (Taurus)', 'lord': 'Venus (Shukra)', 'nakshatra': 'Rohini', 'nakshatra_lord': 'Moon'},
      
      'K': {'rashi': 'Mithun (Gemini)', 'lord': 'Mercury (Budh)', 'nakshatra': 'Ardra', 'nakshatra_lord': 'Rahu'},
      'G': {'rashi': 'Mithun (Gemini)', 'lord': 'Mercury (Budh)', 'nakshatra': 'Ardra', 'nakshatra_lord': 'Rahu'},
      'C': {'rashi': 'Mithun (Gemini)', 'lord': 'Mercury (Budh)', 'nakshatra': 'Punarvasu', 'nakshatra_lord': 'Jupiter'},
      'H': {'rashi': 'Mithun (Gemini)', 'lord': 'Mercury (Budh)', 'nakshatra': 'Punarvasu', 'nakshatra_lord': 'Jupiter'},
      
      'D': {'rashi': 'Kark (Cancer)', 'lord': 'Moon (Chandra)', 'nakshatra': 'Ashlesha', 'nakshatra_lord': 'Mercury'},
      
      'M': {'rashi': 'Singh (Leo)', 'lord': 'Sun (Surya)', 'nakshatra': 'Magha', 'nakshatra_lord': 'Ketu'},
      'T': {'rashi': 'Singh (Leo)', 'lord': 'Sun (Surya)', 'nakshatra': 'Purvaphalguni', 'nakshatra_lord': 'Venus'},
      
      'P': {'rashi': 'Kanya (Virgo)', 'lord': 'Mercury (Budh)', 'nakshatra': 'Uttaraphalguni', 'nakshatra_lord': 'Sun'},
      'S': {'rashi': 'Kanya (Virgo)', 'lord': 'Mercury (Budh)', 'nakshatra': 'Hasta', 'nakshatra_lord': 'Moon'},
      
      'R': {'rashi': 'Tula (Libra)', 'lord': 'Venus (Shukra)', 'nakshatra': 'Swati', 'nakshatra_lord': 'Rahu'},
      
      'N': {'rashi': 'Vrischik (Scorpio)', 'lord': 'Mars (Mangal)', 'nakshatra': 'Anuradha', 'nakshatra_lord': 'Saturn'},
      'Y': {'rashi': 'Vrischik (Scorpio)', 'lord': 'Mars (Mangal)', 'nakshatra': 'Jyeshtha', 'nakshatra_lord': 'Mercury'},
      
      'F': {'rashi': 'Dhanu (Sagittarius)', 'lord': 'Jupiter (Guru)', 'nakshatra': 'Purvashadha', 'nakshatra_lord': 'Venus'},
      'W': {'rashi': 'Dhanu (Sagittarius)', 'lord': 'Jupiter (Guru)', 'nakshatra': 'Purvashadha', 'nakshatra_lord': 'Venus'},
      
      'J': {'rashi': 'Makar (Capricorn)', 'lord': 'Saturn (Shani)', 'nakshatra': 'Uttarashadha', 'nakshatra_lord': 'Sun'},
      
      'Z': {'rashi': 'Kumbh (Aquarius)', 'lord': 'Saturn (Shani)', 'nakshatra': 'Shatabhisha', 'nakshatra_lord': 'Rahu'},
      'X': {'rashi': 'Kumbh (Aquarius)', 'lord': 'Saturn (Shani)', 'nakshatra': 'Shatabhisha', 'nakshatra_lord': 'Rahu'},
    };

    if (letterMapping.containsKey(firstLetter)) {
      return letterMapping[firstLetter]!;
    }

    return {
      'rashi': 'Meen (Pisces)',
      'lord': 'Jupiter (Guru)',
      'nakshatra': 'Revati',
      'nakshatra_lord': 'Mercury',
    };
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
    
    if (normalizedEng.contains('purvaphalguni') || normalizedEng.contains('pphalguni')) {
      if (normalizedHindi.contains('पूर्वाफाल्गुनी')) return true;
    }
    if (normalizedEng.contains('uttaraphalguni') || normalizedEng.contains('uphalguni')) {
      if (normalizedHindi.contains('उत्तराफाल्गुनी')) return true;
    }
    if (normalizedEng.contains('purvashadha') || normalizedEng.contains('pashadha')) {
      if (normalizedHindi.contains('पूर्वाषाढ़ा')) return true;
    }
    if (normalizedEng.contains('uttarashadha') || normalizedEng.contains('uashadha')) {
      if (normalizedHindi.contains('उत्तराषाढ़ा')) return true;
    }
    if (normalizedEng.contains('purvabhadrapada') || normalizedEng.contains('pbhadra')) {
      if (normalizedHindi.contains('पूर्वाभाद्रपद')) return true;
    }
    if (normalizedEng.contains('uttarabhadrapada') || normalizedEng.contains('ubhadra')) {
      if (normalizedHindi.contains('उत्तराभाद्रपद')) return true;
    }
    if (normalizedEng.contains('moola') && normalizedHindi.contains('मूल')) return true;
    if (normalizedEng.contains('swati') && normalizedHindi.contains('स्वाती')) return true;
    if (normalizedEng.contains('vishakha') && normalizedHindi.contains('विशाखा')) return true;

    final Map<String, String> translation = {
      'ashwini': 'अश्विनी', 'bharani': 'भरणी', 'krittika': 'कृत्तिका',
      'rohini': 'रोहिणी', 'mrigashira': 'मृगशिरा', 'ardra': 'आर्द्रा',
      'punarvasu': 'पुनर्वसु', 'pushya': 'पुष्य', 'ashlesha': 'आश्लेषा',
      'magha': 'मघा', 'hasta': 'हस्त', 'chitra': 'चित्रा',
      'anuradha': 'अनुराधा', 'jyeshtha': 'ज्येष्ठा', 'shravana': 'श्रवण',
      'dhanishtha': 'धनिष्ठा', 'shatabhisha': 'शतभिषा', 'revati': 'रेवती',
      'swati': 'स्वाती', 'moola': 'मूल', 'vishakha': 'विशाखा',
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
    // Use Name Rashi's default Nakshatra and Lord
    final nameNakshatra = details['nakshatra'] ?? '';
    final nameNakshatraLord = details['nakshatra_lord'] ?? '';
    
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
