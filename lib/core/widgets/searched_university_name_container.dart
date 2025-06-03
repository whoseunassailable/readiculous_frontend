import 'package:flutter/material.dart';
import '../utils/text_styles.dart';

class SearchedUniversityNameContainer extends StatelessWidget {
  final double height;
  final double width;
  final String universityName;
  final String greScore;
  final String toeflScore;
  final String preferredLocation;
  final IconData? leadingIcon;
  final Color? colorOfBorder;
  final Color? colorOfContainer;
  final Color? colorOfText;
  final void Function()? onTapOfContainer;

  const SearchedUniversityNameContainer({
    Key? key,
    required this.height,
    required this.width,
    required this.universityName,
    required this.greScore,
    required this.toeflScore,
    required this.preferredLocation,
    this.leadingIcon,
    this.colorOfBorder,
    this.colorOfContainer,
    this.colorOfText,
    this.onTapOfContainer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapOfContainer,
      child: Container(
        height: height * 0.4,
        width: width * 0.9,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: colorOfContainer ?? Colors.lightGreenAccent,
          border: Border.all(color: colorOfBorder ?? Colors.yellowAccent),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading icon - 1/3 of the space
            SizedBox(
              width: width * 0.25, // Allocate around 1/3 width for the icon
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Icon(
                  Icons.school, // Default icon if not provided
                  size: height * 0.12, // Adjust size based on height
                  color: Colors.black,
                ),
              ),
            ),
            // University name and scores on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    universityName,
                    style: TextStyles.appBarTitle(),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'GRE: $greScore',
                        style: TextStyles.bodyTextSmall(color: Colors.black),
                      ),
                      SizedBox(width: width / 10),
                      Text(
                        'TOEFL: $toeflScore',
                        style: TextStyles.bodyTextSmall(color: Colors.black),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Preferred Location: $preferredLocation',
                        style: TextStyles.bodyTextSmall(color: Colors.black),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
