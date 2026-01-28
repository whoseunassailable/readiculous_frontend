import 'package:flutter/cupertino.dart';

class HeadingWithLogo extends StatelessWidget {
  final double height;
  final double width;
  final String imageAssetName;
  final String heading;
  const HeadingWithLogo(
      {super.key,
      required this.height,
      required this.width,
      required this.imageAssetName,
      required this.heading});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: width / 12),
        Image.asset(
          imageAssetName,
          height: height / 25,
        ),
        SizedBox(width: width / 24),
        Text(
          heading,
          style: TextStyle(fontSize: height / 30, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
