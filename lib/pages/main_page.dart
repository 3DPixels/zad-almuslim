import 'package:flutter/material.dart';
import 'package:project_azkar/pages/settings/settings_view.dart';
import 'package:project_azkar/utils/app_colors.dart';

import 'home/view.dart';
import 'prayers/view.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _tabs = [HomePage(), PrayersPage(), SettingsPage()];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _pageController,
      builder: (context, child) {
        final double page = _pageController.hasClients
            ? (_pageController.page ?? _currentIndex.toDouble())
            : _currentIndex.toDouble();

        final double transitionProgress = page.clamp(0.0, 1.0);

        final backgroundColor = Color.lerp(
          AppColors.darkGreenPageBG,
          AppColors.darkPageBG,
          transitionProgress,
        );
        final barBackgroundColor = Color.lerp(
          AppColors.darkGreenNavBarBG,
          AppColors.darkNavBarBG,
          transitionProgress,
        );

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Center(
              child: SizedBox(
                width: 600,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      _currentIndex = index;
                    },
                    children: _tabs,
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            backgroundColor: barBackgroundColor,
            onDestinationSelected: (index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 600),
                curve: Curves.ease,
              );
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'الرئيسية'),
              NavigationDestination(icon: Icon(Icons.book), label: 'عبادات'),
              NavigationDestination(
                icon: Icon(Icons.settings),
                label: 'الاعدادات',
              ),
            ],
          ),
        );
      },
    );
  }
}
