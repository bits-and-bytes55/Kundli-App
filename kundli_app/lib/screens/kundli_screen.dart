import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kundli_controller.dart';
import '../theme/app_theme.dart';
import 'kundli/dasha_tab.dart';
import 'kundli/yoga_tab.dart';
import 'kundli/lal_kitab_tab.dart';
import 'kundli/chart_tab.dart';
import 'kundli/planets_tab.dart';
import 'kundli/planets_sub_tab.dart';
import 'kundli/cusps_tab.dart';
import 'kundli/planet_signification_tab.dart';
import 'kundli/house_significators_tab.dart';
import 'kundli/reports_tab.dart';
import 'kundli/shodashvarga_tab.dart';
import 'kundli/graha_sthiti_tab.dart';
import 'kundli/avakahada_tab.dart';
import 'kundli/gochar_tab.dart';
import 'kundli/kp_tab.dart';
import 'kundli/ashtakvarga_tab.dart';
import 'kundli/prastharashtakvarga_tab.dart';
import 'kundli/shad_bala_tab.dart';

class KundliScreen extends StatefulWidget {
  final int initialTabIdx;
  const KundliScreen({super.key, this.initialTabIdx = 0});
  @override
  State<KundliScreen> createState() => _KundliScreenState();
}

class _KundliScreenState extends State<KundliScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Tab> _tabs = const [
    Tab(text: 'Chart'),
    Tab(text: 'Planets'),
    Tab(text: 'Planets-Sub'),
    Tab(text: 'Cusps'),
    Tab(text: 'Planet Sig.'),
    Tab(text: 'House Sig.'),
    Tab(text: 'Ashtakvarga'),
    Tab(text: 'Prasthara'),
    Tab(text: 'Shad Bala'),
    Tab(text: 'Graha Sthiti'),
    Tab(text: 'KP System'),
    Tab(text: 'Avakahada'),
    Tab(text: 'Gochar'),
    Tab(text: 'Dasha'),
    Tab(text: 'Yogas'),
    Tab(text: 'Shodashvarga'),
    Tab(text: 'Lal Kitab'),
    Tab(text: 'Reports'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: widget.initialTabIdx);
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<KundliController>();
    final data = c.kundliData.value;
    if (data == null) {
      return Scaffold(appBar: AppBar(title: const Text('Kundli')),
        body: const Center(child: Text('No data available')));
    }
    final planets   = data['planets']   as Map<String, dynamic>;
    final ascendant = data['ascendant'];
    final kpPlanets   = data['kp_planets']   as Map<String, dynamic>? ?? planets;
    final kpAscendant = data['kp_ascendant'] ?? ascendant;
    final dasha     = data['dasha']     as List<dynamic>? ?? [];
    final yogas     = data['yogas']     as List<dynamic>? ?? [];
    final doshas    = data['doshas']    as Map<String, dynamic>? ?? {};
    final numerology  = data['numerology']  as Map<String, dynamic>? ?? {};
    final lalKitab    = data['lal_kitab']   as Map<String, dynamic>? ?? {};
    final shodashvarga = data['shodashvarga'] as Map<String, dynamic>? ?? {};
    final avakahada   = data['avakahada']   as Map<String, dynamic>? ?? {};
    final planetSignificators = data['planet_significators'] as Map<String, dynamic>? ?? {};
    final houseSignificators = data['house_significators'] as Map<String, dynamic>? ?? {};
    final ashtakvarga = data['ashtakvarga'] as List<dynamic>? ?? [];
    final prastharaAshtakvarga = data['prasthara_ashtakavarga'] as Map<String, dynamic>? ?? {};
    final shadBala = data['shad_bala'] as Map<String, dynamic>? ?? {};

    return Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        key: _scaffoldKey,
        drawer: _buildDrawer(data['name'] ?? ''),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
            onPressed: () => _scaffoldKey.currentState?.openDrawer()),
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data['name'] ?? '', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
            Text('${data['date']} • ${ascendant['rashi']} Lagna', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
          ]),
          actions: [IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary), onPressed: () => Get.back())],
          bottom: TabBar(
            controller: _tabController, isScrollable: true,
            labelColor: AppColors.primary, unselectedLabelColor: AppColors.textLight,
            indicatorColor: AppColors.primary, indicatorWeight: 3,
            tabs: _tabs,
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await c.fetchKundli(
              data['name'] ?? '',
              data['date'] ?? '',
              data['time'] ?? '',
              (data['lat'] as num?)?.toDouble() ?? 28.6139,
              (data['lon'] as num?)?.toDouble() ?? 77.2090,
              gender: data['gender'] ?? 'Male',
            );
          },
          color: AppColors.primary,
          child: TabBarView(controller: _tabController, children: [
            // 0 - Chart
            ChartTab(ascendant: ascendant, planets: planets, kpAscendant: kpAscendant, kpPlanets: kpPlanets),
            // 1 - Planets (AstroSage style)
            PlanetsTab(planets: planets, ascendant: ascendant),
            // 2 - Planets-Sub (KP SL/NL/SB/SS)
            PlanetsSubTab(kpPlanets: kpPlanets, kpAscendant: kpAscendant),
            // 3 - Cusps
            CuspsTab(kpAscendant: kpAscendant),
            // 4 - Planet Signification
            PlanetSignificationTab(planetSignificators: planetSignificators),
            // 5 - House Significators
            HouseSignificatorsTab(houseSignificators: houseSignificators, kpPlanets: kpPlanets),
            // 6 - Ashtakvarga SAV
            AshtakvargaTab(ashtakvarga: ashtakvarga),
            // 7 - Prastharashtakvarga PAT
            PrastharashtakvargaTab(prastharaAshtakvarga: prastharaAshtakvarga),
            // 8 - Shad Bala & Bhav Bala
            ShadBalaTab(shadBala: shadBala),
            // 9 - Graha Sthiti
            GrahaSthitiTab(planets: planets, ascendant: ascendant),
            // 10 - KP System
            KpTab(kpPlanets: kpPlanets, kpAscendant: kpAscendant),
            // 11 - Avakahada
            AvakahadaTab(avakahada: avakahada, ascendant: ascendant),
            // 12 - Gochar
            const GocharTab(),
            // 13 - Dasha
            DashaTab(dasha: dasha),
            // 14 - Yogas
            YogaTab(yogas: yogas),
            // 15 - Shodashvarga
            ShodashvargaTab(shodashvarga: shodashvarga),
            // 16 - Lal Kitab
            LalKitabTab(lalKitab: lalKitab),
            // 17 - Reports
            ReportsTab(doshas: doshas, numerology: numerology),
          ]),
        ),
      );
  }

  Widget _buildDrawer(String name) {
    return Drawer(
      child: Column(children: [
        UserAccountsDrawerHeader(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft, end: Alignment.bottomRight)),
          currentAccountPicture: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: AppColors.primary, size: 40)),
          accountName: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          accountEmail: const Text('Janma Kundli', style: TextStyle(color: Colors.white70)),
        ),
        Expanded(child: ListView(padding: EdgeInsets.zero, children: [
          _dItem('चार्ट (Chart)', Icons.grid_view_rounded, 0),
          _dItem('ग्रह (Planets)', Icons.stars_rounded, 1),
          _dItem('Planets-Sub (KP)', Icons.table_chart_rounded, 2),
          _dItem('Cusps (KP)', Icons.border_all_rounded, 3),
          _dItem('Planet Signification', Icons.text_snippet_rounded, 4),
          _dItem('House Significators', Icons.home_work_rounded, 5),
          _dItem('अष्टकवर्ग (Ashtakvarga)', Icons.apps_rounded, 6),
          _dItem('प्रस्तार अष्टकवर्ग (Prasthara)', Icons.grid_on_rounded, 7),
          _dItem('षडबल (Shad Bala)', Icons.bar_chart_rounded, 8),
          _dItem('ग्रह स्थिति', Icons.table_rows_rounded, 9),
          _dItem('केपी सिस्टम (KP System)', Icons.auto_stories_rounded, 10),
          _dItem('अवकहड़ा चक्र', Icons.grid_on_rounded, 11),
          _dItem('गोचर (Transit)', Icons.satellite_alt_rounded, 12),
          _dItem('दशा (Dasha)', Icons.timelapse_rounded, 13),
          _dItem('योग (Yogas)', Icons.auto_awesome_rounded, 14),
          _dItem('षोडशवर्ग', Icons.layers_rounded, 15),
          _dItem('लाल किताब', Icons.book_rounded, 16),
          _dItem('रिपोर्ट (Reports)', Icons.analytics_rounded, 17),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
            title: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () { Navigator.pop(context); Get.back(); }),
        ])),
      ]),
    );
  }

  Widget _dItem(String title, IconData icon, int tabIdx) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
      onTap: () { Navigator.pop(context); _tabController.animateTo(tabIdx); },
    );
  }
}
