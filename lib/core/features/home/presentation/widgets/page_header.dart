import 'package:flutter/cupertino.dart';

import '../../../../../generated/l10n.dart';

class PageHeader extends StatelessWidget {
  final double height;
  final double width;

  const PageHeader({super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: height / 8.3),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(width: width / 6),
            Image.asset(
              'assets/icons/library_pulse_icon.png',
              height: height / 25,
            ),
            SizedBox(width: width / 25),
            Text(
              S.of(context).libraryPulse,
              style:
                  TextStyle(fontSize: height / 30, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(width: width / 6),
            Text(
              S.of(context).whatReadersWant,
              style: TextStyle(fontSize: height / 60),
            ),
          ],
        ),
      ],
    );
  }
}
