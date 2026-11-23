import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adhan/adhan.dart';

import '../../services/adhan_service.dart';
import '../pages/home/cubits/prayer_times_cubit.dart';
import '../pages/settings/cubits/settings_cubit.dart';

class CalculationMethodDialog extends StatelessWidget {
  const CalculationMethodDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final country = context.read<PrayerTimesCubit>().state.country;
        final autoMethod = AdhanService.getAutoMethodForCountry(country);

        return AlertDialog(
          backgroundColor: const Color(0xFF161F18),
          title: const Text(
            'طريقة الحساب',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          contentPadding: const EdgeInsets.only(top: 16, bottom: 8),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: RadioGroup<CalculationMethod?>(
                groupValue: settingsState.selectedCalculationMethod,
                onChanged: (CalculationMethod? value) {
                  context.read<SettingsCubit>().updateCalculationMethod(value);
                  context.read<PrayerTimesCubit>().calculatePrayers();
                  Navigator.pop(context);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<CalculationMethod?>(
                      activeColor: Colors.green,
                      title: Text(
                        'تلقائي (${AdhanService.getMethodName(autoMethod)})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      value: null,
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    ...CalculationMethod.values
                        .where((method) => method != CalculationMethod.other)
                        .map((method) {
                          return RadioListTile<CalculationMethod?>(
                            activeColor: Colors.green,
                            title: Text(
                              AdhanService.getMethodName(method),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            value: method,
                          );
                        }),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }
}
