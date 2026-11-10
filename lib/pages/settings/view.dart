import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_azkar/pages/settings/changelog_sheet.dart';

import 'package:project_azkar/pages/settings/developer_profile_page.dart';
import 'package:project_azkar/utils/app_colors.dart';
import '../../cubits/prayer_times_cubit.dart';
import '../../cubits/settings_cubit.dart';
import '../../services/adhan_service.dart';
import '../../utils/url_helper.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Future<void> _launchStoreRating() async {
  //   const url =
  //       'https://play.google.com/store/apps/details?id=com.yourcompany.projectazkar';
  //   if (await canLaunchUrl(Uri.parse(url))) {
  //     await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final pState = context.watch<PrayerTimesCubit>().state;
        final autoMethod = AdhanService.getAutoMethodForCountry(pState.country);
        final isAuto = settingsState.selectedCalculationMethod == null;

        final subtitleText = isAuto
            ? 'تلقائي (${AdhanService.getMethodName(autoMethod)})'
            : AdhanService.getMethodName(
                settingsState.selectedCalculationMethod!,
              );

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // SECTION 1: App Settings
            Material(
              color: AppColors.darkSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.darkBorder),
              ),
              clipBehavior: Clip
                  .antiAlias, // So splash doesn't bleed outside the rounded corners
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.secondary,
                    inactiveTrackColor: AppColors.darkPageBG,
                    title: const Text(
                      'تفعيل إشعارات الصلاة',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: settingsState.prayerNotifications,
                    onChanged: (val) {
                      context.read<SettingsCubit>().togglePrayerNotifications(
                        val,
                        lat: pState.latitude,
                        lng: pState.longitude,
                        country: pState.country,
                      );
                    },
                  ),
                  const Divider(color: AppColors.darkBorder, height: 1),
                  SwitchListTile(
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.secondary,
                    inactiveTrackColor: AppColors.darkPageBG,
                    title: const Text(
                      'أذكار الصباح والمساء',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'بعد الفجر والعصر بـ ١٠ دقائق',
                      style: TextStyle(fontSize: 12, color: AppColors.hint),
                    ),
                    value: settingsState.morningNightAzkarNotifications,
                    onChanged: (val) {
                      context.read<SettingsCubit>().toggleMorningNightAzkar(
                        val,
                        lat: pState.latitude,
                        lng: pState.longitude,
                        country: pState.country,
                      );
                    },
                  ),
                  const Divider(color: AppColors.darkBorder, height: 1),
                  ListTile(
                    title: const Text(
                      'طريقة الحساب',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      subtitleText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.hint,
                      ),
                    ),
                    // trailing: const Icon(
                    //   Icons.arrow_forward_ios,
                    //   color: AppColors.hint,
                    //   size: 16,
                    // ),
                    // onTap: () {
                    //   showDialog(
                    //     context: context,
                    //     builder: (context) => const CalculationMethodDialog(),
                    //   );
                    // },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SECTION 2: Information & Support
            Material(
              color: AppColors.darkSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.darkBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // ListTile(
                  //   title: const Text(
                  //     'شارك التطبيق',
                  //     style: TextStyle(fontWeight: FontWeight.w600),
                  //   ),
                  //   leading: const Icon(
                  //     Icons.share_outlined,
                  //     color: AppColors.hint,
                  //   ),
                  //   onTap: () {
                  //     SharePlus.instance.share(
                  //       ShareParams(
                  //         title: 'App share',
                  //         text:
                  //             'حمل تطبيق أذكار ومواقيت الصلاة الآن: https://play.google.com/store/apps/details?id=com.yourcompany.projectazkar',
                  //       ),
                  //     );
                  //   },
                  // ),
                  // const Divider(color: AppColors.darkBorder, height: 1),
                  // ListTile(
                  //   title: const Text(
                  //     'قيم التطبيق',
                  //     style: TextStyle(fontWeight: FontWeight.w600),
                  //   ),
                  //   leading: const Icon(
                  //     Icons.star_outline,
                  //     color: AppColors.hint,
                  //   ),
                  //   onTap: _launchStoreRating,
                  // ),
                  // const Divider(color: AppColors.darkBorder, height: 1),
                  ListTile(
                    title: const Text(
                      'اقتراحات وشكاوى',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    leading: const Icon(
                      Icons.email_outlined,
                      color: AppColors.hint,
                    ),
                    onTap: () => UrlHelper.launchEmail(
                      emailAddress: 'ammar.salim2020@outlook.com',
                      subject: 'اقتراحات وشكاوى لتطبيق دليل المسلم',
                    ),
                  ),
                  const Divider(color: AppColors.darkBorder, height: 1),
                  ListTile(
                    title: const Text(
                      'اضافات قادمة',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    leading: const Icon(
                      Icons.rocket_launch_outlined,
                      color: AppColors.hint,
                    ),
                    onTap: () => showChangelogSheet(context),
                  ),
                  const Divider(color: AppColors.darkBorder, height: 1),
                  ListTile(
                    title: const Text(
                      'حول المطور',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    leading: const Icon(
                      Icons.badge_outlined,
                      color: AppColors.hint,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.hint,
                      size: 16,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeveloperProfilePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
