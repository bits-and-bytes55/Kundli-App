import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kundli_controller.dart';
import '../theme/app_theme.dart';
import 'kundli/dasha_tab.dart';
import 'kundli/yoga_tab.dart';
import 'kundli/lal_kitab_tab.dart';
import 'kundli/chart_tab.dart';
import 'kundli/planets_tab.dart';
import 'kundli/reports_tab.dart';
import 'kundli/shodashvarga_tab.dart';
import 'kundli/graha_sthiti_tab.dart';
import 'kundli/avakahada_tab.dart';
import 'kundli/gochar_tab.dart';

class KundliScreen extends StatefulWidget {
  const KundliScreen({super.key});
  @override
  State<KundliScreen> createState() => _KundliScreenState();
}

class _KundliScreenState extends State<KundliScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Tab> _tabs = const [
    Tab(text: 'Chart'), Tab(text: 'Planets'), Tab(text: 'Graha Sthiti'),
    Tab(text: 'Avakahada'), Tab(text: 'Gochar'), Tab(text: 'Dasha'),
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
    final avakahada = data['avakahada'] as Map<String, dynamic>? ?? {};

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
        body: TabBarView(controller: _tabController, children: [
          ChartTab(ascendant: ascendant, planets: planets, kpAscendant: kpAscendant, kpPlanets: kpPlanets),
          PlanetsTab(planets: planets, ascendant: ascendant),
          GrahaSthitiTab(planets: planets, ascendant: ascendant),
          AvakahadaTab(avakahada: avakahada, ascendant: ascendant),
          const GocharTab(),
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
          _dItem('ग्रह स्थिति', Icons.table_rows_rounded, 2),
          _dItem('अवकहड़ा चक्र', Icons.grid_on_rounded, 3),
          _dItem('गोचर (Transit)', Icons.satellite_alt_rounded, 4),
          _dItem('दशा (Dasha)', Icons.timelapse_rounded, 5),
          _dItem('योग (Yogas)', Icons.auto_awesome_rounded, 6),
          _dItem('षोडशवर्ग', Icons.layers_rounded, 7),
          _dItem('लाल किताब', Icons.book_rounded, 8),
          _dItem('रिपोर्ट (Reports)', Icons.analytics_rounded, 9),
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
