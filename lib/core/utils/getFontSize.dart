import '../constants/app_font_size.dart';

double getCustomFontSize(
    {required final String size, required final double width}) {
  switch (size) {
    case 'xxxs':
      return AppFontSize.xxxs * width;
    case 'xxs':
      return AppFontSize.xxs * width;
    case 'xs':
      return AppFontSize.xs * width;
    case 's':
      return AppFontSize.s * width;
    case 'm':
      return AppFontSize.m * width;
    case 'l':
      return AppFontSize.l * width;
    case 'xl':
      return AppFontSize.xl * width;
    case 'xxl':
      return AppFontSize.xxl * width;
    case 'xxxl':
      return AppFontSize.xxxl * width;
    default:
      throw ArgumentError("Invalid size identifier: $size");
  }
}
