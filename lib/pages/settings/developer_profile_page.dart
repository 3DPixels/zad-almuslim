import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_azkar/utils/app_fonts.dart';
import 'package:project_azkar/utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../utils/url_helper.dart';

class DeveloperProfilePage extends StatelessWidget {
  const DeveloperProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Center(
          child: Column(
            children: [
              ClipOval(
                child: Transform.scale(
                  scale: 1.3,
                  child: Image.asset(
                    AppImages.profile,
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "عمار احمد اسماعيل",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.amiri,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'FLUTTER DEVELOPER',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Divider(
                  color: AppColors.darkBorder,
                  endIndent: 40,
                  indent: 40,
                ),
              ),

              _buildContactTile(
                context,
                icon: Icons.email_outlined,
                title: 'Email',
                onTap: () => UrlHelper.launchEmail(
                  emailAddress: 'ammar.ismail.dev@gmail.com',
                ),
                trailingIcon: Icons.copy,
                onTrailingTap: () {
                  Clipboard.setData(
                    const ClipboardData(text: 'ammar.ismail.dev@gmail.com'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم نسخ البريد الإلكتروني'),
                      backgroundColor: AppColors.darkSurface,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              _buildContactTile(
                context,
                icon: Icons.link,
                title: 'LinkedIn',
                onTap: () => UrlHelper.launchWebUrl(
                  'https://www.linkedin.com/in/ammar-ahmad-ismail-24bb24vv',
                ),
                trailingIcon: Icons.arrow_forward_ios,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    IconData? trailingIcon,
    VoidCallback? onTrailingTap,
  }) {
    return ListTile(
      tileColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        textAlign: .center,
        textDirection: TextDirection.ltr,
      ),
      trailing: trailingIcon != null
          ? IconButton(
              icon: Icon(trailingIcon, color: AppColors.hint, size: 20),
              onPressed: onTrailingTap ?? onTap,
            )
          : null,
    );
  }
}
