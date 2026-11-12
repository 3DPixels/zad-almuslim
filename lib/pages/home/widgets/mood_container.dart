import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class MoodContainer extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Widget detailsPage;
  final Color iconColor;
  final Color? backgroundColor;

  const MoodContainer({
    super.key,
    this.backgroundColor,
    required this.title,
    required this.iconData,
    required this.iconColor,
    required this.detailsPage,
  });

  Color get _effectiveBackgroundColor {
    if (backgroundColor != null) return backgroundColor!;
    final hslColor = HSLColor.fromColor(iconColor);
    return hslColor.withSaturation(0.25).withLightness(0.15).toColor();
  }

  @override
  Widget build(BuildContext context) {
    // Scale the 18.0 box padding proportionally with our global text scale
    final double boxPadding = MediaQuery.textScalerOf(context).scale(18.0);
    return Column(
      spacing: 8,
      children: [
        OpenContainer(
          transitionDuration: const Duration(milliseconds: 500),
          closedColor: _effectiveBackgroundColor,
          middleColor: Theme.of(context).scaffoldBackgroundColor,
          openColor: Theme.of(context).scaffoldBackgroundColor,
          tappable: false,
          closedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          closedBuilder: (BuildContext context, VoidCallback openContainer) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: openContainer,
                child: Padding(
                  padding: EdgeInsets.all(boxPadding),
                  child: Icon(iconData, color: iconColor),
                ),
              ),
            );
          },
          openBuilder: (BuildContext context, VoidCallback _) {
            return detailsPage;
          },
        ),
        Text(title, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
