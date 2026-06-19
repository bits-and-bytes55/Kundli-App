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
import 'kundli/personal_details_tab.dart';
import 'kundli/chalit_table_tab.dart';
import 'kundli/friendship_tab.dart';

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
    Tab(text: 'Basic'),
    Tab(text: 'Chart'),
    Tab(text: 'Chalit Table'),
    Tab(text: 'Planets'),
    Tab(text: 'Planets-Sub'),
    Tab(text: 'Cusps'),
    Tab(text: 'Planet Sig.'),
    Tab(text: 'House Sig.'),
    Tab(text: 'Ashtakvarga'),
    Tab(text: 'Prasthara'),
    Tab(text: 'Friendship'),
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
    
    // New fields
    final personalDetails = data['personal_details'] as Map<String, dynamic>? ?? {};
    final ghatak = data['ghatak'] as Map<String, dynamic>? ?? {};
    final favourable = data['favourable'] as Map<String, dynamic>? ?? {};
    final friendship = data['friendship'] as Map<String, dynamic>? ?? {};
    final chalitTable = data['chalit_table'] as List<dynamic>? ?? [];

    return Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        key: _scaffoldKey,
        drawer: _buildDrawer(data['name'] ?? ''),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.black),
            onPressed: () => _scaffoldKey.currentState?.openDrawer()),
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data['name'] ?? '', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 17)),
            Text('${data['date']} • ${ascendant['rashi']} Lagna', style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w700)),
          ]),
          actions: [IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black), onPressed: () => Get.back())],
          bottom: TabBar(
            controller: _tabController, isScrollable: true,
            labelColor: Colors.black, unselectedLabelColor: Colors.black54,
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
            // 0 - Basic Details
            PersonalDetailsTab(personalDetails: personalDetails),
            // 1 - Chart
            ChartTab(ascendant: ascendant, planets: planets, kpAscendant: kpAscendant, kpPlanets: kpPlanets),
            // 2 - Chalit Table
            ChalitTableTab(chalitTable: chalitTable),
            // 3 - Planets (AstroSage style)
            PlanetsTab(planets: planets, ascendant: ascendant),
            // 4 - Planets-Sub (KP SL/NL/SB/SS)
            PlanetsSubTab(kpPlanets: kpPlanets, kpAscendant: kpAscendant),
            // 5 - Cusps
            CuspsTab(kpAscendant: kpAscendant),
            // 6 - Planet Signification
            PlanetSignificationTab(planetSignificators: planetSignificators),
            // 7 - House Significators
            HouseSignificatorsTab(houseSignificators: houseSignificators, kpPlanets: kpPlanets),
            // 8 - Ashtakvarga SAV
            AshtakvargaTab(ashtakvarga: ashtakvarga),
            // 9 - Prastharashtakvarga PAT
            PrastharashtakvargaTab(prastharaAshtakvarga: prastharaAshtakvarga),
            // 10 - Friendship
            FriendshipTab(friendship: friendship),
            // 11 - Shad Bala & Bhav Bala
            ShadBalaTab(shadBala: shadBala),
            // 12 - Graha Sthiti
            GrahaSthitiTab(planets: planets, ascendant: ascendant),
            // 13 - KP System
            KpTab(kpPlanets: kpPlanets, kpAscendant: kpAscendant),
            // 14 - Avakahada
            AvakahadaTab(avakahada: avakahada, ascendant: ascendant, ghatak: ghatak, favourable: favourable),
            // 15 - Gochar
            const GocharTab(),
            // 16 - Dasha
            DashaTab(dasha: dasha),
            // 17 - Yogas
            YogaTab(yogas: yogas),
            // 18 - Shodashvarga
            ShodashvargaTab(shodashvarga: shodashvarga),
            // 19 - Lal Kitab
            LalKitabTab(lalKitab: lalKitab),
            // 20 - Reports
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
          _dItem('Basic (Personal)', Icons.info_outline_rounded, 0),
          _dItem('चार्ट (Chart)', Icons.grid_view_rounded, 1),
          _dItem('Chalit Table', Icons.table_view_rounded, 2),
          _dItem('ग्रह (Planets)', Icons.stars_rounded, 3),
          _dItem('Planets-Sub (KP)', Icons.table_chart_rounded, 4),
          _dItem('Cusps (KP)', Icons.border_all_rounded, 5),
          _dItem('Planet Signification', Icons.text_snippet_rounded, 6),
          _dItem('House Significators', Icons.home_work_rounded, 7),
          _dItem('अष्टकवर्ग (Ashtakvarga)', Icons.apps_rounded, 8),
          _dItem('प्रस्तार अष्टकवर्ग (Prasthara)', Icons.grid_on_rounded, 9),
          _dItem('Planetary Friendship', Icons.people_rounded, 10),
          _dItem('षडबल (Shad Bala)', Icons.bar_chart_rounded, 11),
          _dItem('ग्रह स्थिति', Icons.table_rows_rounded, 12),
          _dItem('केपी सिस्टम (KP System)', Icons.auto_stories_rounded, 13),
          _dItem('अवकहड़ा चक्र', Icons.grid_on_rounded, 14),
          _dItem('गोचर (Transit)', Icons.satellite_alt_rounded, 15),
          _dItem('दशा (Dasha)', Icons.timelapse_rounded, 16),
          _dItem('योग (Yogas)', Icons.auto_awesome_rounded, 17),
          _dItem('षोडशवर्ग', Icons.layers_rounded, 18),
          _dItem('लाल किताब', Icons.book_rounded, 19),
          _dItem('रिपोर्ट (Reports)', Icons.analytics_rounded, 20),
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
