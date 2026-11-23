import 'package:flutter/material.dart';
import 'package:project_azkar/pages/prayers/models/prayer_model.dart';
import 'package:project_azkar/data/repos/prayers_repo.dart';
import 'package:project_azkar/pages/prayers/prayer_details.dart';
import 'package:project_azkar/utils/app_colors.dart';
import 'package:project_azkar/utils/enums.dart';

class CarouselPrayers extends StatefulWidget {
  const CarouselPrayers({super.key});

  @override
  State<CarouselPrayers> createState() => _CarouselPrayersState();
}

class _CarouselPrayersState extends State<CarouselPrayers> {
  final wetr = PrayersRepo.getPrayerByType(PrayerCategories.wetr);
  final estkhara = PrayersRepo.getPrayerByType(PrayerCategories.istikhara);
  final janazah = PrayersRepo.getPrayerByType(PrayerCategories.janazah);

  final List<PrayerModel> prayers = [
    PrayersRepo.getPrayerByType(PrayerCategories.wetr),
    PrayersRepo.getPrayerByType(PrayerCategories.istikhara),
    PrayersRepo.getPrayerByType(PrayerCategories.janazah),
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 180,
          child: CarouselView(
            itemSnapping: true,
            itemExtent: 330,
            shrinkExtent: 200,
            elevation: 3,
            onTap: (value) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrayerDetails(prayers[value]),
                ),
              );
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(24),
              side: BorderSide(color: AppColors.darkBorder, width: .5),
            ),
            children: prayers
                .map((prayer) => UncontainedLayoutCard(prayer))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class UncontainedLayoutCard extends StatelessWidget {
  const UncontainedLayoutCard(this.prayer, {super.key});

  final PrayerModel prayer;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    return Stack(
      alignment: AlignmentDirectional.bottomStart,
      children: <Widget>[
        OverflowBox(
          maxWidth: width * 7 / 8,
          minWidth: width * 7 / 8,
          child: Image(fit: BoxFit.cover, image: AssetImage(prayer.imagePath)),
        ),

        // LAYER 2: The Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xE6000000), Color(0x00000000)],
              ),
            ),
          ),
        ),

        // LAYER 3: The Text Content
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                prayer.title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: Colors.white),
              ),

              Text(
                prayer.subtitle,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFFD1D5DB),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
