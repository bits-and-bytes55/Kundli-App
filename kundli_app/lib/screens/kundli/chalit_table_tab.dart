import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ChalitTableTab extends StatelessWidget {
  final List<dynamic> chalitTable;
  const ChalitTableTab({super.key, required this.chalitTable});

  static const Color _orangeLight = AppColors.accentLight;
  static const Color _orangeBorder = AppColors.border;

  @override
  Widget build(BuildContext context) {
    if (chalitTable.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: Center(child: Text('Loading Chalit Table...', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header explanation card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.black, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bhav Chalit (Shripati System) displays the astrological house boundaries (Bh. Begin) and house midpoints (Mid Bh).',
                      style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Table card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.2), // Bh. No
                    1: FlexColumnWidth(2.5), // Bh. Begin Sign + Deg
                    2: FlexColumnWidth(2.5), // Mid Bh Sign + Deg
                  },
                  border: TableBorder.symmetric(
                    inside: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  children: [
                    // Table Header
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                      ),
                      children: [
                        _buildHeaderCell('Bh.'),
                        _buildHeaderCell('Bh. Begin'),
                        _buildHeaderCell('Mid Bh.'),
                      ],
                    ),
                    // Table Rows
                    ...chalitTable.map((row) {
                      final isEven = (row['house'] as int) % 2 == 0;
                      return TableRow(
                        decoration: BoxDecoration(
                          color: isEven ? Colors.grey.shade50 : Colors.white,
                        ),
                        children: [
                          _buildCell('${row['house']}', isBold: true, alignment: Alignment.center),
                          _buildCuspCell(row['begin_sign'] ?? '', row['begin_deg_str'] ?? ''),
                          _buildCuspCell(row['mid_sign'] ?? '', row['mid_deg_str'] ?? ''),
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
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCell(String text, {bool isBold = false, Alignment alignment = Alignment.centerLeft}) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.black,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildCuspCell(String sign, String degree) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Sign Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: _orangeLight,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _orangeBorder.withOpacity(0.5)),
            ),
            child: Text(
              sign,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Degree Text
          Text(
            degree,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
