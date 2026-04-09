import 'package:flutter/cupertino.dart';

import '../../../../../generated/l10n.dart';

class MiniHeading extends StatelessWidget {
  final double height;
  final double width;
  final bool isLibrarian;
  const MiniHeading({super.key, required this.height, required this.width, this.isLibrarian = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: width / 12),
        Text(
          isLibrarian ? S.of(context).basedOnCollectedReaderData : 'Track, rate, and discover books',
          style: TextStyle(
            fontSize: height / 45,
          ),
        ),
      ],
    );
  }
}
