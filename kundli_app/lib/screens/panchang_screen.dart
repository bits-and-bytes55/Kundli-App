import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/panchang_controller.dart';
import '../theme/app_theme.dart';
import '../theme/custom_shadows.dart';

class PanchangScreen extends StatefulWidget {
  const PanchangScreen({super.key});

  @override
  State<PanchangScreen> createState() => _PanchangScreenState();
}

class _PanchangScreenState extends State<PanchangScreen> with SingleTickerProviderStateMixin {
  final panchangController = Get.put(PanchangController());
  late TabController _choghadiyaTabController;

  @override
  void initState() {
    super.initState();
    _choghadiyaTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _choghadiyaTabController.dispose();
    super.dispose();
  }

  // Helper to open Date Picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime initial = DateTime.tryParse(panchangController.selectedDate.value) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      String formatted = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      panchangController.updateDate(formatted);
    }
  }

  // Helper to open Time Picker
  Future<void> _selectTime(BuildContext context) async {
    final now = DateTime.now();
    TimeOfDay initial = const TimeOfDay(hour: 12, minute: 0);
    if (panchangController.selectedTime.value.contains(':')) {
      final parts = panchangController.selectedTime.value.split(':');
      initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      String formatted = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      panchangController.updateTime(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBg,
        image: DecorationImage(
          image: AssetImage('assets/images/ChatGPT Image Jun 14, 2026, 10_51_39 PM.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Detailed Panchang'),
          backgroundColor: Colors.white.withOpacity(0.9),
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
            onPressed: () => Get.back(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
              onPressed: () => panchangController.fetchPanchang(),
            ),
          ],
        ),
        body: Obx(() {
          if (panchangController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final data = panchangController.panchangData.value;
          if (data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load Panchang data.', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => panchangController.fetchPanchang(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Date & Time Selector Header ──────────────────────────────────
                _buildDatePickerHeader(context),
                const SizedBox(height: 20),

                // ── Today's Sun & Moon Banner ────────────────────────────────────
                _buildSunMoonBanner(data['sun_moon_timings'], data['astrological_details']),
                const SizedBox(height: 20),

                // ── Samvat & Masa Card ──────────────────────────────────────────
                _buildSamvatCard(data['samvat'], data['astrological_details']),
                const SizedBox(height: 20),

                // ── Five Limbs (Panchang) Card ───────────────────────────────────
                const Text(
                  'Five Limbs (पंच अंग)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 10),
                _buildPanchangLimbsCard(data),
                const SizedBox(height: 24),

                // ── Auspicious & Inauspicious Times ─────────────────────────────
                const Text(
                  'Auspicious & Inauspicious Hours',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 10),
                _buildMuhuratasCard(data),
                const SizedBox(height: 24),

                // ── Choghadiya Explorer ─────────────────────────────────────────
                const Text(
                  'Choghadiya Timings (चोघड़िया)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 10),
                _buildChoghadiyaCard(data['choghadiya']),
                const SizedBox(height: 30),
              ],
            ),
          );
        }),
      ),
    );
  }

  // 1. DATE & TIME SELECTOR HEADER
  Widget _buildDatePickerHeader(BuildContext context) {
    DateTime parsedDate = DateTime.tryParse(panchangController.selectedDate.value) ?? DateTime.now();
    String formattedDateLabel = DateFormat('EEEE, d MMMM yyyy').format(parsedDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
        boxShadow: CustomShadows.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  panchangController.placeName.value,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark),
                ),
              ),
              Text(
                'Coordinates: ${panchangController.latitude.value.toStringAsFixed(3)}, ${panchangController.longitude.value.toStringAsFixed(3)}',
                style: const TextStyle(fontSize: 11, color: AppColors.textLight),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Date', style: TextStyle(fontSize: 10, color: AppColors.textLight, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(
                                formattedDateLabel,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Calculation Time', style: TextStyle(fontSize: 10, color: AppColors.textLight, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(
                                panchangController.selectedTime.value,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Timezone: ${panchangController.panchangData.value?['timezone'] ?? ''}',
              style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  // 2. SUN & MOON TIMINGS BANNER
  Widget _buildSunMoonBanner(Map<String, dynamic> timings, Map<String, dynamic> astro) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE28A32), Color(0xFF6B3BA7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: CustomShadows.cardShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.wb_sunny_rounded, size: 120, color: Colors.white.withOpacity(0.08)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Sunrise
                    _buildTimingCell(
                      Icons.wb_sunny_rounded, 
                      'SUNRISE', 
                      timings['sunrise'] ?? '', 
                      const Color(0xFFFFEB3B),
                    ),
                    // Vertical Divider
                    Container(height: 40, width: 1, color: Colors.white24),
                    // Sunset
                    _buildTimingCell(
                      Icons.wb_twilight_rounded, 
                      'SUNSET', 
                      timings['sunset'] ?? '', 
                      const Color(0xFFFF7043),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Moonrise
                    _buildTimingCell(
                      Icons.brightness_3_rounded, 
                      'MOONRISE', 
                      timings['moonrise'] ?? '', 
                      const Color(0xFFE0F7FA),
                    ),
                    // Vertical Divider
                    Container(height: 40, width: 1, color: Colors.white24),
                    // Moonset
                    _buildTimingCell(
                      Icons.nightlight_round, 
                      'MOONSET', 
                      timings['moonset'] ?? '', 
                      const Color(0xFFB0BEC5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingCell(IconData icon, String label, String time, Color iconColor) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white70, letterSpacing: 1.1),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ],
    );
  }

  // 3. SAMVAT & MASA CARD
  Widget _buildSamvatCard(Map<String, dynamic> samvat, Map<String, dynamic> astro) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
        boxShadow: CustomShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vedic Calendar (पंचांग विवरण)',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
          _buildSamvatRow('Vikram Samvat', '${samvat['vikram']} (विग्रह संवत)'),
          _buildSamvatRow('Saka Samvat', '${samvat['saka']} (शालिवाहन संवत)'),
          _buildSamvatRow('Hindu Month (Masa)', '${samvat['masa']} (मास)'),
          _buildSamvatRow('Ritu (Season)', '${astro['ritu']} (ऋतु)'),
          _buildSamvatRow('Ayanamsha', '${astro['ayanamsha']} (Lahiri)'),
          _buildSamvatRow('Solar Sign (Sun)', '${astro['sun_rashi']} (सूर्य राशि)'),
          _buildSamvatRow('Lunar Sign (Moon)', '${astro['moon_rashi']} (चंद्र राशि)'),
        ],
      ),
    );
  }

  Widget _buildSamvatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMedium, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // 4. FIVE LIMBS CARD
  Widget _buildPanchangLimbsCard(Map<String, dynamic> data) {
    final tithi = data['tithi'];
    final nakshatra = data['nakshatra'];
    final yoga = data['yoga'];
    final karana = data['karana'];
    final vara = data['vara'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
        boxShadow: CustomShadows.cardShadow,
      ),
      child: Column(
        children: [
          // Tithi
          _buildLimbItem(
            'Tithi (तिथि)', 
            '${tithi['paksha']} Paksha • ${tithi['name']}', 
            '${tithi['percent_elapsed']}% elapsed',
            tithi['percent_elapsed'] / 100.0,
            Icons.brightness_4_rounded,
            Colors.amber,
          ),
          const Divider(height: 24, thickness: 0.8),
          
          // Nakshatra
          _buildLimbItem(
            'Nakshatra (नक्षत्र)', 
            '${nakshatra['name']} (Pada ${nakshatra['pada']})', 
            'Lord: ${nakshatra['lord']} • ${nakshatra['percent_elapsed']}% elapsed',
            nakshatra['percent_elapsed'] / 100.0,
            Icons.star_rounded,
            Colors.purple,
          ),
          const Divider(height: 24, thickness: 0.8),

          // Yoga
          _buildLimbItem(
            'Yoga (योग)', 
            '${yoga['name']}', 
            '${yoga['percent_elapsed']}% elapsed',
            yoga['percent_elapsed'] / 100.0,
            Icons.gesture_rounded,
            Colors.teal,
          ),
          const Divider(height: 24, thickness: 0.8),

          // Karana
          _buildLimbItemSimple(
            'Karana (करण)', 
            '${karana['name']}', 
            karana['is_bhadra'] ? 'Bhadra (Vishti) Active' : 'Normal auspicious period',
            Icons.pie_chart_rounded,
            karana['is_bhadra'] ? Colors.red : Colors.blue,
            badge: karana['is_bhadra'] ? 'Inauspicious (भद्रा)' : null,
          ),
          const Divider(height: 24, thickness: 0.8),

          // Weekday
          _buildLimbItemSimple(
            'Vara (वार / दिन)', 
            'Astrological: ${vara['astrological']}', 
            'Calendar: ${vara['calendar']}' + (vara['is_before_sunrise'] ? '\n(Born before sunrise, using previous day)' : ''),
            Icons.calendar_today_rounded,
            Colors.indigo,
          ),
        ],
      ),
    );
  }

  Widget _buildLimbItem(String title, String value, String subtitle, double progress, IconData icon, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor.withOpacity(0.12)),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight),
              ),
              const SizedBox(height: 3),
              Text(
                value, 
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: iconColor.withOpacity(0.1),
                  color: iconColor,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle, 
                style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLimbItemSimple(String title, String value, String subtitle, IconData icon, Color iconColor, {String? badge}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor.withOpacity(0.12)),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title, 
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
                      child: Text(badge, style: TextStyle(color: Colors.red.shade800, fontSize: 9, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(
                value, 
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle, 
                style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 5. AUSPICIOUS & INAUSPICIOUS TIMES CARD
  Widget _buildMuhuratasCard(Map<String, dynamic> data) {
    final auspicious = data['auspicious_timings'];
    final inauspicious = data['inauspicious_timings'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
        boxShadow: CustomShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Abhijit
          _buildTimingRow(
            'Abhijit Muhurta', 
            '${auspicious['abhijit']['start']} - ${auspicious['abhijit']['end']}', 
            'Highly auspicious midday period. Best for starting new activities.',
            true,
          ),
          const Divider(height: 24, thickness: 0.8),
          
          // Rahu Kaal
          _buildTimingRow(
            'Rahu Kaal', 
            '${inauspicious['rahu_kaal']['start']} - ${inauspicious['rahu_kaal']['end']}', 
            'Inauspicious. Avoid starting new ventures or travel.',
            false,
          ),
          const Divider(height: 24, thickness: 0.8),

          // Yamaganda
          _buildTimingRow(
            'Yamaganda Kaal', 
            '${inauspicious['yamaganda']['start']} - ${inauspicious['yamaganda']['end']}', 
            'Inauspicious. Generally avoided for important ceremonies.',
            false,
          ),
          const Divider(height: 24, thickness: 0.8),

          // Gulika
          _buildTimingRow(
            'Gulika Kaal', 
            '${inauspicious['gulika']['start']} - ${inauspicious['gulika']['end']}', 
            'Generally neutral/inauspicious. Delayed results.',
            false,
            isOrange: true,
          ),

          // Dur Muhurtam list if present
          if (inauspicious['dur_muhurtam'] != null && (inauspicious['dur_muhurtam'] as List).isNotEmpty) ...[
            const Divider(height: 24, thickness: 0.8),
            const Text(
              'Dur Muhurtam (दुर्मुहूर्त समय)',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            ...(inauspicious['dur_muhurtam'] as List).map((dm) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dm['name'] ?? 'Dur Muhurtam',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMedium, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '${dm['start']} - ${dm['end']}',
                      style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildTimingRow(String name, String time, String desc, bool isAuspicious, {bool isOrange = false}) {
    Color badgeColor = isAuspicious 
        ? Colors.green.shade700 
        : (isOrange ? Colors.orange.shade800 : Colors.red.shade700);
    Color badgeBg = isAuspicious 
        ? Colors.green.shade50 
        : (isOrange ? Colors.orange.shade50 : Colors.red.shade50);
    String typeLabel = isAuspicious ? 'AUSPICIOUS' : 'INAUSPICIOUS';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
              child: Text(
                typeLabel,
                style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: badgeColor),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          style: const TextStyle(fontSize: 11, color: AppColors.textLight),
        ),
      ],
    );
  }

  // 6. CHOGHADIYA CARD
  Widget _buildChoghadiyaCard(Map<String, dynamic> choghadiya) {
    final dayChog = choghadiya['day'] as List<dynamic>? ?? [];
    final nightChog = choghadiya['night'] as List<dynamic>? ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
        boxShadow: CustomShadows.cardShadow,
      ),
      child: Column(
        children: [
          TabBar(
            controller: _choghadiyaTabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textLight,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(text: 'Day (दिन का चोघड़िया)', icon: Icon(Icons.wb_sunny_rounded, size: 18)),
              Tab(text: 'Night (रात का चोघड़िया)', icon: Icon(Icons.nightlight_round, size: 18)),
            ],
          ),
          SizedBox(
            height: 380,
            child: TabBarView(
              controller: _choghadiyaTabController,
              children: [
                _buildChoghadiyaList(dayChog),
                _buildChoghadiyaList(nightChog),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoghadiyaList(List<dynamic> list) {
    if (list.isEmpty) {
      return const Center(child: Text('No Choghadiya timings available.'));
    }
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
      itemBuilder: (context, idx) {
        final item = list[idx];
        final String name = item['name'];
        final String type = item['type'];
        final String translation = item['translation'];
        final String start = item['start'];
        final String end = item['end'];

        Color textCol = Colors.grey;
        Color bgCol = Colors.transparent;

        if (type == 'Good') {
          textCol = Colors.green.shade800;
          bgCol = Colors.green.shade50.withOpacity(0.8);
        } else if (type == 'Bad') {
          textCol = Colors.red.shade800;
          bgCol = Colors.red.shade50.withOpacity(0.8);
        } else {
          textCol = Colors.blue.shade800;
          bgCol = Colors.blue.shade50.withOpacity(0.8);
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bgCol,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Period circle
              Container(
                alignment: Alignment.center,
                width: 22,
                height: 22,
                decoration: BoxDecoration(shape: BoxShape.circle, color: textCol.withOpacity(0.15)),
                child: Text(
                  '${item['period']}',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textCol),
                ),
              ),
              const SizedBox(width: 14),
              // Name and meaning
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textCol),
                    ),
                    Text(
                      '$translation • $type',
                      style: TextStyle(fontSize: 10, color: textCol.withOpacity(0.8), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // Timings
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$start - $end',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
