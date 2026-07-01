import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import '../controllers/kundli_controller.dart';
import '../theme/app_theme.dart';
import '../utils/namakshar_mapping.dart';
import '../theme/custom_shadows.dart';
import 'kundli/chart_tab.dart';
import 'kundli/planets_tab.dart';
import 'kundli/planets_sub_tab.dart';
import 'kundli/cusps_tab.dart';
import 'kundli/planet_signification_tab.dart';
import 'kundli/house_significators_tab.dart';
import 'kundli/kp_tab.dart';
import 'kundli/direction_match_screen.dart';
import 'kundli/planet_hits_tab.dart';
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


import 'dart:io';

class PremiumKundliScreen extends StatefulWidget {
  final int initialTabIdx;
  final File? signatureImage;
  final Map<String, String>? savedDirectionParams;
  const PremiumKundliScreen({super.key, this.initialTabIdx = 0, this.signatureImage, this.savedDirectionParams});

  @override
  State<PremiumKundliScreen> createState() => _PremiumKundliScreenState();
}

class _PremiumKundliScreenState extends State<PremiumKundliScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showLottie = true;
  
  Map<String, dynamic>? _homeDirectionData;
  
  final TextEditingController _signatureNameController = TextEditingController();
  final TextEditingController _signatureTotalController = TextEditingController();
  final TextEditingController _signaturePredictionController = TextEditingController();
  String _savedSignatureName = '';
  String _savedSignatureTotal = '';
  String _savedSignaturePrediction = '';
  final ScreenshotController _screenshotController = ScreenshotController();

  final List<Tab> _tabs = [
    Tab(text: 'premium'.tr),
    Tab(text: 'basic'.tr),
    Tab(text: '12_rashi'.tr),
    Tab(text: 'direction_prediction'.tr),
    Tab(text: Get.locale?.languageCode == 'hi' ? 'ग्रह हिट' : 'Planet Hit'),
    Tab(text: 'graha_sthiti'.tr),
    Tab(text: 'planets'.tr),
    Tab(text: 'planets_sub'.tr),
    Tab(text: 'cusps'.tr),
    Tab(text: 'planet_sig'.tr),
    Tab(text: 'house_sig'.tr),
    Tab(text: 'kp_system'.tr),
    Tab(text: 'ashtakvarga'.tr),
    Tab(text: 'shad_bala'.tr),
    Tab(text: 'gochar'.tr),
    Tab(text: 'dasha'.tr),
    Tab(text: 'varshphal'.tr),
    Tab(text: 'avakahada'.tr),
    Tab(text: 'chalit_table'.tr),
    Tab(text: 'prasthara'.tr),
    Tab(text: 'friendship'.tr),
    Tab(text: 'yogas'.tr),
    Tab(text: 'shodashvarga'.tr),
    Tab(text: 'lal_kitab'.tr),
    Tab(text: 'predictions'.tr),
    Tab(text: 'reports'.tr),
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
    _signatureNameController.dispose();
    _signatureTotalController.dispose();
    _signaturePredictionController.dispose();
    super.dispose();
  }

  Future<void> _shareAsPdf() async {
    final pdf = pw.Document();
    final image = await _screenshotController.capture();
    if (image != null) {
      pdf.addPage(pw.Page(build: (pw.Context context) {
        return pw.Center(child: pw.Image(pw.MemoryImage(image)));
      }));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/kundli.pdf');
      await file.writeAsBytes(await pdf.save());
      await Share.shareXFiles([XFile(file.path)], text: 'Kundli Report');
    }
  }

  Widget _buildExaltedDebilitatedNote(Map<String, dynamic> planets) {
    List<String> uchchPlanets = [];
    List<String> neechPlanets = [];

    final rules = {
      'Sun': {'uchch': 1, 'neech': 7, 'hindi': 'सूर्य'},
      'Moon': {'uchch': 2, 'neech': 8, 'hindi': 'चन्द्र'},
      'Mars': {'uchch': 10, 'neech': 4, 'hindi': 'मंगल'},
      'Mercury': {'uchch': 6, 'neech': 12, 'hindi': 'बुध'},
      'Jupiter': {'uchch': 4, 'neech': 10, 'hindi': 'गुरु'},
      'Venus': {'uchch': 12, 'neech': 6, 'hindi': 'शुक्र'},
      'Saturn': {'uchch': 7, 'neech': 1, 'hindi': 'शनि'},
      'Rahu': {'uchch': 2, 'neech': 8, 'hindi': 'राहु'},
      'Ketu': {'uchch': 8, 'neech': 2, 'hindi': 'केतु'},
    };

    planets.forEach((key, data) {
      if (rules.containsKey(key)) {
        int rashiNum = data['rashi_num'] ?? 1;
        if (rashiNum == rules[key]!['uchch']) {
          uchchPlanets.add(rules[key]!['hindi'] as String);
        } else if (rashiNum == rules[key]!['neech']) {
          neechPlanets.add(rules[key]!['hindi'] as String);
        }
      }
    });

    if (uchchPlanets.isEmpty && neechPlanets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade400, width: 1.5),
        boxShadow: CustomShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                'ग्रहों की स्थिति (उच्च / नीच)',
                style: TextStyle(
                  color: Colors.amber.shade900,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          if (uchchPlanets.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.arrow_upward_rounded, color: Colors.green.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      children: [
                        const TextSpan(text: 'आपकी कुण्डली में ', style: TextStyle(fontWeight: FontWeight.w600)),
                        TextSpan(
                          text: uchchPlanets.join(', '),
                          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.green.shade800),
                        ),
                        const TextSpan(text: ' ग्रह उच्च (Exalted) राशि में स्थित हैं, जो अत्यंत शुभ परिणाम देने में सक्षम हैं।'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          if (uchchPlanets.isNotEmpty && neechPlanets.isNotEmpty)
            const SizedBox(height: 12),
          if (neechPlanets.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.arrow_downward_rounded, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      children: [
                        const TextSpan(text: 'आपकी कुण्डली में ', style: TextStyle(fontWeight: FontWeight.w600)),
                        TextSpan(
                          text: neechPlanets.join(', '),
                          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.red.shade800),
                        ),
                        const TextSpan(text: ' ग्रह नीच (Debilitated) राशि में स्थित हैं। इसके प्रभाव स्वरूप कुछ चुनौतियाँ आ सकती हैं।'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
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

    final String name = data['name'] ?? '';
    final nameDetails = _calculateNaamRashiDetails(name);
    final String rashiFullName = nameDetails['rashi'] ?? '';
    final String rashiShortName = rashiFullName.isNotEmpty ? rashiFullName.split(' ').first : '';
    final int naamRashiIdx = rashiList.indexOf(rashiShortName);

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
                icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.amber),
                onPressed: _shareAsPdf,
                tooltip: 'Download PDF',
              ),
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
              // 0 - Premium Tab
              Screenshot(
                controller: _screenshotController,
                child: SingleChildScrollView(
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
                          ashtakvarga: ashtakvarga,
                          targetHouseCrossIdx: _homeDirectionData?['house'],
                          isTargetDirectionBad: _homeDirectionData != null 
                            ? (_homeDirectionData!['lagnaCount'] == 8 || _homeDirectionData!['moonCount'] == 8 || _homeDirectionData!['nameCount'] == 8) 
                            : false,
                        ),
                      ),
                      if (_homeDirectionData == null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await showDialog<Map<String, dynamic>>(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => DirectionPredictionDialog(
                                  birthPlace: personalDetails['place'] ?? data['place'] ?? '',
                                  lagnaHouse: lagnaIdx + 1,
                                  moonHouse: planets['Moon']?['rashi_num'] ?? 1,
                                  nameRashiHouse: naamRashiIdx != -1 ? naamRashiIdx + 1 : 1,
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  _homeDirectionData = result;
                                });
                              }
                            },
                            icon: const Icon(Icons.explore_rounded, color: Colors.white),
                            label: const Text('Know Direction Prediction', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(Icons.explore_rounded, color: AppColors.primary),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Direction: ${_homeDirectionData!['name']}',
                                              style: TextStyle(
                                                fontSize: 16, 
                                                fontWeight: (_homeDirectionData!['name'].toString().contains('WNW') || _homeDirectionData!['name'].toString().contains('ESE')) ? FontWeight.w900 : FontWeight.bold,
                                                color: (_homeDirectionData!['name'].toString().contains('WNW') || _homeDirectionData!['name'].toString().contains('ESE')) ? Colors.red : Colors.black87
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.grey),
                                      onPressed: () => setState(() => _homeDirectionData = null),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                _buildResultRow('लग्न (Ascendant)', _homeDirectionData!['lagnaCount']),
                                _buildResultRow('चंद्र (Moon Sign)', _homeDirectionData!['moonCount']),
                                _buildResultRow('नाम राशि (${data['name'] ?? ''})', _homeDirectionData!['nameCount']),
                                if (_homeDirectionData!['name'].toString().contains('WNW') || _homeDirectionData!['name'].toString().contains('ESE')) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.red.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded, color: Colors.red.shade800),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Note: ${_homeDirectionData!['name']} is considered a generally bad direction. It is not good.',
                                            style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                              ],
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPremiumHeader(data),
                          const SizedBox(height: 12),
                          _buildMoonHouseSignCard(planets, lagnaIdx, planetSignificators),
                          const SizedBox(height: 12),
                          _buildExaltedDebilitatedNote(planets),
                          const SizedBox(height: 12),
                          _buildNameHouseSignCard(data['name'] ?? '', lagnaIdx, planets),
                          const SizedBox(height: 12),
                          _buildNameAnalysisCard(data['name'] ?? '', lagnaIdx, planets, planetSignificators),
                          const SizedBox(height: 12),
                          NumerologyPremiumSection(
                            personalDetails: personalDetails,
                            name: data['name'] ?? '',
                            dob: data['date'] ?? '',
                            deathData: c.deathKundliData.value,
                          ),
                          const SizedBox(height: 12),
                          _buildDeathDetailsCard(c),
                          const SizedBox(height: 12),
                          _buildSignatureDetailsCard(data['name'] ?? ''),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ),
              // 1 - Basic Details
              PersonalDetailsTab(personalDetails: personalDetails, name: data['name'] ?? ''),
              // 2 - 12 Rashi
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                child: _buildAll12Rashis(data['name'] ?? '', lagnaIdx, planets, planetSignificators),
              ),
              // 3 - Direction Prediction
              DirectionMatchScreen(
                birthPlace: personalDetails['place'] ?? data['place'] ?? '',
                lagnaHouse: lagnaIdx + 1,
                moonHouse: planets['Moon']?['rashi_num'] ?? 1,
                nameRashiHouse: naamRashiIdx != -1 ? naamRashiIdx + 1 : 1,
                name: name,
                ascendant: ascendant,
                planets: planets,
                kpAscendant: kpAscendant,
                kpPlanets: kpPlanets,
                savedParams: widget.savedDirectionParams,
              ),
              // 4 - Planet Hit
              PlanetHitsTab(planets: planets, kpAscendant: kpAscendant),
              // 5 - Graha Sthiti
              GrahaSthitiTab(planets: planets, ascendant: ascendant),
              // 6 - Planets
              PlanetsTab(planets: planets, ascendant: ascendant),
              // 7 - Planets-Sub
              PlanetsSubTab(kpPlanets: kpPlanets, kpAscendant: kpAscendant),
              // 8 - Cusps
              CuspsTab(kpAscendant: kpAscendant),
              // 8 - Planet Sig.
              PlanetSignificationTab(planetSignificators: planetSignificators, kpPlanets: kpPlanets),
              // 9 - House Sig.
              HouseSignificatorsTab(houseSignificators: houseSignificators, kpPlanets: kpPlanets),
              // 10 - KP System
              KpTab(kpPlanets: kpPlanets, kpAscendant: kpAscendant),
              // 11 - Ashtakvarga
              AshtakvargaTab(ashtakvarga: ashtakvarga),
              // 12 - Shad Bala
              ShadBalaTab(shadBala: shadBala),
              // 13 - Gochar
              GocharTab(birthAscendant: ascendant, birthPlanets: planets),
              // 14 - Dasha
              DashaTab(dasha: dasha, charDasha: charDasha, yoginiDasha: yoginiDasha, mahadashaPhala: mahadashaPhala),
              // 15 - Varshphal
              const VarshphalTab(),
              // 16 - Avakahada
              AvakahadaTab(avakahada: avakahada, ascendant: ascendant, ghatak: ghatak, favourable: favourable),
              // 17 - Chalit Table
              ChalitTableTab(chalitTable: chalitTable),
              // 18 - Prasthara
              PrastharashtakvargaTab(prastharaAshtakvarga: prastharaAshtakvarga),
              // 19 - Friendship
              FriendshipTab(friendship: friendship),
              // 20 - Yogas
              YogaTab(yogas: yogas),
              // 21 - Shodashvarga
              ShodashvargaTab(shodashvarga: shodashvarga),
              // 22 - Lal Kitab
              LalKitabTab(lalKitab: lalKitab),
              // 23 - Predictions
              PredictionsTab(predictions: predictions),
              // 24 - Reports
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

  Widget _buildResultRow(String title, int count) {
    bool isBad = count == 8;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBad ? Colors.red.shade50 : Colors.green.shade50,
        border: Border.all(color: isBad ? Colors.red.shade200 : Colors.green.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Icon(
                isBad ? Icons.cancel_rounded : Icons.check_circle_rounded,
                color: isBad ? Colors.red : Colors.green,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isBad 
              ? 'यह दिशा $title से 8वें भाव में आ रही है, इसलिए यह आपके लिए अनुकूल नहीं है।'
              : 'यह दिशा $title से ${count}वें भाव में है, जो कि अनुकूल है।',
            style: TextStyle(color: isBad ? Colors.red.shade800 : Colors.green.shade800, fontSize: 12),
          ),
        ],
      ),
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

  Widget _buildNameAnalysisCard(String name, int lagnaIdx, Map<String, dynamic> planets, [Map<String, dynamic>? planetSignificators]) {
    if (name.isEmpty) return const SizedBox();
    final details = _calculateNaamRashiDetails(name);
    if (details.isEmpty) return const SizedBox();

    final nameNakshatra = details['nakshatra'] ?? '';
    final nameNakshatraLord = details['nakshatra_lord'] ?? '';

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

    final naamRashiIdx = rashiList.indexOf(rashiName);
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
      var sigData = planetSignificators?[lord] ?? planetSignificators?[lord.toLowerCase()];
      if (sigData is Map && sigData.containsKey('planet_houses')) {
         List<dynamic> sigs = sigData['planet_houses'];
         rashiSignified.addAll(sigs.map((e) => int.parse(e.toString())));
      } else {
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
    }
    
    String rashiStr = "-";
    if (rashiSignified.isNotEmpty) {
      var l = rashiSignified.toList()..sort();
      rashiStr = l.join(', ');
    }
    
    Set<int> nakSignified = {};
    String nakLordEng = _getNakshatraLordEng(nameNakshatraLord);
    if (nakLordEng.isNotEmpty) {
      var sigData = planetSignificators?[nakLordEng] ?? planetSignificators?[nakLordEng.toLowerCase()];
      if (sigData is Map && sigData.containsKey('planet_houses')) {
         List<dynamic> sigs = sigData['planet_houses'];
         nakSignified.addAll(sigs.map((e) => int.parse(e.toString())));
      } else {
        final ownership = {
          'Sun': [4], 'Moon': [3], 'Mars': [0, 7], 'Mercury': [2, 5],
          'Jupiter': [8, 11], 'Venus': [1, 6], 'Saturn': [9, 10]
        };
        for (int rIdx in (ownership[nakLordEng] ?? [])) {
          nakSignified.add(((rIdx - lagnaIdx + 12) % 12) + 1);
        }
        if (planets[nakLordEng] != null && planets[nakLordEng]['house'] != null) {
          nakSignified.add(planets[nakLordEng]['house'] as int);
        }
      }
    }
    
    String nakStr = "-";
    if (nakSignified.isNotEmpty) {
      var l = nakSignified.toList()..sort();
      nakStr = l.join(', ');
    }
    
    Map<int, int> houseFreq = {};
    if (nameRashiHouseNum > 0) houseFreq[nameRashiHouseNum] = (houseFreq[nameRashiHouseNum] ?? 0) + 1;
    if (moonHouseFromName > 0) houseFreq[moonHouseFromName] = (houseFreq[moonHouseFromName] ?? 0) + 1;
    for (int h in rashiSignified) {
      houseFreq[h] = (houseFreq[h] ?? 0) + 1;
    }
    for (int h in nakSignified) {
      houseFreq[h] = (houseFreq[h] ?? 0) + 1;
    }
    
    List<int> sortedActive = houseFreq.keys.toList()..sort();
    
    List<TextSpan> spans = [];
    if (sortedActive.isEmpty) {
      spans.add(const TextSpan(text: '-'));
    } else {
      for (int i = 0; i < sortedActive.length; i++) {
        int h = sortedActive[i];
        int count = houseFreq[h] ?? 1;
        
        Color textColor = (h == 8 || h == 12) ? Colors.red.shade700 : Colors.green.shade800;

        spans.add(TextSpan(
          text: '$h',
          style: TextStyle(
            fontWeight: count > 1 ? FontWeight.w900 : FontWeight.w600,
            fontSize: count > 1 ? 15 : 13,
            color: textColor,
          ),
        ));
        if (i < sortedActive.length - 1) {
          spans.add(TextSpan(
            text: ', ', 
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey.shade600)
          ));
        }
      }
      
      bool has8 = sortedActive.contains(8);
      spans.add(TextSpan(
        text: has8 ? ' ❌' : ' ✔️', 
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: has8 ? Colors.red.shade700 : Colors.green.shade700)
      ));
    }
    
    Widget totalActiveWidget = RichText(
      textAlign: TextAlign.right,
      text: TextSpan(children: spans),
    );

    final Map<String, String> engToHindi = {
      'A': 'अ / आ', 'B': 'ब / भ', 'C': 'च / छ', 'D': 'द / ड', 'E': 'ए',
      'F': 'फ', 'G': 'ग / घ', 'H': 'ह', 'I': 'इ / ई', 'J': 'ज / झ',
      'K': 'क / ख', 'L': 'ल', 'M': 'म', 'N': 'न', 'O': 'ओ',
      'P': 'प', 'Q': 'क़', 'R': 'र', 'S': 'स / श', 'T': 'त / ट',
      'U': 'उ / ऊ', 'V': 'व', 'W': 'व', 'X': 'क्स', 'Y': 'य', 'Z': 'ज़'
    };
    
    String activeEng = '';
    String hindiLetter = '';
    String upperName = name.trim().toUpperCase();
    
    for (int len = 4; len >= 1; len--) {
      if (upperName.length >= len) {
        String prefix = upperName.substring(0, len);
        if (NamaksharMapping.padaMap.containsKey(prefix)) {
          activeEng = prefix;
          hindiLetter = NamaksharMapping.padaMap[prefix]!['hindi']!;
          break;
        }
      }
    }

    if (activeEng.isEmpty) {
      String firstLetter = upperName.isNotEmpty ? upperName.substring(0, 1) : '';
      activeEng = firstLetter;
      hindiLetter = engToHindi[firstLetter] ?? '';
    }
    
    String nameDisplay = name;
    if (activeEng.isNotEmpty) {
      String formattedEng = activeEng[0] + (activeEng.length > 1 ? activeEng.substring(1).toLowerCase() : '');
      nameDisplay += ' ($formattedEng' + (hindiLetter.isNotEmpty ? ' / $hindiLetter' : '') + ')';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        Column(
          children: [
            _buildSimpleRow('Active Name Analyzed', nameDisplay, valueColor: const Color(0xFFE07B20)),
            _buildSimpleRow('लग्न से नाम किस भाव में है', '${nameRashiHouseNum > 0 ? nameRashiHouseNum : "-"}वाँ भाव'),
            _buildSimpleRow('name_from_moon'.tr, '${moonHouseFromName > 0 ? moonHouseFromName : "-"}वाँ भाव'),
            _buildSimpleRow('name_rashi_signified'.tr, rashiStr),
            _buildSimpleRow('name_nak_signified'.tr, nakStr),
            _buildSimpleRow('total_active_houses'.tr, '', customValueWidget: totalActiveWidget, isLast: true),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSimpleRow(String label, String value, {Color? valueColor, bool isLast = false, Widget? customValueWidget}) {
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
                child: customValueWidget ?? Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
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
    if (name.trim().isEmpty) return {};
    String upperName = name.trim().toUpperCase();
    
    for (int len = 4; len >= 1; len--) {
      if (upperName.length >= len) {
        String prefix = upperName.substring(0, len);
        if (NamaksharMapping.padaMap.containsKey(prefix)) {
          return NamaksharMapping.padaMap[prefix]!;
        }
      }
    }
    
    String firstLetter = upperName.substring(0, 1);
    
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
      {'name': 'कृत्तिका 1 चरण', 'letters': 'अ, [आ, अं]', 'lord': 'सूर्य'},
    ],
    'Vrishabh': [
      {'name': 'कृत्तिका 3 चरण', 'letters': 'ई, उ, ए, [ऊ, ऐ]', 'lord': 'सूर्य'},
      {'name': 'रोहिणी', 'letters': 'ओ, वा, वी, वू, [औ, बा, बी, बू]', 'lord': 'चंद्र'},
      {'name': 'मृगशिरा 2 चरण', 'letters': 'वे, वो, [बे, बो]', 'lord': 'मंगल'},
    ],
    'Mithun': [
      {'name': 'मृगशिरा 2 चरण', 'letters': 'का, की', 'lord': 'मंगल'},
      {'name': 'आर्द्रा', 'letters': 'कू, घ, ङ, छ, [क्ष]', 'lord': 'राहु'},
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
      {'name': 'चित्रा 2 चरण', 'letters': 'रा, री, [ऋ]', 'lord': 'मंगल'},
      {'name': 'स्वाती', 'letters': 'रू, रे, रो, ता, [त्र, त्रा]', 'lord': 'राहु'},
      {'name': 'विशाखा 3 चरण', 'letters': 'ती, तू, ते, [त्रि, त्री, त्रे]', 'lord': 'गुरु'},
    ],
    'Vrischik': [
      {'name': 'विशाखा 1 चरण', 'letters': 'तो, [त्रो]', 'lord': 'गुरु'},
      {'name': 'अनुराधा', 'letters': 'ना, नी, नू, ने', 'lord': 'शनि'},
      {'name': 'ज्येष्ठा', 'letters': 'नो, या, यी, यू', 'lord': 'बुध'},
    ],
    'Dhanu': [
      {'name': 'मूल', 'letters': 'ये, यो, भा, भी', 'lord': 'केतु'},
      {'name': 'पूर्वाषाढ़ा', 'letters': 'भू, धा, फा, ढा, [धी, धू, फ़ा]', 'lord': 'शुक्र'},
      {'name': 'उत्तराषाढ़ा 1 चरण', 'letters': 'भे', 'lord': 'सूर्य'},
    ],
    'Makar': [
      {'name': 'उत्तराषाढ़ा 3 चरण', 'letters': 'भो, जा, जी', 'lord': 'सूर्य'},
      {'name': 'श्रवण', 'letters': 'खी, खू, खे, खो', 'lord': 'चंद्र'},
      {'name': 'धनिष्ठा 2 चरण', 'letters': 'गा, गी, [ज्ञ, ज्ञा, ज्ञी]', 'lord': 'मंगल'},
    ],
    'Kumbh': [
      {'name': 'धनिष्ठा 2 चरण', 'letters': 'गू, गे', 'lord': 'मंगल'},
      {'name': 'शतभिषा', 'letters': 'गो, सा, सी, सू, [शा, शी, शू, श, श्र, श्रा, श्री, श्रि, श्रे, श्रु, श्रो]', 'lord': 'राहु'},
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

  Widget _buildMoonHouseSignCard(Map<String, dynamic> planets, int lagnaIdx, [Map<String, dynamic>? planetSignificators]) {
    final chandra = planets['Moon'] as Map<String, dynamic>?;
    if (chandra == null) return const SizedBox();

    final moonRashi = chandra['rashi'] as String? ?? 'Mesh';
    final moonRashiHindi = rashiHindi[moonRashi] ?? moonRashi;
    final moonRashiLordHindi = rashiLordsHindi[moonRashi] ?? '';
    final rashiLordEng = _getRashiLordEng(moonRashi);
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
    
    int moonHouse = chandra['house'] as int? ?? 1;
    
    Set<int> rashiSignified = {};
    if (rashiLordEng.isNotEmpty) {
      var sigData = planetSignificators?[rashiLordEng] ?? planetSignificators?[rashiLordEng.toLowerCase()];
      if (sigData is Map && sigData.containsKey('planet_houses')) {
         List<dynamic> sigs = sigData['planet_houses'];
         rashiSignified.addAll(sigs.map((e) => int.parse(e.toString())));
      } else {
        final ownership = {
          'Sun': [4], 'Moon': [3], 'Mars': [0, 7], 'Mercury': [2, 5],
          'Jupiter': [8, 11], 'Venus': [1, 6], 'Saturn': [9, 10]
        };
        for (int rIdx in (ownership[rashiLordEng] ?? [])) {
          rashiSignified.add(((rIdx - lagnaIdx + 12) % 12) + 1);
        }
        if (planets[rashiLordEng] != null && planets[rashiLordEng]['house'] != null) {
          rashiSignified.add(planets[rashiLordEng]['house'] as int);
        }
      }
    }
    
    String rashiStr = "-";
    if (rashiSignified.isNotEmpty) {
      var l = rashiSignified.toList()..sort();
      rashiStr = l.join(', ');
    }

    Widget _colorRow(String label, String value, Color color) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600)),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13)),
          ],
        ),
      );
    }

    Widget card = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, const Color(0xFFFFF8F0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade400, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFFF8C00), const Color(0xFFFF3D00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.nights_stay_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'moon_title'.tr,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Text(
                    '${'house'.tr} ${chandra['house'] ?? '-'}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _colorRow('rashi'.tr, '$moonRashiHindi ($moonRashiLordHindi)', Colors.blue.shade700),
                _colorRow('nakshatra'.tr, '$moonNakshatra पद $moonPada', Colors.purple.shade700),
                _colorRow('nakshatra_lord'.tr, chandra['nakshatra_lord'] ?? '-', Colors.teal.shade700),
                _colorRow('namakshar'.tr, moonFirstLetter, Colors.red.shade700),
                _colorRow('degree'.tr, _formatDegree(chandra['degree']), Colors.orange.shade800),
                _colorRow('speed'.tr, '${(chandra['speed'] as num? ?? 0).toStringAsFixed(4)}°/day', Colors.indigo.shade600),
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
                  '$moonRashiHindi ${'rashi_all_nakshatras_namakshar'.tr}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                ...nakList.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  final isCurrent = idx == activeNakIdx;
                  
                  String nLord = item['lord']!;
                  String nLordEng = _getNakshatraLordEng(nLord);
                  
                  Set<int> nakSignified = {};
                  if (nLordEng.isNotEmpty) {
                    var sigData = planetSignificators?[nLordEng] ?? planetSignificators?[nLordEng.toLowerCase()];
                    if (sigData is Map && sigData.containsKey('planet_houses')) {
                      List<dynamic> sigs = sigData['planet_houses'];
                      nakSignified.addAll(sigs.map((e) => int.parse(e.toString())));
                    } else {
                      final ownership = {
                        'Sun': [4], 'Moon': [3], 'Mars': [0, 7], 'Mercury': [2, 5],
                        'Jupiter': [8, 11], 'Venus': [1, 6], 'Saturn': [9, 10]
                      };
                      for (int rIdx in (ownership[nLordEng] ?? [])) {
                        nakSignified.add(((rIdx - lagnaIdx + 12) % 12) + 1);
                      }
                      if (planets[nLordEng] != null && planets[nLordEng]['house'] != null) {
                        nakSignified.add(planets[nLordEng]['house'] as int);
                      }
                    }
                  }
                  
                  String nakStr = "-";
                  if (nakSignified.isNotEmpty) {
                    var l = nakSignified.toList()..sort();
                    nakStr = l.join(', ');
                  }
                  
                  Map<int, int> houseFreq = {};
                  houseFreq[moonHouse] = (houseFreq[moonHouse] ?? 0) + 1;
                  houseFreq[1] = (houseFreq[1] ?? 0) + 1;
                  for (int h in rashiSignified) houseFreq[h] = (houseFreq[h] ?? 0) + 1;
                  for (int h in nakSignified) houseFreq[h] = (houseFreq[h] ?? 0) + 1;
                  
                  List<int> sortedActive = houseFreq.keys.toList()..sort();
                  List<TextSpan> spans = [];
                  if (sortedActive.isEmpty) {
                    spans.add(const TextSpan(text: '-'));
                  } else {
                    for (int i = 0; i < sortedActive.length; i++) {
                      int h = sortedActive[i];
                      int count = houseFreq[h] ?? 1;
                      Color textColor = (h == 8 || h == 12) ? Colors.red.shade700 : Colors.green.shade800;
                      spans.add(TextSpan(
                        text: '$h',
                        style: TextStyle(
                          fontWeight: count > 1 ? FontWeight.w900 : FontWeight.w600,
                          fontSize: count > 1 ? 15 : 13,
                          color: textColor,
                        ),
                      ));
                      if (i < sortedActive.length - 1) {
                        spans.add(TextSpan(
                          text: ', ', 
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey.shade600)
                        ));
                      }
                    }
                    bool has8 = sortedActive.contains(8);
                    spans.add(TextSpan(
                      text: has8 ? ' ❌' : ' ✔️', 
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: has8 ? Colors.red.shade700 : Colors.green.shade700)
                    ));
                  }
                  
                  Widget totalActiveWidget = RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(children: spans),
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isCurrent ? const Color(0xFFFFF0E0) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCurrent ? Colors.orange.shade500 : Colors.grey.shade200,
                        width: isCurrent ? 2.0 : 1.0,
                      ),
                      boxShadow: isCurrent ? [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ] : [],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCurrent ? Icons.stars_rounded : Icons.radio_button_off_rounded,
                              color: isCurrent ? Colors.orange.shade700 : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${item['name']} (${item['letters']}) — ${item['lord']}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isCurrent ? FontWeight.w900 : FontWeight.normal,
                                  color: isCurrent ? Colors.orange.shade900 : Colors.black87,
                                ),
                              ),
                            ),
                            if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'active'.tr,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                                ),
                              ),
                          ],
                        ),
                        if (isCurrent) ...[
                          const SizedBox(height: 12),
                          _buildSimpleRow('moon_from_lagna'.tr, '${moonHouse > 0 ? moonHouse : "-"}${'th_house'.tr}'),
                          _buildSimpleRow('moon_from_moon'.tr, '1${'th_house'.tr}'),
                          _buildSimpleRow('moon_rashi_signified'.tr, rashiStr),
                          _buildSimpleRow('moon_nak_signified'.tr, nakStr),
                          _buildSimpleRow('total_active_houses'.tr, '', customValueWidget: totalActiveWidget, isLast: true),
                        ]
                      ]
                    )
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
    
    return card;
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
    
    String nameFirstLetter = '';
    String hindiLetter = '';
    String upperName = name.trim().toUpperCase();
    
    for (int len = 4; len >= 1; len--) {
      if (upperName.length >= len) {
        String prefix = upperName.substring(0, len);
        if (NamaksharMapping.padaMap.containsKey(prefix)) {
          nameFirstLetter = prefix;
          hindiLetter = NamaksharMapping.padaMap[prefix]!['hindi']!;
          break;
        }
      }
    }

    if (nameFirstLetter.isEmpty) {
      nameFirstLetter = upperName.isNotEmpty ? upperName.substring(0, 1) : '';
      final Map<String, String> engToHindi = {
        'A': 'अ / आ', 'B': 'ब / भ', 'C': 'च / छ', 'D': 'द / ड', 'E': 'ए',
        'F': 'फ', 'G': 'ग / घ', 'H': 'ह', 'I': 'इ / ई', 'J': 'ज / झ',
        'K': 'क / ख', 'L': 'ल', 'M': 'म', 'N': 'न', 'O': 'ओ',
        'P': 'प', 'Q': 'क़', 'R': 'र', 'S': 'स / श', 'T': 'त / ट',
        'U': 'उ / ऊ', 'V': 'व', 'W': 'व', 'X': 'क्स', 'Y': 'य', 'Z': 'ज़'
      };
      hindiLetter = engToHindi[nameFirstLetter] ?? '';
    }

    String displayLetter = nameFirstLetter;
    if (nameFirstLetter.isNotEmpty) {
       displayLetter = nameFirstLetter[0] + (nameFirstLetter.length > 1 ? nameFirstLetter.substring(1).toLowerCase() : '');
       if (hindiLetter.isNotEmpty) {
         displayLetter += ' / $hindiLetter';
       }
    }
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
                _detRow('नामाक्षर', displayLetter),
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
                  '$nameRashiHindi ${'rashi_all_nakshatras_namakshar'.tr}',
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
                            'active'.tr,
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
  Widget _buildDeathDetailsCard(KundliController c) {
    final deathData = c.deathKundliData.value;
    if (deathData == null) return const SizedBox();

    final planets = deathData['planets'] as Map<String, dynamic>? ?? {};
    final ascendant = deathData['ascendant'] as Map<String, dynamic>? ?? {};
    final moonRashi = planets['Moon']?['rashi'] ?? '';
    final moonNak = planets['Moon']?['nakshatra'] ?? '';
    final moonNakLord = planets['Moon']?['nakshatra_lord'] ?? '';
    final lagnaRashi = ascendant['rashi'] ?? '';

    return _buildSectionCard(
      title: 'Death Details & Analysis',
      icon: Icons.auto_awesome_rounded,
      isExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSimpleRow('Date of Death', deathData['date'] ?? ''),
          _buildSimpleRow('Time of Death', deathData['time'] ?? ''),
          _buildSimpleRow('Place of Death', deathData['place'] ?? ''),
          _buildSimpleRow('Death Lagna (Ascendant)', lagnaRashi, valueColor: Colors.deepPurple),
          _buildSimpleRow('Death Moon Sign (Rashi)', moonRashi, valueColor: Colors.blue.shade800),
          _buildSimpleRow('Death Nakshatra', moonNak, valueColor: Colors.amber.shade900),
          _buildSimpleRow('Nakshatra Lord', moonNakLord, isLast: true),
        ],
      ),
    );
  }

  Widget _buildSignatureDetailsCard(String defaultName) {
    if (widget.signatureImage == null) return const SizedBox();

    String currentSignatureName = _savedSignatureName.isNotEmpty ? _savedSignatureName : defaultName;

    final Map<String, int> chaldeanMap = {
      'A':1,'I':1,'J':1,'Q':1,'Y':1,
      'B':2,'K':2,'R':2,
      'C':3,'G':3,'L':3,'S':3,
      'D':4,'M':4,'T':4,
      'E':5,'H':5,'N':5,'X':5,
      'U':6,'V':6,'W':6,
      'O':7,'Z':7,
      'F':8,'P':8
    };

    int total = 0;
    String cleaned = currentSignatureName.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    for (int i = 0; i < cleaned.length; i++) {
      if (chaldeanMap.containsKey(cleaned[i])) {
        total += chaldeanMap[cleaned[i]]!;
      }
    }
    int reduceToSingleDigit(int n) {
      if (n == 0) return 0;
      int res = n % 9;
      return res == 0 ? 9 : res;
    }
    int singleDigit = reduceToSingleDigit(total);

    return _buildSectionCard(
      title: 'Signature Analysis',
      icon: Icons.draw_rounded,
      isExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(widget.signatureImage!, height: 100, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _signatureNameController,
            decoration: InputDecoration(
              labelText: 'Signature Name',
              hintText: 'Enter name in signature',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _signatureTotalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Total Letters',
              hintText: 'Enter total number of letters',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _signaturePredictionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Signature Prediction',
              hintText: 'Enter detailed signature prediction...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _savedSignatureName = _signatureNameController.text.trim();
                _savedSignatureTotal = _signatureTotalController.text.trim();
                _savedSignaturePrediction = _signaturePredictionController.text.trim();
              });
              Get.snackbar('Saved', 'Signature analysis saved successfully', backgroundColor: Colors.green.shade100, snackPosition: SnackPosition.BOTTOM);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save Signature Prediction', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          if (_savedSignatureName.isNotEmpty || _savedSignatureTotal.isNotEmpty || _savedSignaturePrediction.isNotEmpty) ...[
            const Divider(height: 32),
            if (_savedSignatureName.isNotEmpty) _buildSimpleRow('Signature Name', _savedSignatureName),
            if (_savedSignatureName.isNotEmpty) _buildSimpleRow('Chaldean Total', '$total = $singleDigit', valueColor: Colors.green.shade800),
            if (_savedSignatureTotal.isNotEmpty) _buildSimpleRow('Total Letters', _savedSignatureTotal),
            if (_savedSignaturePrediction.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Prediction:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
                child: Text(_savedSignaturePrediction, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5)),
              ),
            ]
          ],
        ],
      ),
    );
  }

  Widget _buildAll12Rashis(String userName, int lagnaIdx, Map<String, dynamic> planets, Map<String, dynamic> planetSignificators) {
    if (userName.isEmpty) return const SizedBox();
    
    // Find the user's name nakshatra to highlight it
    final details = _calculateNaamRashiDetails(userName);
    final userNakshatra = details['nakshatra'] ?? '';
    final userNakshatraLord = details['nakshatra_lord'] ?? '';

    List<Widget> rashiWidgets = [];
    
    rashiWidgets.add(
      const Padding(
        padding: EdgeInsets.only(top: 12, bottom: 12),
        child: Text(
          'All 12 Rashis & Active Houses Analysis',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
      )
    );

    for (String rashi in rashiList) {
      rashiWidgets.add(_buildSingleRashiAnalysis(rashi, userNakshatra, userNakshatraLord, lagnaIdx, planets, planetSignificators));
      rashiWidgets.add(const SizedBox(height: 16));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rashiWidgets,
    );
  }

  Widget _buildSingleRashiAnalysis(String rashiName, String userNakshatra, String userNakshatraLord, int lagnaIdx, Map<String, dynamic> planets, Map<String, dynamic> planetSignificators) {
    final rashiHindiName = rashiHindi[rashiName] ?? rashiName;
    final rashiLord = rashiLordsHindi[rashiName] ?? '';
    final rashiLordEng = _getRashiLordEng(rashiName); 
    
    final rashiIdx = rashiList.indexOf(rashiName);
    final houseNum = (rashiIdx - lagnaIdx + 12) % 12 + 1;
    
    final nakList = rashiNakshatras[rashiName] ?? [];
    int activeNakIdx = -1;
    if (userNakshatra.isNotEmpty) {
      for (int idx = 0; idx < nakList.length; idx++) {
        if (_isMatchingNakshatra(userNakshatra, nakList[idx]['name']!)) {
          activeNakIdx = idx;
          break;
        }
      }
    }
    
    final Color orange = AppColors.primary;
    
    Widget card = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: orange.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [orange.withOpacity(0.85), const Color(0xFFFFCC80)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$rashiHindiName ($rashiLord)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'घर $houseNum',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            color: orange.withOpacity(0.02),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$rashiHindiName ${'rashi_all_nakshatras_namakshar'.tr}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                ...nakList.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  final isCurrent = idx == activeNakIdx;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCurrent ? orange.withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(6),
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
                            'active'.tr,
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
    
    int moonHouseFromName = 0;
    if (planets['Moon'] != null) {
      String moonRashiStr = planets['Moon']['rashi'] ?? '';
      int moonRashiIdx = rashiList.indexWhere((r) => r.toLowerCase() == moonRashiStr.toLowerCase());
      if (moonRashiIdx != -1) {
        moonHouseFromName = ((rashiIdx - moonRashiIdx + 12) % 12) + 1;
      }
    }
    
    Set<int> rashiSignified = {};
    if (rashiLordEng.isNotEmpty) {
      var sigData = planetSignificators?[rashiLordEng] ?? planetSignificators?[rashiLordEng.toLowerCase()];
      if (sigData is Map && sigData.containsKey('planet_houses')) {
         List<dynamic> sigs = sigData['planet_houses'];
         rashiSignified.addAll(sigs.map((e) => int.parse(e.toString())));
      } else {
        final ownership = {
          'Sun': [4], 'Moon': [3], 'Mars': [0, 7], 'Mercury': [2, 5],
          'Jupiter': [8, 11], 'Venus': [1, 6], 'Saturn': [9, 10]
        };
        for (int rIdx in (ownership[rashiLordEng] ?? [])) {
          rashiSignified.add(((rIdx - lagnaIdx + 12) % 12) + 1);
        }
        if (planets[rashiLordEng] != null && planets[rashiLordEng]['house'] != null) {
          rashiSignified.add(planets[rashiLordEng]['house'] as int);
        }
      }
    }
    
    String rashiStr = "-";
    if (rashiSignified.isNotEmpty) {
      var l = rashiSignified.toList()..sort();
      rashiStr = l.join(', ');
    }
    
    Widget dropdown = _buildSectionCard(
      title: '$rashiHindiName Active Houses & Significations',
      icon: Icons.analytics_rounded,
      isExpanded: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSimpleRow('लग्न से राशि किस भाव में है', '${houseNum > 0 ? houseNum : "-"}वाँ भाव'),
          _buildSimpleRow('चंद्र से राशि किस भाव में है', '${moonHouseFromName > 0 ? moonHouseFromName : "-"}वाँ भाव'),
          _buildSimpleRow('राशि से Signified Houses', rashiStr),
          const SizedBox(height: 16),
          const Text('नक्षत्र Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
          const SizedBox(height: 12),
          ...nakList.asMap().entries.map((entry) {
            final item = entry.value;
            String nLord = item['lord']!;
            String nLordEng = _getNakshatraLordEng(nLord);
            
            Set<int> nakSignified = {};
            if (nLordEng.isNotEmpty) {
              var sigData = planetSignificators?[nLordEng] ?? planetSignificators?[nLordEng.toLowerCase()];
              if (sigData is Map && sigData.containsKey('planet_houses')) {
                List<dynamic> sigs = sigData['planet_houses'];
                nakSignified.addAll(sigs.map((e) => int.parse(e.toString())));
              } else {
                final ownership = {
                  'Sun': [4], 'Moon': [3], 'Mars': [0, 7], 'Mercury': [2, 5],
                  'Jupiter': [8, 11], 'Venus': [1, 6], 'Saturn': [9, 10]
                };
                for (int rIdx in (ownership[nLordEng] ?? [])) {
                  nakSignified.add(((rIdx - lagnaIdx + 12) % 12) + 1);
                }
                if (planets[nLordEng] != null && planets[nLordEng]['house'] != null) {
                  nakSignified.add(planets[nLordEng]['house'] as int);
                }
              }
            }
            
            String nakStr = "-";
            if (nakSignified.isNotEmpty) {
              var l = nakSignified.toList()..sort();
              nakStr = l.join(', ');
            }
            
            Map<int, int> houseFreq = {};
            if (houseNum > 0) houseFreq[houseNum] = (houseFreq[houseNum] ?? 0) + 1;
            if (moonHouseFromName > 0) houseFreq[moonHouseFromName] = (houseFreq[moonHouseFromName] ?? 0) + 1;
            for (int h in rashiSignified) houseFreq[h] = (houseFreq[h] ?? 0) + 1;
            for (int h in nakSignified) houseFreq[h] = (houseFreq[h] ?? 0) + 1;
            
            List<int> sortedActive = houseFreq.keys.toList()..sort();
            List<TextSpan> spans = [];
            if (sortedActive.isEmpty) {
              spans.add(const TextSpan(text: '-'));
            } else {
              for (int i = 0; i < sortedActive.length; i++) {
                int h = sortedActive[i];
                int count = houseFreq[h] ?? 1;
                Color textColor = (h == 8 || h == 12) ? Colors.red.shade700 : Colors.green.shade800;
                spans.add(TextSpan(
                  text: '$h',
                  style: TextStyle(
                    fontWeight: count > 1 ? FontWeight.w900 : FontWeight.w600,
                    fontSize: count > 1 ? 15 : 13,
                    color: textColor,
                  ),
                ));
                if (i < sortedActive.length - 1) {
                  spans.add(TextSpan(
                    text: ', ', 
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey.shade600)
                  ));
                }
              }
              bool has8 = sortedActive.contains(8);
              spans.add(TextSpan(
                text: has8 ? ' ❌' : ' ✔️', 
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: has8 ? Colors.red.shade700 : Colors.green.shade700)
              ));
            }
            
            Widget totalActiveWidget = RichText(
              textAlign: TextAlign.right,
              text: TextSpan(children: spans),
            );
            
            bool isCurrent = false;
            if (userNakshatra.isNotEmpty) {
               isCurrent = _isMatchingNakshatra(userNakshatra, item['name']!);
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrent ? orange.withOpacity(0.06) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isCurrent ? orange.withOpacity(0.5) : Colors.grey.shade200, width: isCurrent ? 1.5 : 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(isCurrent ? Icons.stars_rounded : Icons.lens, size: 14, color: isCurrent ? orange : Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${item['name']} (${item['letters']}) — ${item['lord']}',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isCurrent ? orange.darken() : Colors.black87),
                        ),
                      ),
                      if (isCurrent)
                        Text(
                          'active'.tr,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: orange),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildSimpleRow('name_from_lagna'.tr, '${houseNum > 0 ? houseNum : "-"}वाँ भाव'),
                  _buildSimpleRow('name_from_moon'.tr, '${moonHouseFromName > 0 ? moonHouseFromName : "-"}वाँ भाव'),
                  _buildSimpleRow('name_rashi_signified'.tr, rashiStr),
                  _buildSimpleRow('name_nak_signified'.tr, nakStr),
                  _buildSimpleRow('total_active_houses'.tr, '', customValueWidget: totalActiveWidget, isLast: true),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        card,
        const SizedBox(height: 8),
        dropdown,
      ],
    );
  }

  String _getRashiLordEng(String rashi) {
    switch (rashi) {
      case 'Mesh': case 'Vrischik': return 'Mars';
      case 'Vrishabh': case 'Tula': return 'Venus';
      case 'Mithun': case 'Kanya': return 'Mercury';
      case 'Kark': return 'Moon';
      case 'Singh': return 'Sun';
      case 'Dhanu': case 'Meen': return 'Jupiter';
      case 'Makar': case 'Kumbh': return 'Saturn';
      default: return '';
    }
  }

  String _getNakshatraLordEng(String hindiLord) {
    switch (hindiLord) {
      case 'सूर्य': case 'Sun': return 'Sun';
      case 'चंद्र': case 'चन्द्र': case 'Moon': return 'Moon';
      case 'मंगल': case 'Mars': return 'Mars';
      case 'बुध': case 'Mercury': return 'Mercury';
      case 'गुरु': case 'Jupiter': return 'Jupiter';
      case 'शुक्र': case 'Venus': return 'Venus';
      case 'शनि': case 'Saturn': return 'Saturn';
      case 'राहु': case 'Rahu': return 'Rahu';
      case 'केतु': case 'Ketu': return 'Ketu';
      default: return '';
    }
  }
}

class DirectionPredictionDialog extends StatefulWidget {
  final String birthPlace;
  final int lagnaHouse, moonHouse, nameRashiHouse;
  const DirectionPredictionDialog({super.key, required this.birthPlace, required this.lagnaHouse, required this.moonHouse, required this.nameRashiHouse});
  @override
  State<DirectionPredictionDialog> createState() => _DirectionPredictionDialogState();
}

class _DirectionPredictionDialogState extends State<DirectionPredictionDialog> {
  final TextEditingController _birthPlaceController = TextEditingController();
  final TextEditingController _currentPlaceController1 = TextEditingController();
  final TextEditingController _residencePlaceController = TextEditingController();
  final TextEditingController _currentPlaceController2 = TextEditingController();
  
  bool _isLoading = false;
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _birthPlaceController.text = widget.birthPlace;
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentPlaceController1.text = prefs.getString('dp_current_place_1') ?? '';
        _residencePlaceController.text = prefs.getString('dp_residence_place') ?? '';
        _currentPlaceController2.text = prefs.getString('dp_current_place_2') ?? '';
        String savedBirth = prefs.getString('dp_birth_place') ?? '';
        if (savedBirth.isNotEmpty) {
          _birthPlaceController.text = savedBirth;
        }
      });
    }
  }

  Future<Iterable<String>> _getPlaces(String query) async {
    if (query.isEmpty || query.length < 2) return const [];
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&limit=5&addressdetails=1');
    try {
      final response = await http.get(url, headers: {'User-Agent': 'kundli_app_suggestion'});
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((p) => p['display_name'] as String).toList();
      }
    } catch (e) {
      print('Error fetching places: $e');
    }
    return const [];
  }

  Widget _buildPlaceAutocomplete(TextEditingController controller, String label, String hint) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text == '') return const Iterable<String>.empty();
        return await _getPlaces(textEditingValue.text);
      },
      onSelected: (String selection) { controller.text = selection; },
      fieldViewBuilder: (context, fieldController, focusNode, onEditingComplete) {
        if (fieldController.text != controller.text) fieldController.text = controller.text;
        fieldController.addListener(() { controller.text = fieldController.text; });
        return TextField(
          controller: fieldController, focusNode: focusNode, onEditingComplete: onEditingComplete,
          decoration: InputDecoration(labelText: label, hintText: hint, isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0, borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 96,
              child: ListView.builder(
                padding: EdgeInsets.zero, shrinkWrap: true, itemCount: options.length,
                itemBuilder: (context, index) {
                  final String option = options.elementAt(index);
                  return ListTile(title: Text(option, style: const TextStyle(fontSize: 13)), onTap: () => onSelected(option));
                },
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    double rLat1 = lat1 * math.pi / 180.0;
    double rLat2 = lat2 * math.pi / 180.0;
    double dLon = (lon2 - lon1) * math.pi / 180.0;
    double y = math.sin(dLon) * math.cos(rLat2);
    double x = math.cos(rLat1) * math.sin(rLat2) - math.sin(rLat1) * math.cos(rLat2) * math.cos(dLon);
    double brng = math.atan2(y, x);
    return (brng * 180.0 / math.pi + 360.0) % 360.0;
  }

  Map<String, dynamic> _mapBearingToHouseData(double angle) {
    int zone = ((angle + 11.25) / 22.5).floor() % 16;
    String dirName = ''; int dirHouse = 1;
    switch (zone) {
      case 0: dirName = 'North (N)'; dirHouse = 6; break;
      case 1: dirName = 'North-North-East (NNE)'; dirHouse = 4; break;
      case 2: dirName = 'North-East (NE)'; dirHouse = 9; break;
      case 3: dirName = 'East-North-East (ENE)'; dirHouse = 5; break;
      case 4: dirName = 'East (E)'; dirHouse = 1; break;
      case 5: dirName = 'East-South-East (ESE)'; dirHouse = 12; break;
      case 6: dirName = 'South-East (SE)'; dirHouse = 12; break;
      case 7: dirName = 'South-South-East (SSE)'; dirHouse = 10; break;
      case 8: dirName = 'South (S)'; dirHouse = 10; break;
      case 9: dirName = 'South-South-West (SSW)'; dirHouse = 8; break;
      case 10: dirName = 'South-West (SW)'; dirHouse = 8; break;
      case 11: dirName = 'West-South-West (WSW)'; dirHouse = 7; break;
      case 12: dirName = 'West (W)'; dirHouse = 11; break;
      case 13: dirName = 'West-North-West (WNW)'; dirHouse = 2; break;
      case 14: dirName = 'North-West (NW)'; dirHouse = 2; break;
      case 15: dirName = 'North-North-West (NNW)'; dirHouse = 3; break;
    }
    int lagnaCount = ((dirHouse - widget.lagnaHouse + 12) % 12) + 1;
    int moonCount = ((dirHouse - widget.moonHouse + 12) % 12) + 1;
    int nameCount = ((dirHouse - widget.nameRashiHouse + 12) % 12) + 1;
    return { 'name': dirName, 'house': dirHouse, 'lagnaCount': lagnaCount, 'moonCount': moonCount, 'nameCount': nameCount };
  }

  Future<void> _submit() async {
    final current1 = _currentPlaceController1.text.trim();
    final residence = _residencePlaceController.text.trim();
    final current2 = _currentPlaceController2.text.trim();
    final birth = _birthPlaceController.text.trim();

    if ((birth.isEmpty || current1.isEmpty) && (residence.isEmpty || current2.isEmpty)) {
      Get.snackbar('Error', 'Please fill at least one form completely', backgroundColor: Colors.red.shade100);
      return;
    }

    setState(() => _isLoading = true);
    try {
      String src = '';
      String tgt = '';
      
      // Prioritize Form 1 if filled, otherwise Form 2
      if (birth.isNotEmpty && current1.isNotEmpty) {
        src = birth;
        tgt = current1;
      } else {
        src = residence;
        tgt = current2;
      }

      List<Location> srcLocs = await locationFromAddress(src);
      List<Location> tgtLocs = await locationFromAddress(tgt);

      if (srcLocs.isEmpty || tgtLocs.isEmpty) throw Exception("Location not found");

      double bearing = _calculateBearing(srcLocs.first.latitude, srcLocs.first.longitude, tgtLocs.first.latitude, tgtLocs.first.longitude);
      final data = _mapBearingToHouseData(bearing);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dp_current_place_1', current1);
      await prefs.setString('dp_residence_place', residence);
      await prefs.setString('dp_current_place_2', current2);
      await prefs.setString('dp_birth_place', birth);

      if (mounted) Navigator.pop(context, data);
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Direction Prediction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Form 1
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.orange.shade200, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Form 1: From Birth Place', style: TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      _buildPlaceAutocomplete(_birthPlaceController, 'Birth Place', 'Enter birth city'),
                      const SizedBox(height: 12),
                      _buildPlaceAutocomplete(_currentPlaceController1, 'Current Place', 'Enter current city'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Form 2
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.orange.shade200, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Form 2: From Residence', style: TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      _buildPlaceAutocomplete(_residencePlaceController, 'Residence Location', 'Enter residence city'),
                      const SizedBox(height: 12),
                      _buildPlaceAutocomplete(_currentPlaceController2, 'Current Place', 'Enter current city'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE65100), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Check Direction Match', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
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
