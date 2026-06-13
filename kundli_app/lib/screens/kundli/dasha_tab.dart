import 'package:flutter/material.dart';

class DashaTab extends StatefulWidget {
  final List<dynamic> dasha;
  const DashaTab({super.key, required this.dasha});
  @override State<DashaTab> createState() => _DashaTabState();
}

class _DashaTabState extends State<DashaTab> {
  int? _expanded;
  final now = DateTime.now().year + DateTime.now().month / 12.0;

  static const lordColors = {
    'Ketu': Color(0xFF795548), 'Shukra': Color(0xFF9C27B0), 'Surya': Color(0xFFFF5722),
    'Chandra': Color(0xFF2196F3), 'Mangal': Color(0xFFF44336), 'Rahu': Color(0xFF607D8B),
    'Guru': Color(0xFFFFB300), 'Shani': Color(0xFF333333), 'Budha': Color(0xFF4CAF50),
  };

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widget.dasha.length,
      itemBuilder: (ctx, i) {
        final d = widget.dasha[i] as Map<String, dynamic>;
        final lord = d['lord'] as String? ?? '';
        final start = (d['start_year'] as num?)?.toDouble() ?? 0;
        final end = (d['end_year'] as num?)?.toDouble() ?? 0;
        final isActive = now >= start && now <= end;
        final color = lordColors[lord] ?? const Color(0xFFFF7E93);
        final antars = d['antars'] as List<dynamic>? ?? [];
        final isOpen = _expanded == i;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isActive ? color : Colors.grey.shade200, width: isActive ? 2 : 1),
          ),
          child: Column(children: [
            ListTile(
              onTap: () => setState(() => _expanded = isOpen ? null : i),
              leading: CircleAvatar(backgroundColor: color.withOpacity(0.15),
                child: Text(lord.substring(0, 2), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12))),
              title: Row(children: [
                Text('$lord Maha Dasha', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                if (isActive) Container(margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                  child: const Text('ACTIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
              ]),
              subtitle: Text('${_yearToStr(start)} → ${_yearToStr(end)} (${(d['duration_years'] as num?)?.toStringAsFixed(1)} yrs)',
                style: const TextStyle(fontSize: 12, color: Color(0xFF7F8C8D))),
              trailing: Icon(isOpen ? Icons.expand_less : Icons.expand_more, color: color),
            ),
            if (isOpen)
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.04),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12))),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: antars.map((a) {
                    final antar = a as Map<String, dynamic>;
                    final aLord = antar['lord'] as String? ?? '';
                    final aStart = (antar['start_year'] as num?)?.toDouble() ?? 0;
                    final aEnd = (antar['end_year'] as num?)?.toDouble() ?? 0;
                    final aActive = now >= aStart && now <= aEnd;
                    final aColor = lordColors[aLord] ?? Colors.grey;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: aActive ? aColor.withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: aActive ? aColor : Colors.grey.shade200),
                      ),
                      child: Row(children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: aColor, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Expanded(child: Text('$aLord Antar', style: TextStyle(fontWeight: aActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13, color: aActive ? aColor : const Color(0xFF2C3E50)))),
                        Text('${_yearToStr(aStart)} - ${_yearToStr(aEnd)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ]),
                    );
                  }).toList(),
                ),
              ),
          ]),
        );
      },
    );
  }

  String _yearToStr(double y) {
    int year = y.floor();
    int month = ((y - year) * 12).round();
    if (month == 0) month = 1;
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[(month - 1).clamp(0, 11)]} $year';
  }
}
