import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_font_size.dart';

class UniversityInfoHeader extends StatefulWidget {
  final String universityName;
  final double height;
  final int universityRank;
  final double progressValue;
  const UniversityInfoHeader({
    super.key,
    required this.universityName,
    required this.height,
    required this.universityRank,
    required this.progressValue,
  });

  @override
  State<UniversityInfoHeader> createState() => _UniversityInfoHeaderState();
}

class _UniversityInfoHeaderState extends State<UniversityInfoHeader> {
  @override
  Widget build(BuildContext context) {
    return

        /// HEADER
        Row(
      children: [
        const CircleAvatar(radius: 28, child: Icon(FontAwesome.university)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.universityName,
                style: TextStyle(
                  fontSize: widget.height * AppFontSize.xxxxl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorForUniversityInfocard,
                ),
              ),
              Text(
                "${AppLocalizations.of(context).rank} #${widget.universityRank}",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textColorForUniversityInfocard,
                  fontSize: widget.height * AppFontSize.xxxl,
                ),
              ),
            ],
          ),
        ),
        CircularPercentIndicator(
          radius: widget.height * 0.15,
          lineWidth: 5.0,
          percent: widget.progressValue,
          center: Text('${(widget.progressValue * 100).toStringAsFixed(0)}%'),
          progressColor: Colors.green,
        ),
        SizedBox(width: widget.height * 0.05),
      ],
    );
  }
}
