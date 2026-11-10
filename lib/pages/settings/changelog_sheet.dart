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
    text:
        'تحديد مواقيت الصلاة تلقائياً بناءً على موقعك الجغرافي وعرض الوقت المتبقي للأذان.',
  ),
  ChangelogItem(type: ChangeType.newFeature, text: 'عرض التاريخ الهجري بدقة.'),
  ChangelogItem(
    type: ChangeType.newFeature,
    text: 'إشعارات دقيقة لمواقيت الأذان وتنبيهات يومية لأذكار الصباح والمساء.',
  ),
  ChangelogItem(
    type: ChangeType.newFeature,
    text: 'مكتبة شاملة للأذكار مع عداد تفاعلي لحفظ تقدمك اليومي وتشجيعك.',
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
                      'ميزات الإصدار الأول',
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
                      'قيد التطوير (قريباً)',
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
    final bool isNew = item.type == ChangeType.newFeature;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          // Tag Label (جديد / قادم)
          Container(
            // margin: const EdgeInsets.only(top: 2, left: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isNew
                  ? AppColors.primary.withAlpha(50)
                  : AppColors.hint.withAlpha(50),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isNew ? 'جديد' : 'قادم',
              style: TextStyle(
                color: isNew ? AppColors.primary : AppColors.hint,
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
