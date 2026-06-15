import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kundli_controller.dart';
import '../theme/custom_shadows.dart';
import 'kundli/dasha_tab.dart';
import 'kundli/yoga_tab.dart';
import 'kundli/lal_kitab_tab.dart';
import 'kundli/chart_tab.dart';
import 'kundli/planets_tab.dart';
import 'kundli/reports_tab.dart';
import 'kundli/shodashvarga_tab.dart';

class KundliScreen extends StatefulWidget {
  const KundliScreen({super.key});
  @override
  State<KundliScreen> createState() => _KundliScreenState();
}

class _KundliScreenState extends State<KundliScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Tab> _tabs = const [
    Tab(text: 'Chart'), Tab(text: 'Planets'), Tab(text: 'Dasha'),
    Tab(text: 'Yogas'), Tab(text: 'Shodashvarga'), Tab(text: 'Lal Kitab'),
    Tab(text: 'Reports'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
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
    final planets = data['planets'] as Map<String, dynamic>;
    final ascendant = data['ascendant'];
    final kpPlanets = data['kp_planets'] as Map<String, dynamic>? ?? planets;
    final kpAscendant = data['kp_ascendant'] ?? ascendant;
    final dasha = data['dasha'] as List<dynamic>? ?? [];
    final yogas = data['yogas'] as List<dynamic>? ?? [];
    final doshas = data['doshas'] as Map<String, dynamic>? ?? {};
    final numerology = data['numerology'] as Map<String, dynamic>? ?? {};
    final lalKitab = data['lal_kitab'] as Map<String, dynamic>? ?? {};
    final shodashvarga = data['shodashvarga'] as Map<String, dynamic>? ?? {};

    return Scaffold(
        backgroundColor: const Color(0xFFFFF5F7),
        key: _scaffoldKey,
        drawer: _buildDrawer(data['name'] ?? ''),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFFFF7E93)),
            onPressed: () => _scaffoldKey.currentState?.openDrawer()),
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data['name'] ?? '', style: const TextStyle(color: Color(0xFFFF7E93), fontWeight: FontWeight.bold, fontSize: 16)),
            Text('${data['date']} • ${ascendant['rashi']} Lagna', style: const TextStyle(fontSize: 11, color: Color(0xFF7F8C8D))),
          ]),
          actions: [IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFFF7E93)), onPressed: () => Get.back())],
          bottom: TabBar(
            controller: _tabController, isScrollable: true,
            labelColor: const Color(0xFFFF7E93), unselectedLabelColor: const Color(0xFF7F8C8D),
            indicatorColor: const Color(0xFFFF7E93), indicatorWeight: 3,
            tabs: _tabs,
          ),
        ),
        body: TabBarView(controller: _tabController, children: [
          ChartTab(ascendant: ascendant, planets: planets, kpAscendant: kpAscendant, kpPlanets: kpPlanets),
          PlanetsTab(planets: planets, ascendant: ascendant),
          DashaTab(dasha: dasha),
          YogaTab(yogas: yogas),
          ShodashvargaTab(shodashvarga: shodashvarga),
          LalKitabTab(lalKitab: lalKitab),
          ReportsTab(doshas: doshas, numerology: numerology),
        ]),
      );
  }

  Widget _buildDrawer(String name) {
    return Drawer(
      child: Column(children: [
        UserAccountsDrawerHeader(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFFF7E93), Color(0xFFD5F3D8)],
              begin: Alignment.topLeft, end: Alignment.bottomRight)),
          currentAccountPicture: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFFFF7E93), size: 40)),
          accountName: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          accountEmail: const Text('Janma Kundli', style: TextStyle(color: Colors.white70)),
        ),
        Expanded(child: ListView(padding: EdgeInsets.zero, children: [
          _dItem('होम', Icons.home_rounded, 0),
          _dItem('चार्ट (Chart)', Icons.grid_view_rounded, 0),
          _dItem('ग्रह (Planets)', Icons.stars_rounded, 1),
          _dItem('दशा (Dasha)', Icons.timelapse_rounded, 2),
          _dItem('योग (Yogas)', Icons.auto_awesome_rounded, 3),
          _dItem('षोडशवर्ग', Icons.layers_rounded, 4),
          _dItem('लाल किताब', Icons.book_rounded, 5),
          _dItem('रिपोर्ट (Reports)', Icons.analytics_rounded, 6),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.arrow_back_rounded, color: Color(0xFFFF7E93)),
            title: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () { Navigator.pop(context); Get.back(); }),
        ])),
      ]),
    );
  }

  Widget _dItem(String title, IconData icon, int tabIdx) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFF7E93)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
      onTap: () { Navigator.pop(context); _tabController.animateTo(tabIdx); },
    );
  }
}
