import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math' as math;
import '../../theme/app_theme.dart';
import 'chart_tab.dart';

class DirectionMatchScreen extends StatefulWidget {
  final String birthPlace;
  final int lagnaHouse;
  final int moonHouse;
  final int nameRashiHouse;
  final String name;
  final Map<String, dynamic> ascendant;
  final Map<String, dynamic> planets;
  final Map<String, dynamic> kpAscendant;
  final Map<String, dynamic> kpPlanets;

  const DirectionMatchScreen({
    Key? key,
    required this.birthPlace,
    required this.lagnaHouse,
    required this.moonHouse,
    required this.nameRashiHouse,
    required this.name,
    required this.ascendant,
    required this.planets,
    required this.kpAscendant,
    required this.kpPlanets,
  }) : super(key: key);

  @override
  _DirectionMatchScreenState createState() => _DirectionMatchScreenState();
}

class _DirectionMatchScreenState extends State<DirectionMatchScreen> {
  final TextEditingController _currentPlaceController1 = TextEditingController();
  final TextEditingController _residencePlaceController = TextEditingController();
  final TextEditingController _currentPlaceController2 = TextEditingController();
  
  bool _isLoading = false;
  bool _showResults = false;
  int _activeResultTabIndex = 0; // 0 = Birth -> Current, 1 = Residence -> Current
  
  Map<String, dynamic>? _birthData;
  Map<String, dynamic>? _residenceData;

