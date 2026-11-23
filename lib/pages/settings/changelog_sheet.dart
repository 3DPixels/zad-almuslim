import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:project_azkar/utils/app_colors.dart';

enum ChangeType { newFeature, upcoming, fix, tweak }

class ChangelogItem {
  final ChangeType type;
  final String text;

  ChangelogItem({required this.type, required this.text});
}

final List<ChangelogItem> currentRelease = [
  ChangelogItem(
    type: ChangeType.newFeature,
    text: 'حفظ التقدم اليومي للأذكار.',
  ),
  ChangelogItem(
    type: ChangeType.newFeature,
    text: 'أدعية مخصصة تواسي مختلف الحالات المزاجية مع إرفاق مصادرها الموثوقة.',
  ),
  ChangelogItem(
    type: ChangeType.newFeature,
    text:
        'دليل تفصيلي لأداء العبادات الخاصة مثل صلاة الجنازة، الاستخارة، والكسوف.',
  ),
  ChangelogItem(
    type: ChangeType.tweak,
    text: 'تحسين نظام البطاقات في الأذكار.',
  ),
  ChangelogItem(
    type: ChangeType.fix,
    text: 'اصلاح مشكلة تغير حجم الخطوط مع نظام الهاتف.',
  ),
];

final List<ChangelogItem> upcomingFeatures = [
  ChangelogItem(
    type: ChangeType.upcoming,
    text: 'تخصيص طريقة حساب مواقيت الصلاة (مثل أم القرى، الهيئة المصرية).',
  ),
  ChangelogItem(
    type: ChangeType.upcoming,
    text: 'بوصلة دقيقة لتحديد اتجاه القبلة.',
  ),
  ChangelogItem(
    type: ChangeType.upcoming,
    text: 'قسم شامل للأدعية القرآنية وأدعية الأنبياء.',
  ),
  ChangelogItem(
    type: ChangeType.upcoming,
    text: 'تحكم كامل في توقيت إشعارات الصلاة (قبل أو بعد الأذان بمدة مخصصة).',
  ),
  ChangelogItem(
    type: ChangeType.upcoming,
    text: 'تشغيل صوتي للأذكار مع ميزة الترديد التلقائي والتحكم في سرعة الصوت.',
  ),
  ChangelogItem(type: ChangeType.upcoming, text: 'اضافة لغات اخرى.'),
  ChangelogItem(
    type: ChangeType.upcoming,
    text: '.اضافة سبحة الكترونية تفاعلية',
  ),

  ChangelogItem(
    type: ChangeType.upcoming,
    text: 'التحكم في صوت اشعارات الأذان.',
  ),
  ChangelogItem(
    type: ChangeType.upcoming,
    text: 'اضافة اشعارات اخرى مثل الصلاة على النبي ﷺ.',
  ),
  ChangelogItem(
    type: ChangeType.upcoming,
    text: 'عرض مواقيت العبادات و الاعياد مثل الايام القمرية و رمضان.',
  ),

  ChangelogItem(
    type: ChangeType.upcoming,
    text: 'اضافة اختيار البلد يدويا في حالة عدم عمل GPS.',
  ),
  // ChangelogItem(type: ChangeType.upcoming, text: ''),
];

void showChangelogSheet(BuildContext context) async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  if (!context.mounted) return;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ChangelogSheetContent(version: packageInfo.version),
  );
}

class _ChangelogSheetContent extends StatelessWidget {
  final String version;

  const _ChangelogSheetContent({required this.version});

  @override
  Widget build(BuildContext context) {
    final newCount = currentRelease.length;
    final fixesCount = currentRelease
        .where((entry) => entry.type == ChangeType.fix)
        .length;
    final tweaksCount = currentRelease
        .where((entry) => entry.type == ChangeType.tweak)
        .length;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.5,
      maxChildSize: 1,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.darkPageBG,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.darkBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const Text(
                'ما الجديد؟',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'سجل التحديثات',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Inner Container
              Container(
                margin: EdgeInsets.only(bottom: 30),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    // Version Box
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(50),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'v$version',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            spacing: 8,
                            children: [
                              if (newCount != 0)
                                _buildStatBadge('$newCount اضافات'),
                              if (fixesCount != 0)
                                _buildStatBadge('$fixesCount اصلاحات'),
                              if (tweaksCount != 0)
                                _buildStatBadge('$tweaksCount تعديلات'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      'اخر تحديثات',
                      style: TextStyle(
                        color: AppColors.hint,
                        fontSize: 13,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...currentRelease.map((item) => _buildFeatureItem(item)),

                    const SizedBox(height: 10),

                    const Text(
                      'قيد التطوير',
                      style: TextStyle(
                        color: AppColors.hint,
                        fontSize: 13,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...upcomingFeatures.map((item) => _buildFeatureItem(item)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withAlpha(240),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFeatureItem(ChangelogItem item) {
    final (Color color, String label) = switch (item.type) {
      ChangeType.newFeature => (AppColors.primary, 'جديد'),
      ChangeType.upcoming => (AppColors.hint, 'قادم'),
      ChangeType.fix => (Colors.amber, 'إصلاح'),
      ChangeType.tweak => (Colors.orange, 'تحسين'),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          // Tag Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withAlpha(50),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.text,
              style: TextStyle(
                color: Color(0xFFE5E7EB),
                fontSize: 14.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
