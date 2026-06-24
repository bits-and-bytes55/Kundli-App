import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/custom_shadows.dart';

class PredictionsTab extends StatelessWidget {
  final List<dynamic> predictions;

  const PredictionsTab({super.key, required this.predictions});

  @override
  Widget build(BuildContext context) {
    if (predictions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No predictions available for this chart.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      color: AppColors.scaffoldBg,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: predictions.length,
        itemBuilder: (context, index) {
          final p = predictions[index] as Map<String, dynamic>? ?? {};
          final titleHi = p['title_hi'] ?? '';
          final titleEn = p['title_en'] ?? '';
          final descHi = p['desc_hi'] ?? '';
          final descEn = p['desc_en'] ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withOpacity(0.3)),
              boxShadow: CustomShadows.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$titleHi / $titleEn',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 10),
                Text(
                  descHi,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  descEn,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
