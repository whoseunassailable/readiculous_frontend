import 'package:flutter/cupertino.dart';
import '../constants/app_colors.dart';
import '../utils/text_styles.dart';

class RoundedContainer extends StatelessWidget {
  final String text;
  final void Function()? onTapOfContainer;
  final double height;

  const RoundedContainer({
    super.key,
    required this.text,
    required this.height,
    this.onTapOfContainer,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapOfContainer,
      child: Container(
        height: height / 5,
        width: height / 5,
        decoration: BoxDecoration(
          color: AppColors.bgColorForHomePage,
          border: Border.all(color: AppColors.containerColor),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: TextStyles.bodyTextForContainer(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
