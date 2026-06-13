import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kundli_controller.dart';
import '../theme/custom_shadows.dart';

class MilanScreen extends StatefulWidget {
  const MilanScreen({super.key});
  @override State<MilanScreen> createState() => _MilanScreenState();
}

class _MilanScreenState extends State<MilanScreen> {
  final _formKey = GlobalKey<FormState>();
  final boyName = TextEditingController(text: 'Rahul');
  final boyDate = TextEditingController(text: '1995-03-15');
  final boyTime = TextEditingController(text: '10:00');
  final girlName = TextEditingController(text: 'Priya');
  final girlDate = TextEditingController(text: '1997-08-20');
  final girlTime = TextEditingController(text: '08:30');
  var result = Rx<Map<String, dynamic>?>(null);
  var loading = false.obs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/bg_floral.png'), fit: BoxFit.fill)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.95),
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFFF7E93)), onPressed: () => Get.back()),
          title: const Text('Kundli Milan', style: TextStyle(color: Color(0xFFFF7E93), fontWeight: FontWeight.bold)),
        ),
        body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Form(
          key: _formKey,
          child: Column(children: [
            _personCard('Boy / Var', boyName, boyDate, boyTime, const Color(0xFF2196F3)),
            const SizedBox(height: 12),
            _personCard('Girl / Vadhu', girlName, girlDate, girlTime, const Color(0xFFE91E63)),
            const SizedBox(height: 20),
            Obx(() => loading.value
              ? const CircularProgressIndicator(color: Color(0xFFFF7E93))
              : SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  icon: const Icon(Icons.favorite_rounded),
                  label: const Text('Match Kundli (मिलान करें)'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7E93), padding: const EdgeInsets.all(16)),
                  onPressed: _doMilan))),
            const SizedBox(height: 20),
            Obx(() => result.value == null ? const SizedBox() : _resultWidget(result.value!)),
          ]),
        )),
      ),
    );
  }

  Widget _personCard(String title, TextEditingController name, TextEditingController date, TextEditingController time, Color color) {
    return Card(
      color: Colors.white.withOpacity(0.95),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: color.withOpacity(0.3))),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.15), radius: 16,
            child: Icon(title.contains('Boy') ? Icons.male_rounded : Icons.female_rounded, color: color, size: 18)),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
        ]),
        const SizedBox(height: 12),
        TextFormField(controller: name, decoration: const InputDecoration(hintText: 'Full Name', prefixIcon: Icon(Icons.person_outline_rounded)),
          validator: (v) => v!.isEmpty ? 'Required' : null),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: TextFormField(controller: date, readOnly: true,
            decoration: const InputDecoration(hintText: 'Date of Birth', prefixIcon: Icon(Icons.calendar_today_rounded)),
            onTap: () => _pickDate(date), validator: (v) => v!.isEmpty ? 'Required' : null)),
          const SizedBox(width: 10),
          Expanded(child: TextFormField(controller: time, readOnly: true,
            decoration: const InputDecoration(hintText: 'Time', prefixIcon: Icon(Icons.access_time_rounded)),
            onTap: () => _pickTime(time), validator: (v) => v!.isEmpty ? 'Required' : null)),
        ]),
      ])),
    );
  }

  Widget _resultWidget(Map<String, dynamic> r) {
    final total = (r['total_score'] as num?)?.toInt() ?? 0;
    final pct = (r['percentage'] as num?)?.toDouble() ?? 0;
    final verdict = r['verdict'] as String? ?? '';
    final scores = r['scores'] as Map<String, dynamic>? ?? {};
    final doshas = r['doshas'] as Map<String, dynamic>? ?? {};
    return Card(
      elevation: 4, color: Colors.white.withOpacity(0.97),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Column(children: [
          Stack(alignment: Alignment.center, children: [
            SizedBox(width: 120, height: 120, child: CircularProgressIndicator(
              value: pct / 100, strokeWidth: 10,
              backgroundColor: Colors.grey.shade200,
              color: pct >= 75 ? Colors.green : pct >= 50 ? Colors.orange : Colors.red)),
            Column(children: [
              Text('$total/36', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFF7E93))),
              Text('${pct.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D))),
            ]),
          ]),
          const SizedBox(height: 12),
          Text(verdict, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        ])),
        const Divider(height: 24, color: Color(0xFFD5F3D8)),
        const Text('Ashtakoot Scores', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2C3E50))),
        const SizedBox(height: 10),
        ...scores.entries.map((e) {
          final s = e.value as Map<String, dynamic>;
          int got = (s['score'] as num?)?.toInt() ?? 0;
          int max = (s['max'] as num?)?.toInt() ?? 0;
          return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
            SizedBox(width: 110, child: Text(e.key.replaceAll('_', ' '), style: const TextStyle(fontSize: 13, color: Color(0xFF2C3E50)))),
            Expanded(child: LinearProgressIndicator(value: max > 0 ? got / max : 0,
              backgroundColor: Colors.grey.shade200, color: got >= max * 0.7 ? Colors.green : got >= max * 0.4 ? Colors.orange : Colors.red,
              minHeight: 8, borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 8),
            Text('$got/$max', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFFF7E93))),
          ]));
        }).toList(),
        const Divider(height: 24, color: Color(0xFFD5F3D8)),
        if ((doshas['report'] as String? ?? '').isNotEmpty)
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200)),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
              const SizedBox(width: 6),
              Expanded(child: Text(doshas['report'] as String? ?? '', style: const TextStyle(color: Colors.red, fontSize: 12))),
            ])),
      ])),
    );
  }

  void _doMilan() async {
    if (!_formKey.currentState!.validate()) return;
    loading.value = true;
    try {
      final c = Get.find<KundliController>();
      final data = await c.apiService.matchMilan(
        boyName: boyName.text, boyDate: boyDate.text, boyTime: boyTime.text, boyLat: 28.6139, boyLon: 77.209,
        girlName: girlName.text, girlDate: girlDate.text, girlTime: girlTime.text, girlLat: 28.6139, girlLon: 77.209,
      );
      result.value = data;
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
    } finally {
      loading.value = false;
    }
  }

  void _pickDate(TextEditingController ctrl) async {
    DateTime? d = await showDatePicker(context: context,
      initialDate: DateTime(1995), firstDate: DateTime(1900), lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(
        colorScheme: const ColorScheme.light(primary: Color(0xFFFF7E93))), child: child!));
    if (d != null) ctrl.text = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  }

  void _pickTime(TextEditingController ctrl) async {
    TimeOfDay? t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(
        colorScheme: const ColorScheme.light(primary: Color(0xFFFF7E93))), child: child!));
    if (t != null) ctrl.text = '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
  }
}
