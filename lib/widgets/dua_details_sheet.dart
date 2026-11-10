import 'package:flutter/material.dart';

class DuaDetailsSheet extends StatelessWidget {
  const DuaDetailsSheet({
    super.key,
    required this.source,
    required this.benefit,
    required this.buttonsColor,
  });

  final String source;
  final String benefit;
  final Color buttonsColor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          spacing: 10,
          crossAxisAlignment: .start,
          mainAxisSize: .min,
          children: [
            Text(
              'تفاصيل المصدر',
              style: TextStyle(fontSize: 20, fontWeight: .bold),
            ),
            Text(
              source,
              style: TextStyle(
                fontSize: 20,
                fontWeight: .bold,
                color: buttonsColor,
              ),
            ),
            Text(
              benefit,
              style: TextStyle(fontSize: 17, height: 1.6, fontWeight: .w600),
            ),
            SizedBox(),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: buttonsColor),
                minimumSize: Size(.infinity, 45),
              ),
              child: Text(
                'إغلاق',
                style: TextStyle(
                  color: buttonsColor,
                  fontSize: 20,
                  fontWeight: .bold,
                ),
              ),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
