import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_theme.dart';
import 'edit_profile_screen.dart';
import '../bookmarks/bookmarks_tab.dart';
import '../language_selection_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _name = 'Guest User';
  String _phone = '';
  String _email = 'No email provided';
  double _completeness = 0.25;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('profile_name') ?? '';
    final email = prefs.getString('profile_email') ?? '';
    final phone = prefs.getString('logged_phone') ?? '';
    final dob = prefs.getString('profile_dob') ?? '';
    final tob = prefs.getString('profile_tob') ?? '';
    final place = prefs.getString('profile_place') ?? '';

    double completeness = 0.25; // Base 25% for phone (login parameter)
    if (name.isNotEmpty) completeness += 0.25;
    if (email.isNotEmpty) completeness += 0.25;
    if (dob.isNotEmpty && tob.isNotEmpty && place.isNotEmpty) completeness += 0.25;

    setState(() {
      _name = name.isEmpty ? 'Guest User' : name;
      _phone = phone.isEmpty ? 'Guest Account' : phone;
      _email = email.isEmpty ? 'No email provided' : email;
      _completeness = completeness;
    });
  }

  void _navigateToEditProfile() async {
    final result = await Get.to(() => const EditProfileScreen());
    if (result == true) {
      _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 28),
            onPressed: _navigateToEditProfile,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: const Icon(Icons.person_rounded, size: 50, color: AppColors.primary),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50))),
                      const SizedBox(height: 4),
                      Text(_phone, style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D), fontWeight: FontWeight.bold)),
                      Text(_email, style: const TextStyle(fontSize: 13, color: Color(0xFF95A5A6))),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),
            
            // Profile Completeness
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('profile_completeness'.tr, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
                      Text('${(_completeness * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _completeness,
                    backgroundColor: Colors.white,
                    color: AppColors.primary,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Menu Items
            _menuItem(Icons.person_outline_rounded, 'edit_profile'.tr, onTap: _navigateToEditProfile),
            _divider(),
            _menuItem(Icons.bookmark_border_rounded, 'saved_charts'.tr, onTap: () {
              // Direct navigation to Bookmarks Tab
              Get.to(() => const BookmarksTab());
            }),
            _divider(),
            _menuItem(Icons.language_rounded, 'language'.tr, onTap: () {
              Get.to(() => const LanguageSelectionScreen(isFromProfile: true));
            }),
            _divider(),
            _menuItem(Icons.logout_rounded, 'logout'.tr, isLogout: true, onTap: () {
              final authController = Get.find<AuthController>();
              authController.logout();
            }),
          ],
        ),
      ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, {bool isLogout = false, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isLogout ? Colors.red.shade400 : const Color(0xFF2C3E50)),
      title: Text(title, style: TextStyle(
        fontSize: 16, 
        fontWeight: FontWeight.w600, 
        color: isLogout ? Colors.red.shade400 : const Color(0xFF2C3E50)
      )),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return Divider(color: Colors.grey.shade200, height: 1);
  }
}
