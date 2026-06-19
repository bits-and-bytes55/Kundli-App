import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class FriendshipTab extends StatefulWidget {
  final Map<String, dynamic> friendship;
  const FriendshipTab({super.key, required this.friendship});

  @override
  State<FriendshipTab> createState() => _FriendshipTabState();
}

class _FriendshipTabState extends State<FriendshipTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _orange      = AppColors.primary;
  static const Color _orangeLight = AppColors.accentLight;
  static const Color _orangeBorder= AppColors.border;
  static const Color _textDark    = AppColors.textDark;
  static const Color _textGrey    = AppColors.textLight;

  final List<String> _planets = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'];
  final Map<String, String> _abbrevs = {
    'Sun': 'SU', 'Moon': 'MO', 'Mars': 'MA', 'Mercury': 'ME',
    'Jupiter': 'JU', 'Venus': 'VE', 'Saturn': 'SA'
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.friendship.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: Center(child: Text('Loading friendship tables...', style: TextStyle(color: _textDark))),
      );
    }

    final permanent = widget.friendship['permanent'] as Map<String, dynamic>? ?? {};
    final temporal = widget.friendship['temporal'] as Map<String, dynamic>? ?? {};

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
              Tab(text: 'Permanent Friendship'),
              Tab(text: 'Temporal Friendship'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendshipTable(permanent, 'Permanent relationship between planets based on classical laws.'),
          _buildFriendshipTable(temporal, 'Temporal relationship based on current positions in the horoscope (Tatkalika Maitri).'),
        ],
      ),
    );
  }

  Widget _buildFriendshipTable(Map<String, dynamic> matrix, String explanation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info description card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _orangeLight,
              border: Border.all(color: _orangeBorder, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: _orange, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    explanation,
                    style: const TextStyle(fontSize: 12, color: _textDark, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Legend description
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 4),
            child: Row(
              children: [
                _buildLegendItem('F', Colors.green, 'Friend'),
                const SizedBox(width: 16),
                _buildLegendItem('N', Colors.orange.shade700, 'Neutral'),
                const SizedBox(width: 16),
                _buildLegendItem('E', Colors.red, 'Enemy'),
              ],
            ),
          ),

          // 7x7 Grid Table
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _orangeBorder.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(color: _orange.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.2), // Row Header (Planet)
                  1: FlexColumnWidth(1.0),
                  2: FlexColumnWidth(1.0),
                  3: FlexColumnWidth(1.0),
                  4: FlexColumnWidth(1.0),
                  5: FlexColumnWidth(1.0),
                  6: FlexColumnWidth(1.0),
                  7: FlexColumnWidth(1.0),
                },
                border: TableBorder.symmetric(
                  inside: BorderSide(color: Colors.grey.shade100, width: 1),
                ),
                children: [
                  // Table Header
                  TableRow(
                    decoration: const BoxDecoration(
                      color: _orange,
                    ),
                    children: [
                      _buildHeaderCell('Planets'),
                      ..._planets.map((p) => _buildHeaderCell(_abbrevs[p]!)),
                    ],
                  ),
                  // Table Rows
                  ..._planets.map((p1) {
                    final rowData = matrix[p1] as Map<String, dynamic>? ?? {};
                    return TableRow(
                      children: [
                        // Row header
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          color: _orangeLight.withOpacity(0.3),
                          child: Text(
                            _abbrevs[p1]!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Relationships
                        ..._planets.map((p2) {
                          final rel = rowData[p2] ?? '—';
                          return _buildRelCell(rel);
                        }),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String code, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            code,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: _textGrey, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildRelCell(String rel) {
    Color txtColor = _textGrey;
    Color bgColor = Colors.transparent;

    if (rel == 'F') {
      txtColor = Colors.green.shade700;
      bgColor = Colors.green.shade50.withOpacity(0.5);
    } else if (rel == 'E') {
      txtColor = Colors.red.shade700;
      bgColor = Colors.red.shade50.withOpacity(0.5);
    } else if (rel == 'N') {
      txtColor = Colors.orange.shade800;
      bgColor = Colors.orange.shade50.withOpacity(0.3);
    }

    return Container(
      color: bgColor,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        rel,
        style: TextStyle(
          fontSize: 13,
          color: txtColor,
          fontWeight: rel != '—' ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
