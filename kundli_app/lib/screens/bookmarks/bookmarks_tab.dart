import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../birth_form_screen.dart';
import '../kundli_screen.dart';
import '../../controllers/kundli_controller.dart';
import '../../theme/app_theme.dart';
import '../../theme/custom_shadows.dart';

class BookmarksTab extends StatefulWidget {
  const BookmarksTab({super.key});

  @override
  State<BookmarksTab> createState() => _BookmarksTabState();
}

class _BookmarksTabState extends State<BookmarksTab> {
  final KundliController _kundliController = Get.put(KundliController());
  List<Map<String, dynamic>> _savedCharts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCharts();
  }

  Future<void> _loadCharts() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('saved_charts');
    if (raw != null) {
      try {
        final List<dynamic> decoded = jsonDecode(raw);
        setState(() {
          _savedCharts = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } catch (e) {
        print("Failed to decode saved charts: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _deleteChart(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedCharts.removeAt(index);
    });
    await prefs.setString('saved_charts', jsonEncode(_savedCharts));
    Get.snackbar('Deleted', 'Profile removed from saved charts.', snackPosition: SnackPosition.BOTTOM);
  }

  void _openChart(Map<String, dynamic> chart) async {
    setState(() => _isLoading = true);
    try {
      await _kundliController.fetchKundli(
        chart['name'],
        chart['date'],
        chart['time'],
        (chart['lat'] as num).toDouble(),
        (chart['lon'] as num).toDouble(),
      );
      setState(() => _isLoading = false);
      if (_kundliController.kundliData.value != null) {
        Get.to(() => const KundliScreen());
      } else {
        Get.snackbar('Error', 'Failed to calculate Kundli calculations.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Saved Charts (कुंडली संग्रह)'),
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadCharts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _savedCharts.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadCharts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _savedCharts.length,
                    itemBuilder: (context, index) {
                      final item = _savedCharts[index];
                      return _buildChartCard(item, index);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Get.to(() => BirthFormScreen())?.then((_) => _loadCharts()),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_outline_rounded, size: 72, color: AppColors.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'No Saved Profiles',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Charts you generate will be saved here for instant calculation access.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create New Chart'),
              onPressed: () => Get.to(() => BirthFormScreen())?.then((_) => _loadCharts()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: CustomShadows.cardShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.12),
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
        title: Text(
          item['name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textDark),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item['date']} • ${item['time']}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMedium, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                item['place'] ?? '-',
                style: const TextStyle(fontSize: 11, color: AppColors.textLight),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400),
          onPressed: () => _deleteChart(index),
        ),
        onTap: () => _openChart(item),
      ),
    );
  }
}