  Future<void> _calculateDirection() async {
    final current1 = _currentPlaceController1.text.trim();
    final residence = _residencePlaceController.text.trim();
    final current2 = _currentPlaceController2.text.trim();

    if (current1.isEmpty && (residence.isEmpty || current2.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill at least one form completely')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (current1.isNotEmpty) {
        _birthData = await _getDirectionData(widget.birthPlace, current1);
        _birthData!['place'] = current1;
        _birthData!['source'] = widget.birthPlace;
      } else {
        _birthData = null;
      }

      if (residence.isNotEmpty && current2.isNotEmpty) {
        _residenceData = await _getDirectionData(residence, current2);
        _residenceData!['place'] = current2;
        _residenceData!['source'] = residence;
      } else {
        _residenceData = null;
      }

      setState(() {
        _showResults = true;
        _isLoading = false;
        _activeResultTabIndex = (_birthData != null) ? 0 : 1;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<Map<String, dynamic>> _getDirectionData(String birthPlace, String targetPlace) async {
    List<Location> birthLocs = await locationFromAddress(birthPlace);
    List<Location> targetLocs = await locationFromAddress(targetPlace);

    if (birthLocs.isEmpty || targetLocs.isEmpty) {
      throw Exception("Could not find coordinates for the given places.");
    }

    Location birth = birthLocs.first;
    Location curr = targetLocs.first;

    double bearing = _calculateBearing(birth.latitude, birth.longitude, curr.latitude, curr.longitude);
    return _mapBearingToHouseData(bearing);
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    double rLat1 = lat1 * math.pi / 180.0;
    double rLat2 = lat2 * math.pi / 180.0;
    double dLon = (lon2 - lon1) * math.pi / 180.0;

    double y = math.sin(dLon) * math.cos(rLat2);
    double x = math.cos(rLat1) * math.sin(rLat2) - math.sin(rLat1) * math.cos(rLat2) * math.cos(dLon);
    double brng = math.atan2(y, x);

    return (brng * 180.0 / math.pi + 360.0) % 360.0;
  }

  Map<String, dynamic> _mapBearingToHouseData(double angle) {
    int zone = ((angle + 11.25) / 22.5).floor() % 16;
    String dirName = '';
    int dirHouse = 1;
    switch (zone) {
      case 0: dirName = 'North (N)'; dirHouse = 6; break;
      case 1: dirName = 'North-North-East (NNE)'; dirHouse = 4; break;
      case 2: dirName = 'North-East (NE)'; dirHouse = 9; break;
      case 3: dirName = 'East-North-East (ENE)'; dirHouse = 5; break;
      case 4: dirName = 'East (E)'; dirHouse = 1; break;
      case 5: dirName = 'East-South-East (ESE)'; dirHouse = 12; break;
      case 6: dirName = 'South-East (SE)'; dirHouse = 12; break;
      case 7: dirName = 'South-South-East (SSE)'; dirHouse = 10; break;
      case 8: dirName = 'South (S)'; dirHouse = 10; break;
      case 9: dirName = 'South-South-West (SSW)'; dirHouse = 8; break;
      case 10: dirName = 'South-West (SW)'; dirHouse = 8; break;
      case 11: dirName = 'West-South-West (WSW)'; dirHouse = 7; break;
      case 12: dirName = 'West (W)'; dirHouse = 11; break;
      case 13: dirName = 'West-North-West (WNW)'; dirHouse = 2; break;
      case 14: dirName = 'North-West (NW)'; dirHouse = 2; break;
      case 15: dirName = 'North-North-West (NNW)'; dirHouse = 3; break;
    }

    int lagnaCount = ((dirHouse - widget.lagnaHouse + 12) % 12) + 1;
    int moonCount = ((dirHouse - widget.moonHouse + 12) % 12) + 1;
    int nameCount = ((dirHouse - widget.nameRashiHouse + 12) % 12) + 1;
    
    return {
      'name': dirName,
      'house': dirHouse,
      'lagnaCount': lagnaCount,
      'moonCount': moonCount,
      'nameCount': nameCount,
    };
  }

  Widget _buildResultRow(String title, int count) {
    bool isBad = count == 8;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBad ? Colors.red.shade50 : Colors.green.shade50,
        border: Border.all(color: isBad ? Colors.red.shade200 : Colors.green.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Icon(
                isBad ? Icons.cancel_rounded : Icons.check_circle_rounded,
                color: isBad ? Colors.red : Colors.green,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isBad 
              ? 'यह दिशा $title से 8वें भाव में आ रही है, इसलिए यह आपके लिए अनुकूल नहीं है।'
              : 'यह दिशा $title से ${count}वें भाव में है, जो कि अनुकूल है।',
            style: TextStyle(color: isBad ? Colors.red.shade800 : Colors.green.shade800, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _getHindiRashi(int num) {
    const rashis = ['मेष', 'वृषभ', 'मिथुन', 'कर्क', 'सिंह', 'कन्या', 'तुला', 'वृश्चिक', 'धनु', 'मकर', 'कुंभ', 'मीन'];
    return rashis[(num - 1) % 12];
  }

  String _ordinal(int num) {
    if (num == 1) return '1st';
    if (num == 2) return '2nd';
    if (num == 3) return '3rd';
    return '${num}th';
  }

  Widget _buildAllDirectionsTable() {
    final List<Map<String, dynamic>> allDirs = [
      {'name': 'E', 'rashi': 1},
      {'name': 'WNW/NW', 'rashi': 2},
      {'name': 'NNW', 'rashi': 3},
      {'name': 'NNE', 'rashi': 4},
      {'name': 'ENE', 'rashi': 5},
      {'name': 'N', 'rashi': 6},
      {'name': 'WSW', 'rashi': 7},
      {'name': 'SW/SSW', 'rashi': 8},
      {'name': 'NE', 'rashi': 9},
      {'name': 'S/SSE', 'rashi': 10},
      {'name': 'W', 'rashi': 11},
      {'name': 'ESE/SE', 'rashi': 12},
    ];

    String lagnaStr = _getHindiRashi(widget.lagnaHouse);
    String moonStr = _getHindiRashi(widget.moonHouse);
    String nameStr = _getHindiRashi(widget.nameRashiHouse);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 12),
            child: Text(
              'सभी दिशाओं के नंबर (लगन, चंद्र और नाम राशि से)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Table(
            border: TableBorder(
              horizontalInside: BorderSide(color: Colors.grey.shade200),
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
            columnWidths: const {
              0: FlexColumnWidth(1.8),
              1: FlexColumnWidth(1.0),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                children: [
                  Padding(padding: const EdgeInsets.all(8), child: Text('दिशा', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade800))),
                  Padding(padding: const EdgeInsets.all(8), child: Text('राशि', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade800))),
                  Padding(padding: const EdgeInsets.all(8), child: Text('लगन\n($lagnaStr)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade800))),
                  Padding(padding: const EdgeInsets.all(8), child: Text('चंद्र\n($moonStr)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade800))),
                  Padding(padding: const EdgeInsets.all(8), child: Text('नाम राशि\n($nameStr)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade800))),
                ],
              ),
              ...allDirs.map((dir) {
                int rashi = dir['rashi'];
                int lCount = ((rashi - widget.lagnaHouse + 12) % 12) + 1;
                int mCount = ((rashi - widget.moonHouse + 12) % 12) + 1;
                int nCount = ((rashi - widget.nameRashiHouse + 12) % 12) + 1;
                
                final isBadDirName = dir['name'].toString().contains('WNW') || dir['name'].toString().contains('ESE');
                
                return TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(8), child: Text(dir['name'], style: TextStyle(fontSize: 13, fontWeight: isBadDirName ? FontWeight.w900 : FontWeight.bold, color: isBadDirName ? Colors.red : Colors.black87))),
                    Padding(padding: const EdgeInsets.all(8), child: Text('$rashi', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                    Padding(padding: const EdgeInsets.all(8), child: Text(_ordinal(lCount), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: lCount == 8 ? Colors.red : Colors.black87))),
                    Padding(padding: const EdgeInsets.all(8), child: Text(_ordinal(mCount), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: mCount == 8 ? Colors.red : Colors.black87))),
                    Padding(padding: const EdgeInsets.all(8), child: Text(_ordinal(nCount), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: nCount == 8 ? Colors.red : Colors.black87))),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionTab(Map<String, dynamic> data) {
    final String dirName = data['name'];
    final dirHouse = data['house'];
    final lCount = data['lagnaCount'];
    final mCount = data['moonCount'];
    final nCount = data['nameCount'];
    final place = data['place'];
    
    final bool isBadDirName = dirName.contains('WNW') || dirName.contains('ESE');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Chart for: $place',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
        ChartTab(
          ascendant: widget.ascendant,
          planets: widget.planets,
          kpAscendant: widget.kpAscendant,
          kpPlanets: widget.kpPlanets,
          showDirections: true,
          targetHouseCrossIdx: dirHouse,
          isTargetDirectionBad: (lCount == 8 || mCount == 8 || nCount == 8),
          onlyChart: true,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.explore_rounded, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Direction: $dirName',
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: isBadDirName ? FontWeight.w900 : FontWeight.bold,
                          color: isBadDirName ? Colors.red : Colors.black87
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildResultRow('लग्न (Ascendant)', lCount),
                _buildResultRow('चंद्र (Moon Sign)', mCount),
                _buildResultRow('नाम राशि (${widget.name})', nCount),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildAllDirectionsTable(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(!_showResults ? 16 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_showResults)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Form 1: From Birth Place', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: widget.birthPlace,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Birth Place', border: OutlineInputBorder(), filled: true, fillColor: Colors.black12),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _currentPlaceController1,
                        decoration: const InputDecoration(labelText: 'Current Place', border: OutlineInputBorder(), hintText: 'Enter current city'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Form 2: From Residence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _residencePlaceController,
                        decoration: const InputDecoration(labelText: 'Residence Location', border: OutlineInputBorder(), hintText: 'Enter residence city'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _currentPlaceController2,
                        decoration: const InputDecoration(labelText: 'Current Place', border: OutlineInputBorder(), hintText: 'Enter current city'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _calculateDirection,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Check Direction Match', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          
          if (_showResults && (_birthData != null || _residenceData != null)) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Astro-Vastu Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () => setState(() => _showResults = false),
                    icon: const Icon(Icons.edit_location_alt_rounded, size: 18),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                  ),
                ],
              ),
            ),
            if (_birthData != null && _residenceData != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeResultTabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(color: _activeResultTabIndex == 0 ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(16)),
                          child: Text('From Birth Place', textAlign: TextAlign.center, style: TextStyle(color: _activeResultTabIndex == 0 ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeResultTabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(color: _activeResultTabIndex == 1 ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(16)),
                          child: Text('From Residence', textAlign: TextAlign.center, style: TextStyle(color: _activeResultTabIndex == 1 ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _buildPredictionTab((_activeResultTabIndex == 0 && _birthData != null) ? _birthData! : _residenceData!),
          ]
        ],
      ),
    );
  }
}
