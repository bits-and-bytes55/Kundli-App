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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          title: const Text('Saved Charts (कुंडली संग्रह)'),
          elevation: 0.5,
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
                          })
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SavedChartsList(mode: 'Basic', searchQuery: _searchQuery),
                  SavedChartsList(mode: 'Premium', searchQuery: _searchQuery),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => Get.to(() => BirthFormScreen()),
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

class SavedChartsList extends StatefulWidget {
  final String mode;
  final String searchQuery;

  const SavedChartsList({super.key, required this.mode, required this.searchQuery});

  @override
  State<SavedChartsList> createState() => _SavedChartsListState();
}

class _SavedChartsListState extends State<SavedChartsList> {
  final KundliController _kundliController = Get.put(KundliController());
  List<Map<String, dynamic>> _savedCharts = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  int _page = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCharts(isRefresh: true);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isFetchingMore && _hasMore && !_isLoading) {
          _loadCharts(isRefresh: false);
        }
      }
    });
  }

  @override
  void didUpdateWidget(SavedChartsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _loadCharts(isRefresh: true);
    }
  }

  Future<void> _loadCharts({bool isRefresh = true}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _page = 1;
        _hasMore = true;
      });
    } else {
      setState(() => _isFetchingMore = true);
    }
    final prefs = await SharedPreferences.getInstance();
    final String phone = prefs.getString('logged_phone') ?? '9999999999';

    try {
      final apiService = Get.find<ApiService>();
      final apiListRaw = await apiService.getSavedCharts(phone, query: widget.searchQuery, mode: widget.mode, page: _page, limit: 100);
      if (apiListRaw != null) {
        // Local filtering to support production backend not having mode yet
        final apiList = apiListRaw.where((chart) => (chart['mode'] ?? 'Basic') == widget.mode).toList();
        setState(() {
          if (isRefresh) {
            _savedCharts = apiList;
          } else {
            _savedCharts.addAll(apiList);
          }
          if (apiList.length < 20) {
            _hasMore = false;
          } else {
            _page++;
          }
        });
        if (isRefresh && widget.searchQuery.isEmpty) {
          await prefs.setString('saved_charts_${widget.mode}', jsonEncode(apiList));
        }
        setState(() {
          _isLoading = false;
          _isFetchingMore = false;
        });
        return;
      }
    } catch (e) {
      print("API getSavedCharts failed: $e");
    }

    if (isRefresh && widget.searchQuery.isEmpty) {
      final raw = prefs.getString('saved_charts_${widget.mode}');
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
    }
    setState(() {
      _isLoading = false;
      _isFetchingMore = false;
    });
  }

  Future<void> _deleteChart(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final chart = _savedCharts[index];
    final String? chartId = chart['id']?.toString() ?? chart['_id']?.toString();

    setState(() {
      _savedCharts.removeAt(index);
    });
    await prefs.setString('saved_charts_${widget.mode}', jsonEncode(_savedCharts));

    if (chartId != null) {
      try {
        final apiService = Get.find<ApiService>();
        await apiService.deleteChart(chartId);
      } catch (e) {
        print("API delete failed: $e");
      }
    }
    Get.snackbar('Deleted', 'Profile removed from saved charts.', snackPosition: SnackPosition.BOTTOM);
  }

  void _showEditDialog(Map<String, dynamic> chart, int index) {
    final nameCtrl = TextEditingController(text: chart['name']);
    final dateCtrl = TextEditingController(text: chart['date']);
    final timeCtrl = TextEditingController(text: chart['time']);
    final placeCtrl = TextEditingController(text: chart['place']);
    final selectedGender = (chart['gender'] ?? 'Male').toString().obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Edit Chart Details', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(hintText: 'Name'),
              ),
              const SizedBox(height: 12),
              
              const Text('Date of Birth (YYYY-MM-DD)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
              const SizedBox(height: 6),
              TextField(
                controller: dateCtrl,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(hintText: 'e.g. 2005-10-01'),
              ),
              const SizedBox(height: 12),
              
              const Text('Time of Birth (HH:MM)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
              const SizedBox(height: 6),
              TextField(
                controller: timeCtrl,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(hintText: 'e.g. 09:12'),
              ),
              const SizedBox(height: 12),
              
              const Text('Birth Place', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
              const SizedBox(height: 6),
              TextField(
                controller: placeCtrl,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(hintText: 'e.g. New Delhi'),
              ),
              const SizedBox(height: 12),
              
              const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
              const SizedBox(height: 6),
              Obx(() => Row(
                children: [
                  Radio<String>(
                    value: 'Male',
                    groupValue: selectedGender.value,
                    onChanged: (v) => selectedGender.value = v!,
                  ),
                  const Text('Male', style: TextStyle(color: Colors.black)),
                  const SizedBox(width: 12),
                  Radio<String>(
                    value: 'Female',
                    groupValue: selectedGender.value,
                    onChanged: (v) => selectedGender.value = v!,
                  ),
                  const Text('Female', style: TextStyle(color: Colors.black)),
                ],
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              setState(() => _isLoading = true);
              try {
                double lat = (chart['lat'] as num? ?? 28.6139).toDouble();
                double lon = (chart['lon'] as num? ?? 77.2090).toDouble();
                if (placeCtrl.text != chart['place']) {
                  try {
                    List<Location> locations = await locationFromAddress(placeCtrl.text);
                    if (locations.isNotEmpty) {
                      lat = locations.first.latitude;
                      lon = locations.first.longitude;
                    }
                  } catch (e) {
                    print("Geocoding failed during edit: $e");
                  }
                }

                final String? chartId = chart['id']?.toString() ?? chart['_id']?.toString();
                if (chartId != null) {
                  final apiService = Get.find<ApiService>();
                  final success = await apiService.editChart(
                    id: chartId,
                    name: nameCtrl.text,
                    date: dateCtrl.text,
                    time: timeCtrl.text,
                    lat: lat,
                    lon: lon,
                    gender: selectedGender.value,
                    place: placeCtrl.text,
                  );
                  if (success) {
                    Get.snackbar('Success', 'Chart updated successfully!', backgroundColor: Colors.green.shade100);
                  } else {
                    Get.snackbar('Error', 'Failed to update chart in API');
                  }
                }

                final prefs = await SharedPreferences.getInstance();
                _savedCharts[index] = {
                  'id': chartId,
                  'name': nameCtrl.text,
                  'date': dateCtrl.text,
                  'time': timeCtrl.text,
                  'place': placeCtrl.text,
                  'lat': lat,
                  'lon': lon,
                  'gender': selectedGender.value,
                };
                await prefs.setString('saved_charts_${widget.mode}', jsonEncode(_savedCharts));

                await _loadCharts(isRefresh: true);
              } catch (e) {
                Get.snackbar('Error', 'Failed to save: $e');
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
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
        if (widget.mode == 'Premium') {
          Get.to(() => const PremiumKundliScreen());
        } else {
          Get.to(() => const KundliScreen(initialTabIdx: 1));
        }
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
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 6,
        itemBuilder: (context, index) => _buildSkeletonCard(),
      );
    }

    if (_savedCharts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadCharts(isRefresh: true),
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _savedCharts.length + (_isFetchingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _savedCharts.length) {
            return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.primary)));
          }
          final item = _savedCharts[index];
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
