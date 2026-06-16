import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kundli_controller.dart';
import '../theme/app_theme.dart';
import 'milan_result_screen.dart';

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
  void initState() {
    super.initState();
    if (!Get.isRegistered<KundliController>()) {
      Get.lazyPut(() => KundliController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/ChatGPT Image Jun 14, 2026, 10_51_39 PM.png'), fit: BoxFit.fill)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.95),
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary), onPressed: () => Get.back()),
          title: const Text('Kundli Milan', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
        body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Form(
          key: _formKey,
          child: Column(children: [
            _personCard('Boy / Var', boyName, boyDate, boyTime, const Color(0xFF2196F3)),
            const SizedBox(height: 12),
            _personCard('Girl / Vadhu', girlName, girlDate, girlTime, const Color(0xFFE91E63)),
            const SizedBox(height: 20),
            Obx(() => loading.value
              ? const CircularProgressIndicator(color: AppColors.primary)
              : SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  icon: const Icon(Icons.favorite_rounded),
                  label: const Text('Match Kundli (मिलान करें)'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.all(16)),
                  onPressed: _doMilan))),
            const SizedBox(height: 20),
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

  void _doMilan() async {
    if (!_formKey.currentState!.validate()) return;
    loading.value = true;
    try {
      final c = Get.find<KundliController>();
      print('=== API HIT: matchMilan ===');
      print('Boy: ${boyName.text}, ${boyDate.text}, ${boyTime.text}');
      print('Girl: ${girlName.text}, ${girlDate.text}, ${girlTime.text}');
      final data = await c.apiService.matchMilan(
        boyName: boyName.text, boyDate: boyDate.text, boyTime: boyTime.text, boyLat: 28.6139, boyLon: 77.209,
        girlName: girlName.text, girlDate: girlDate.text, girlTime: girlTime.text, girlLat: 28.6139, girlLon: 77.209,
      );
      print('=== RESPONSE BODY: $data ===');
      if (data != null) {
        Get.to(() => MilanResultScreen(resultData: data));
      } else {
        Get.snackbar('Error', 'Failed to match Milan details. Please try again.', backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      print('=== ERROR: $e ===');
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
    } finally {
      loading.value = false;
    }
  }

  void _pickDate(TextEditingController ctrl) async {
    DateTime? d = await showDatePicker(context: context,
      initialDate: DateTime(1995), firstDate: DateTime(1900), lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(
        colorScheme: const ColorScheme.light(primary: AppColors.primary)), child: child!));
    if (d != null) ctrl.text = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  }

  void _pickTime(TextEditingController ctrl) async {
    TimeOfDay? t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(
        colorScheme: const ColorScheme.light(primary: AppColors.primary)), child: child!));
    if (t != null) ctrl.text = '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
  }
}