import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_theme.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.accent,
                  child: const Icon(Icons.person, size: 50, color: Colors.black26),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Arjun Kumar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50))),
                      SizedBox(height: 4),
                      Text('+91 98765 43210', style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D))),
                      Text('arjunkumar@gmail.com', style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D))),
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
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Profile Completeness', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
                      Text('80%', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.8,
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
            _menuItem(Icons.person_outline_rounded, 'My Profile'),
            _divider(),
            _menuItem(Icons.insert_chart_outlined_rounded, 'Saved Charts'),
            _divider(),
            _menuItem(Icons.bookmark_border_rounded, 'Bookmarks'),
            _divider(),
            _menuItem(Icons.settings_outlined, 'Settings'),
            _divider(),
            _menuItem(Icons.help_outline_rounded, 'Help & Support'),
            _divider(),
            _menuItem(Icons.logout_rounded, 'Logout', isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, {bool isLogout = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isLogout ? Colors.red.shade400 : const Color(0xFF2C3E50)),
      title: Text(title, style: TextStyle(
        fontSize: 16, 
        fontWeight: FontWeight.w600, 
        color: isLogout ? Colors.red.shade400 : const Color(0xFF2C3E50)
      )),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      onTap: () {
        if (isLogout) {
          final authController = Get.find<AuthController>();
          authController.logout();
        }
      },
    );
  }

  Widget _divider() {
    return Divider(color: Colors.grey.shade200, height: 1);
  }
}
