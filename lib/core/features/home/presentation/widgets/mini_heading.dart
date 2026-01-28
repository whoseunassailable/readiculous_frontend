import 'package:flutter/cupertino.dart';

import '../../../../../generated/l10n.dart';

class MiniHeading extends StatelessWidget {
  final double height;
  final double width;
  const MiniHeading({super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: width / 12),
        Text(
          S.of(context).basedOnCollectedReaderData,
          style: TextStyle(
            fontSize: height / 45,
          ),
        ),
      ],
    );
  }
}
