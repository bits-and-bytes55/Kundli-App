import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../birth_form_screen.dart';
import '../kundli_screen.dart';
import '../premium_kundli_screen.dart';
import '../../controllers/kundli_controller.dart';
import '../../theme/app_theme.dart';
import '../../theme/custom_shadows.dart';
import 'package:geocoding/geocoding.dart';
import '../../services/api_service.dart';

class BookmarksTab extends StatefulWidget {
  const BookmarksTab({super.key});

  @override
  State<BookmarksTab> createState() => _BookmarksTabState();
}

class _BookmarksTabState extends State<BookmarksTab> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allCharts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllCharts(isRefresh: true);
  }

  Future<void> _loadAllCharts({bool isRefresh = true}) async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final String phone = prefs.getString('logged_phone') ?? '9999999999';

    List<Map<String, dynamic>> localList = [];
    if (_searchQuery.isEmpty) {
      final raw = prefs.getString('saved_charts_all');
      if (raw != null) {
        try {
          final List<dynamic> decoded = jsonDecode(raw);
          localList = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        } catch (e) {
          print("Failed to decode saved charts: $e");
        }
      }
    }

    try {
      final apiService = Get.find<ApiService>();
      final apiList = await apiService.getSavedCharts(phone, query: _searchQuery, page: 1, limit: 20);
      
      if (apiList != null) {
        // Merge API list into local list, preferring API for duplicates
        int defaultTimestamp = DateTime.now().millisecondsSinceEpoch;
        for (var apiChart in apiList) {
          final existsIdx = localList.indexWhere((c) => 
            (c['id']?.toString() ?? c['_id']?.toString()) == (apiChart['id']?.toString() ?? apiChart['_id']?.toString()) ||
            (c['name'] == apiChart['name'] && c['date'] == apiChart['date'] && c['time'] == apiChart['time'])
          );
          if (existsIdx != -1) {
            apiChart['timestamp'] = localList[existsIdx]['timestamp'] ?? defaultTimestamp;
            localList[existsIdx] = apiChart;
          } else {
            apiChart['timestamp'] = defaultTimestamp;
            localList.add(apiChart);
          }
          defaultTimestamp--; // Ensure API list order is preserved if they all get added now
        }

        if (_searchQuery.isEmpty) {
          await prefs.setString('saved_charts_all', jsonEncode(localList));
        }

        if (_searchQuery.isNotEmpty) {
           localList = localList.where((c) {
             final name = (c['name'] ?? '').toString().toLowerCase();
             return name.contains(_searchQuery.toLowerCase());
           }).toList();
        }

        // Sort localList by timestamp descending
        localList.sort((a, b) {
          int timeA = a['timestamp'] ?? 0;
          int timeB = b['timestamp'] ?? 0;
          return timeB.compareTo(timeA); // Descending
        });

        setState(() {
          _allCharts = localList;
          _isLoading = false;
        });
        
        return;
      }
    } catch (e) {
      print("API getSavedCharts failed: $e");
    }

    if (_searchQuery.isNotEmpty) {
       localList = localList.where((c) {
         final name = (c['name'] ?? '').toString().toLowerCase();
         return name.contains(_searchQuery.toLowerCase());
       }).toList();
    }

    // Sort localList by timestamp descending
    localList.sort((a, b) {
      int timeA = a['timestamp'] ?? 0;
      int timeB = b['timestamp'] ?? 0;
      return timeB.compareTo(timeA); // Descending
    });

    setState(() {
      _allCharts = localList;
      _isLoading = false;
    });
  }

  Future<void> _updatePrefs() async {
    if (_searchQuery.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_charts_all', jsonEncode(_allCharts));
    }
  }

  Future<void> _onChartDeleted(Map<String, dynamic> chart) async {
    final chartId = chart['id']?.toString() ?? chart['_id']?.toString();
    setState(() {
      if (chartId != null) {
        _allCharts.removeWhere((c) => (c['id']?.toString() ?? c['_id']?.toString()) == chartId);
      } else {
        _allCharts.removeWhere((c) => c['name'] == chart['name'] && c['date'] == chart['date'] && c['time'] == chart['time']);
      }
    });
    await _updatePrefs();
    _loadAllCharts(isRefresh: true);
  }

  Future<void> _onChartUpdated(Map<String, dynamic> oldChart, Map<String, dynamic> updatedChart) async {
    setState(() {
      final oldId = oldChart['id']?.toString() ?? oldChart['_id']?.toString();
      int idx = -1;
      if (oldId != null) {
        idx = _allCharts.indexWhere((c) => (c['id']?.toString() ?? c['_id']?.toString()) == oldId);
      } else {
        idx = _allCharts.indexWhere((c) => c['name'] == oldChart['name'] && c['date'] == oldChart['date'] && c['time'] == oldChart['time']);
      }
      
      if (idx != -1) {
        _allCharts[idx] = updatedChart;
      }
    });
    await _updatePrefs();
    _loadAllCharts(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final basicCharts = _allCharts.where((c) {
      final m = (c['mode']?.toString() ?? 'Basic').toLowerCase().trim();
      return m == 'basic' || m.isEmpty;
    }).toList();
    
    final premiumCharts = _allCharts.where((c) {
      final m = (c['mode']?.toString() ?? '').toLowerCase().trim();
      return m == 'premium';
    }).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          title: const Text('Saved Charts (कुंडली संग्रह)'),
          elevation: 0.5,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
              onPressed: () => _loadAllCharts(isRefresh: true),
            ),
          ],
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.black54,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Basic Kundli'),
              Tab(text: 'Premium Kundli'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            _loadAllCharts(isRefresh: true);
                          })
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  _loadAllCharts(isRefresh: true);
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SavedChartsList(
                    mode: 'Basic', 
                    searchQuery: _searchQuery, 
                    charts: basicCharts, 
                    isLoading: _isLoading,
                    onDelete: _onChartDeleted,
                    onUpdate: _onChartUpdated,
                    onRefresh: () => _loadAllCharts(isRefresh: true),
                  ),
                  SavedChartsList(
                    mode: 'Premium', 
                    searchQuery: _searchQuery, 
                    charts: premiumCharts, 
                    isLoading: _isLoading,
                    onDelete: _onChartDeleted,
                    onUpdate: _onChartUpdated,
                    onRefresh: () => _loadAllCharts(isRefresh: true),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => Get.to(() => BirthFormScreen())?.then((_) => _loadAllCharts(isRefresh: true)),
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

class SavedChartsList extends StatefulWidget {
  final String mode;
  final String searchQuery;
  final List<Map<String, dynamic>> charts;
  final bool isLoading;
  final Future<void> Function(Map<String, dynamic>) onDelete;
  final Future<void> Function(Map<String, dynamic>, Map<String, dynamic>) onUpdate;
  final Future<void> Function() onRefresh;

  const SavedChartsList({
    super.key, 
    required this.mode, 
    required this.searchQuery, 
    required this.charts, 
    required this.isLoading,
    required this.onDelete,
    required this.onUpdate,
    required this.onRefresh,
  });

  @override
  State<SavedChartsList> createState() => _SavedChartsListState();
}

class _SavedChartsListState extends State<SavedChartsList> {
  final KundliController _kundliController = Get.put(KundliController());
  bool _isProcessing = false;

  Future<void> _deleteChart(int index) async {
    final chart = widget.charts[index];
    final String? chartId = chart['id']?.toString() ?? chart['_id']?.toString();

    if (chartId != null) {
      setState(() => _isProcessing = true);
      try {
        final apiService = Get.find<ApiService>();
        final success = await apiService.deleteChart(chartId);
        widget.onDelete(chart);
        if (success) {
          Get.snackbar('Deleted', 'Profile removed from saved charts.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade100);
        } else {
          Get.snackbar('Deleted', 'Profile removed locally (API sync failed).', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange.shade100);
        }
      } catch (e) {
        print("API delete failed: $e");
        widget.onDelete(chart);
        Get.snackbar('Deleted', 'Profile removed locally (Offline).', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange.shade100);
      } finally {
        setState(() => _isProcessing = false);
      }
    } else {
      widget.onDelete(chart);
      Get.snackbar('Deleted', 'Local profile removed.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade100);
    }
  }

  void _showEditDialog(Map<String, dynamic> chart, int index) {
    Get.to(() => BirthFormScreen(
      initialChart: chart,
    ))?.then((_) => widget.onRefresh());
  }

  void _openChart(Map<String, dynamic> chart) async {
    setState(() => _isProcessing = true);
    try {
      await _kundliController.fetchKundli(
        chart['name'],
        chart['date'],
        chart['time'],
        (chart['lat'] as num).toDouble(),
        (chart['lon'] as num).toDouble(),
      );
      setState(() => _isProcessing = false);
      if (_kundliController.kundliData.value != null) {
        if (widget.mode == 'Premium') {
          Get.to(() => const PremiumKundliScreen());
        } else {
          Get.to(() => const KundliScreen(initialTabIdx: 1));
        }
      } else {
        Get.snackbar('Error', 'Failed to calculate Kundli calculations.');
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading || _isProcessing) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 6,
        itemBuilder: (context, index) => _buildSkeletonCard(),
      );
    }

    if (widget.charts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: widget.charts.length,
        itemBuilder: (context, index) {
          final item = widget.charts[index];
          return _buildChartCard(item, index);
        },
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(height: 14, width: 150, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 8),
                Container(height: 10, width: 100, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 6),
                Container(height: 10, width: 80, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4))),
              ],
            ),
          )
        ],
      )
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
            Text(
              widget.searchQuery.isNotEmpty ? 'No Matching Charts' : 'No Saved ${widget.mode} Profiles',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              widget.searchQuery.isNotEmpty 
                  ? 'Try searching with a different name.' 
                  : 'Charts you generate in ${widget.mode} mode will be saved here for instant access.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textLight, fontSize: 13),
            ),
            const SizedBox(height: 24),
            if (widget.searchQuery.isEmpty)
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create New Chart'),
                onPressed: () => Get.to(() => BirthFormScreen()),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              onPressed: () => _showEditDialog(item, index),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400),
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text('Delete Kundli', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    content: const Text('Are you sure you want to delete this saved chart?', style: TextStyle(color: Colors.black87)),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
                        onPressed: () {
                          Get.back();
                          _deleteChart(index);
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        onTap: () => _openChart(item),
      ),
    );
  }
}
