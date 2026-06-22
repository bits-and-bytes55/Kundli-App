import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DashaTab extends StatefulWidget {
  final List<dynamic> dasha;
  final List<dynamic> charDasha;
  final List<dynamic> yoginiDasha;
  final List<dynamic> mahadashaPhala;

  const DashaTab({
    super.key,
    required this.dasha,
    required this.charDasha,
    required this.yoginiDasha,
    required this.mahadashaPhala,
  });

  @override
  State<DashaTab> createState() => _DashaTabState();
}

class _DashaTabState extends State<DashaTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Vimshottari Drill-Down State
  int _vimshottariLevel = 0; // 0: Maha, 1: Antar, 2: Pratyantar, 3: Sookshma, 4: Prana
  int? _selectedMahaIdx;
  int? _selectedAntarIdx;
  int? _selectedPratyantarIdx;
  int? _selectedSookshmaIdx;
  
  // Expandable state for other tabs
  int? _expandedYoginiIdx;
  int? _expandedCharIdx;

  static const List<String> _dashaLords = ['Ketu', 'Shukra', 'Surya', 'Chandra', 'Mangal', 'Rahu', 'Guru', 'Shani', 'Budha'];
  static const Map<String, int> _dashaYears = {
    'Ketu': 7, 'Shukra': 20, 'Surya': 6, 'Chandra': 10, 'Mangal': 7, 'Rahu': 18, 'Guru': 16, 'Shani': 19, 'Budha': 17
  };

  static const _lordColors = {
    'Ketu': Color(0xFF795548), 'Shukra': Color(0xFFE91E63), 'Surya': Color(0xFFFF5722),
    'Chandra': Color(0xFF2196F3), 'Mangal': Color(0xFFF44336), 'Rahu': Color(0xFF607D8B),
    'Guru': Color(0xFFFFB300), 'Shani': Color(0xFF2D3436), 'Budha': Color(0xFF4CAF50),
  };

  static const _lordHindi = {
    'Ketu': 'केतु', 'Shukra': 'शुक्र', 'Surya': 'सूर्य',
    'Chandra': 'चंद्र', 'Mangal': 'मंगल', 'Rahu': 'राहु',
    'Guru': 'गुरु', 'Shani': 'शनि', 'Budha': 'बुध',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fractional year conversion to readable calendar date
  String _formatFractionalYear(double y) {
    if (y <= 0) return '-';
    int year = y.floor();
    double frac = y - year;
    int daysInYear = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 366 : 365;
    int dayOfYear = (frac * daysInYear).round();
    if (dayOfYear <= 0) dayOfYear = 1;
    
    DateTime date = DateTime(year, 1, 1).add(Duration(days: dayOfYear - 1));
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  // Get current fractional year to mark active periods
  double _getCurrentFractionalYear() {
    DateTime now = DateTime.now();
    int year = now.year;
    int daysInYear = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 366 : 365;
    int dayOfYear = now.difference(DateTime(year, 1, 1)).inDays + 1;
    return year + (dayOfYear / daysInYear);
  }

  // Subdivide parent Vimshottari period recursively
  List<Map<String, dynamic>> _calculateSubPeriods({
    required String parentLord,
    required double parentStart,
    required double parentEnd,
  }) {
    double parentDuration = parentEnd - parentStart;
    int startLordIdx = _dashaLords.indexOf(parentLord);
    if (startLordIdx == -1) startLordIdx = 0;
    
    List<Map<String, dynamic>> subPeriods = [];
    double currentStart = parentStart;
    
    for (int i = 0; i < 9; i++) {
      String lord = _dashaLords[(startLordIdx + i) % 9];
      double years = parentDuration * (_dashaYears[lord]! / 120.0);
      double end = currentStart + years;
      subPeriods.add({
        'lord': lord,
        'start_year': currentStart,
        'end_year': end,
        'duration_years': years,
      });
      currentStart = end;
    }
    return subPeriods;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldBg,
      child: Column(
        children: [
          // Sub-Tab header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
              tabs: const [
                Tab(text: 'Vimshottari'),
                Tab(text: 'Yogini'),
                Tab(text: 'Jaimini Chara'),
                Tab(text: 'Dasha Phala'),
              ],
            ),
          ),
          
          // Tab contents
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVimshottariTab(),
                _buildYoginiTab(),
                _buildCharaTab(),
                _buildPhalaTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Vimshottari Drill Down View
  Widget _buildVimshottariTab() {
    if (widget.dasha.isEmpty) {
      return const Center(child: Text('No Vimshottari data available.'));
    }

    final double nowFrac = _getCurrentFractionalYear();
    List<dynamic> currentList = [];
    String title = "Maha Dasha";
    
    // Determine data based on current level
    if (_vimshottariLevel == 0) {
      currentList = widget.dasha;
      title = "Vimshottari Maha Dashas";
    } else if (_vimshottariLevel == 1) {
      final maha = widget.dasha[_selectedMahaIdx!];
      currentList = maha['antars'] ?? [];
      title = "${maha['lord']} Maha Dasha ➔ Antar Dashas";
    } else if (_vimshottariLevel == 2) {
      final maha = widget.dasha[_selectedMahaIdx!];
      final antar = maha['antars'][_selectedAntarIdx!];
      currentList = _calculateSubPeriods(
        parentLord: antar['lord'],
        parentStart: (antar['start_year'] as num).toDouble(),
        parentEnd: (antar['end_year'] as num).toDouble(),
      );
      title = "${maha['lord']} ➔ ${antar['lord']} ➔ Pratyantardashas";
    } else if (_vimshottariLevel == 3) {
      final maha = widget.dasha[_selectedMahaIdx!];
      final antar = maha['antars'][_selectedAntarIdx!];
      final pratyantars = _calculateSubPeriods(
        parentLord: antar['lord'],
        parentStart: (antar['start_year'] as num).toDouble(),
        parentEnd: (antar['end_year'] as num).toDouble(),
      );
      final pd = pratyantars[_selectedPratyantarIdx!];
      currentList = _calculateSubPeriods(
        parentLord: pd['lord'],
        parentStart: pd['start_year'],
        parentEnd: pd['end_year'],
      );
      title = "${antar['lord']} ➔ ${pd['lord']} ➔ Sookshmadashas";
    } else {
      final maha = widget.dasha[_selectedMahaIdx!];
      final antar = maha['antars'][_selectedAntarIdx!];
      final pratyantars = _calculateSubPeriods(
        parentLord: antar['lord'],
        parentStart: (antar['start_year'] as num).toDouble(),
        parentEnd: (antar['end_year'] as num).toDouble(),
      );
      final pd = pratyantars[_selectedPratyantarIdx!];
      final sookshmas = _calculateSubPeriods(
        parentLord: pd['lord'],
        parentStart: pd['start_year'],
        parentEnd: pd['end_year'],
      );
      final sd = sookshmas[_selectedSookshmaIdx!];
      currentList = _calculateSubPeriods(
        parentLord: sd['lord'],
        parentStart: sd['start_year'],
        parentEnd: sd['end_year'],
      );
      title = "${pd['lord']} ➔ ${sd['lord']} ➔ Pranadashas";
    }

    return Column(
      children: [
        // Navigation path & level title
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Breadcrumbs
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _vimshottariLevel = 0),
                    child: Text('Maha', style: TextStyle(
                      fontWeight: _vimshottariLevel == 0 ? FontWeight.bold : FontWeight.normal,
                      color: _vimshottariLevel == 0 ? AppColors.primary : Colors.grey,
                      fontSize: 12,
                    )),
                  ),
                  const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                  GestureDetector(
                    onTap: _vimshottariLevel >= 1 ? () => setState(() => _vimshottariLevel = 1) : null,
                    child: Text('Antar', style: TextStyle(
                      fontWeight: _vimshottariLevel == 1 ? FontWeight.bold : FontWeight.normal,
                      color: _vimshottariLevel == 1 ? AppColors.primary : Colors.grey,
                      fontSize: 12,
                    )),
                  ),
                  const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                  GestureDetector(
                    onTap: _vimshottariLevel >= 2 ? () => setState(() => _vimshottariLevel = 2) : null,
                    child: Text('Pratyantar', style: TextStyle(
                      fontWeight: _vimshottariLevel == 2 ? FontWeight.bold : FontWeight.normal,
                      color: _vimshottariLevel == 2 ? AppColors.primary : Colors.grey,
                      fontSize: 12,
                    )),
                  ),
                  const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                  GestureDetector(
                    onTap: _vimshottariLevel >= 3 ? () => setState(() => _vimshottariLevel = 3) : null,
                    child: Text('Sookshma', style: TextStyle(
                      fontWeight: _vimshottariLevel == 3 ? FontWeight.bold : FontWeight.normal,
                      color: _vimshottariLevel == 3 ? AppColors.primary : Colors.grey,
                      fontSize: 12,
                    )),
                  ),
                  const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                  Text('Prana', style: TextStyle(
                    fontWeight: _vimshottariLevel == 4 ? FontWeight.bold : FontWeight.normal,
                    color: _vimshottariLevel == 4 ? AppColors.primary : Colors.grey,
                    fontSize: 12,
                  )),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (_vimshottariLevel > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => setState(() => _vimshottariLevel--),
                    ),
                  if (_vimshottariLevel > 0) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Dasha List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: currentList.length,
            itemBuilder: (ctx, i) {
              final d = currentList[i] as Map<String, dynamic>;
              final lord = d['lord'] as String? ?? '';
              final start = (d['start_year'] as num?)?.toDouble() ?? 0;
              final end = (d['end_year'] as num?)?.toDouble() ?? 0;
              final isActive = nowFrac >= start && nowFrac <= end;
              final color = _lordColors[lord] ?? AppColors.primary;
              final hindiName = _lordHindi[lord] ?? lord;

              return Card(
                elevation: isActive ? 2 : 0.5,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isActive ? color : Colors.grey.shade200,
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    if (_vimshottariLevel < 4) {
                      setState(() {
                        if (_vimshottariLevel == 0) {
                          _selectedMahaIdx = i;
                        } else if (_vimshottariLevel == 1) {
                          _selectedAntarIdx = i;
                        } else if (_vimshottariLevel == 2) {
                          _selectedPratyantarIdx = i;
                        } else if (_vimshottariLevel == 3) {
                          _selectedSookshmaIdx = i;
                        }
                        _vimshottariLevel++;
                      });
                    }
                  },
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.15),
                    child: Text(
                      lord.substring(0, minOf(lord.length, 2)),
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        '$lord ($hindiName)',
                        style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
                      ),
                      if (isActive)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    '${_formatFractionalYear(start)} → ${_formatFractionalYear(end)}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  trailing: _vimshottariLevel < 4
                      ? Icon(Icons.arrow_forward_ios, size: 14, color: color.withOpacity(0.7))
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 2. Yogini Dasha View
  Widget _buildYoginiTab() {
    if (widget.yoginiDasha.isEmpty) {
      return const Center(child: Text('No Yogini Dasha data available.'));
    }

    final double nowFrac = _getCurrentFractionalYear();
    
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widget.yoginiDasha.length,
      itemBuilder: (ctx, i) {
        final d = widget.yoginiDasha[i] as Map<String, dynamic>;
        final name = d['name'] as String? ?? '';
        final hindi = d['hindi'] as String? ?? '';
        final start = (d['start_year'] as num?)?.toDouble() ?? 0;
        final end = (d['end_year'] as num?)?.toDouble() ?? 0;
        final duration = (d['duration_years'] as num?)?.toDouble() ?? 0;
        final antars = d['antars'] as List<dynamic>? ?? [];
        
        final isActive = nowFrac >= start && nowFrac <= end;
        final isOpen = _expandedYoginiIdx == i;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isActive ? AppColors.primary : Colors.grey.shade200, width: isActive ? 2 : 1),
          ),
          child: Column(
            children: [
              ListTile(
                onTap: () => setState(() => _expandedYoginiIdx = isOpen ? null : i),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    name.substring(0, minOf(name.length, 2)),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                title: Row(
                  children: [
                    Text('$name ($hindi)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    if (isActive)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                        child: const Text('ACTIVE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                subtitle: Text(
                  '${_formatFractionalYear(start)} - ${_formatFractionalYear(end)} (${duration.toStringAsFixed(1)} yrs)',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                trailing: Icon(isOpen ? Icons.expand_less : Icons.expand_more, color: AppColors.primary),
              ),
              if (isOpen && antars.isNotEmpty)
                Container(
                  color: AppColors.primary.withOpacity(0.02),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: antars.map((a) {
                      final aName = a['name'] as String? ?? '';
                      final aHindi = a['hindi'] as String? ?? '';
                      final aStart = (a['start_year'] as num?)?.toDouble() ?? 0;
                      final aEnd = (a['end_year'] as num?)?.toDouble() ?? 0;
                      final aActive = nowFrac >= aStart && nowFrac <= aEnd;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: aActive ? AppColors.primary.withOpacity(0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: aActive ? AppColors.primary : Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Expanded(child: Text('$aName ($aHindi)', style: TextStyle(
                              fontWeight: aActive ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                              color: aActive ? AppColors.primary : Colors.black87
                            ))),
                            Text('${_formatFractionalYear(aStart)} - ${_formatFractionalYear(aEnd)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  // 3. Jaimini Chara Dasha View
  Widget _buildCharaTab() {
    if (widget.charDasha.isEmpty) {
      return const Center(child: Text('No Chara Dasha data available.'));
    }

    final double nowFrac = _getCurrentFractionalYear();
    
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widget.charDasha.length,
      itemBuilder: (ctx, i) {
        final d = widget.charDasha[i] as Map<String, dynamic>;
        final sign = d['sign'] as String? ?? '';
        final start = (d['start_year'] as num?)?.toDouble() ?? 0;
        final end = (d['end_year'] as num?)?.toDouble() ?? 0;
        final years = (d['years'] as num?)?.toInt() ?? 0;
        final antars = d['antars'] as List<dynamic>? ?? [];
        
        final isActive = nowFrac >= start && nowFrac <= end;
        final isOpen = _expandedCharIdx == i;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isActive ? AppColors.primary : Colors.grey.shade200, width: isActive ? 2 : 1),
          ),
          child: Column(
            children: [
              ListTile(
                onTap: () => setState(() => _expandedCharIdx = isOpen ? null : i),
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  child: Text(
                    sign.substring(0, minOf(sign.length, 3)),
                    style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                title: Row(
                  children: [
                    Text('$sign Dasha', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    if (isActive)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                        child: const Text('ACTIVE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                subtitle: Text(
                  '${_formatFractionalYear(start)} - ${_formatFractionalYear(end)} ($years Yrs)',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                trailing: Icon(isOpen ? Icons.expand_less : Icons.expand_more, color: AppColors.primary),
              ),
              if (isOpen && antars.isNotEmpty)
                Container(
                  color: Colors.purple.withOpacity(0.02),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: antars.map((a) {
                      final aName = a['name'] as String? ?? '';
                      final aStart = (a['start_year'] as num?)?.toDouble() ?? 0;
                      final aEnd = (a['end_year'] as num?)?.toDouble() ?? 0;
                      final aActive = nowFrac >= aStart && nowFrac <= aEnd;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: aActive ? Colors.purple.withOpacity(0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: aActive ? Colors.purple : Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.purple, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Expanded(child: Text('$aName Antar', style: TextStyle(
                              fontWeight: aActive ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                              color: aActive ? Colors.purple : Colors.black87
                            ))),
                            Text('${_formatFractionalYear(aStart)} - ${_formatFractionalYear(aEnd)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  // 4. Mahadasha Phala (Predictions) View
  Widget _buildPhalaTab() {
    if (widget.mahadashaPhala.isEmpty) {
      return const Center(child: Text('No predictions available.'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widget.mahadashaPhala.length,
      itemBuilder: (ctx, i) {
        final item = widget.mahadashaPhala[i] as Map<String, dynamic>;
        final lord = item['lord'] as String? ?? '';
        final rashi = item['rashi'] as String? ?? '';
        final house = item['house'] as int? ?? 1;
        final pred = item['prediction'] as String? ?? '';
        final color = _lordColors[lord] ?? AppColors.primary;
        return Card(
          elevation: 0.5,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ExpansionTile(
            key: PageStorageKey('phala_$lord'),
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Text(lord.substring(0, minOf(lord.length, 2)), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            title: Text(
              '$lord Dasha Predictions',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
            ),
            subtitle: Text(
              '$lord is in $rashi inside House $house',
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Text(
                  pred,
                  style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int minOf(int a, int b) => a < b ? a : b;
}
