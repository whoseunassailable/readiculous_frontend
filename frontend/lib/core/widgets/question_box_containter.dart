import 'package:flutter/material.dart';
import '../utils/text_styles.dart';

class QuestionBoxContainer extends StatelessWidget {
  final double height;
  final double width;
  final String? text;
  final Color? colorOfBorder;
  final Color? colorOfContainer;
  final Color? colorOfText;
  final void Function()? onTapOfContainer;

  const QuestionBoxContainer({
    Key? key,
    required this.height,
    required this.width,
    required this.text,
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
        height: height * 0.075,
        width: width * 0.85,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorOfContainer ?? Colors.black,
          border: Border.all(color: colorOfBorder ?? Colors.white),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Text(
          text ?? '',
          style: TextStyles.bodyText(color: colorOfText ?? Colors.white),
        ),
      ),
    );
  }
}
