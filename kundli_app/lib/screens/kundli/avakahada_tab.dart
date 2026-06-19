import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AvakahadaTab extends StatefulWidget {
  final Map<String, dynamic> avakahada;
  final Map<String, dynamic> ascendant;
  final Map<String, dynamic> ghatak;
  final Map<String, dynamic> favourable;

  const AvakahadaTab({
    super.key,
    required this.avakahada,
    required this.ascendant,
    required this.ghatak,
    required this.favourable,
  });

  @override
  State<AvakahadaTab> createState() => _AvakahadaTabState();
}

class _AvakahadaTabState extends State<AvakahadaTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _orange      = AppColors.primary;
  static const Color _orangeLight = AppColors.accentLight;
  static const Color _orangeBorder= AppColors.border;
  static const Color _textDark    = AppColors.textDark;
  static const Color _textGrey    = AppColors.textLight;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.avakahada.isEmpty || widget.avakahada['paya'] == null) {
      return Container(
        color: AppColors.scaffoldBg,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, size: 52, color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Loading Avakahada details...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: _orange,
            labelColor: _orange,
            unselectedLabelColor: _textGrey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'Avakahada'),
              Tab(text: 'Ghatak'),
              Tab(text: 'Favourable'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvakahadaSubTab(),
          _buildGhatakSubTab(),
          _buildFavourableSubTab(),
        ],
      ),
    );
  }

  // 1. Avakahada Sub-tab
  Widget _buildAvakahadaSubTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _tableCard([
          _row('Paya (Nakshatra Based)', widget.avakahada['paya'] ?? '-'),
          _row('Varna', widget.avakahada['varna'] ?? '-'),
          _row('Yoni', widget.avakahada['yoni'] ?? '-'),
          _row('Gana', widget.avakahada['gana'] ?? '-'),
          _row('Vasya', widget.avakahada['vashya'] ?? '-'),
          _row('Nadi', widget.avakahada['nadi'] ?? '-'),
        ]),

        const SizedBox(height: 12),
        _sectionLabel('Dasha Balance'),
        _tableCard([
          _row('Balance Of Dasha', widget.avakahada['dasha_bhogya'] ?? '-'),
        ]),

        const SizedBox(height: 12),
        _sectionLabel('Lagna & Rasi Details'),
        _tableCard([
          _row('Lagna', widget.avakahada['lagna'] ?? '-'),
          _row('Lagna Lord', widget.avakahada['lagna_swami'] ?? '-'),
          _row('Rasi', widget.avakahada['rashi'] ?? '-'),
          _row('Rasi Lord', widget.avakahada['rasi_swami'] ?? '-'),
          _row('Nakshatra-Pada', widget.avakahada['nakshatra_pad'] ?? '-'),
          _row('Nakshatra Lord', widget.avakahada['nakshatra_swami'] ?? '-'),
        ]),

        const SizedBox(height: 12),
        _sectionLabel('Astronomical Metrics'),
        _tableCard([
          _row('Julian Day', '${widget.avakahada['julian_day'] ?? '-'}'),
          _row('SunSign (Indian)', widget.avakahada['sun_sign_indian'] ?? '-'),
          _row('SunSign (Western)', widget.avakahada['sun_sign_western'] ?? '-'),
        ]),

        const SizedBox(height: 20),
      ],
    );
  }

  // 2. Ghatak Sub-tab
  Widget _buildGhatakSubTab() {
    final ghatak = widget.ghatak;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _buildHeader('Ghatak Chakra', Icons.warning_amber_rounded),
        const SizedBox(height: 8),
        _tableCard([
          _row('Bad Month', ghatak['bad_month'] ?? '-'),
          _row('Bad Tithi', ghatak['bad_tithi'] ?? '-'),
          _row('Bad Day', ghatak['bad_day'] ?? '-'),
          _row('Bad Nakshatra', ghatak['bad_nakshatra'] ?? '-'),
          _row('Bad Lagna', ghatak['bad_lagna'] ?? '-'),
          _row('Bad Rasi', ghatak['bad_rasi'] ?? '-'),
          _row('Bad Karan', ghatak['bad_karan'] ?? '-'),
          _row('Bad Yoga', ghatak['bad_yoga'] ?? '-'),
          _row('Bad Prahar', '${ghatak['bad_prahar'] ?? '-'}'),
          _row('Bad Planets', ghatak['bad_planets'] ?? '-'),
        ]),
        const SizedBox(height: 20),
      ],
    );
  }

  // 3. Favourable Sub-tab
  Widget _buildFavourableSubTab() {
    final favourable = widget.favourable;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _buildHeader('Favourable Points', Icons.recommend_rounded),
        const SizedBox(height: 8),
        _tableCard([
          _row('Lucky Number', favourable['lucky_num'] ?? '-'),
          _row('Good Numbers', favourable['good_num'] ?? '-'),
          _row('Evil Numbers', favourable['evil_num'] ?? '-'),
          _row('Good Years', favourable['good_years'] ?? '-'),
          _row('Lucky Days', favourable['lucky_days'] ?? '-'),
          _row('Good Planets', favourable['good_planets'] ?? '-'),
        ]),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        children: [
          Icon(icon, color: _orange, size: 18),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: _orange, letterSpacing: 0.3)),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(text, style: const TextStyle(
        fontSize: 13, fontWeight: FontWeight.bold, color: _orange, letterSpacing: 0.3)),
    );
  }

  Widget _tableCard(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _orangeBorder.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: _orange.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: rows),
    );
  }

  Widget _row(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 13, color: _textGrey, fontWeight: FontWeight.w500)),
        Flexible(
          child: Text(value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}
