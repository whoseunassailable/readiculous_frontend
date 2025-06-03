import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../constants/routes.dart';
import '../../../widgets/questionnaire_layout.dart';

class GmatPage extends StatelessWidget {
  const GmatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController = TextEditingController();
    final List<Map<String, dynamic>> containerData = [
      {
        "text": AppLocalizations.of(context).four_hundred_fifty_to_six_hundred,
        "colorOfBorder": Colors.black,
        "colorOfContainer": Colors.white,
        "colorOfText": Colors.black,
      },
      {
        "text": AppLocalizations.of(context).six_hundered_to_seven_hundred,
        "colorOfBorder": Colors.blue,
        "colorOfContainer": Colors.lightBlue.shade50,
        "colorOfText": Colors.blue,
      },
      {
        "text": AppLocalizations.of(context).seven_hundred_to_hundred,
        "colorOfBorder": Colors.green,
        "colorOfContainer": Colors.lightGreen.shade50,
        "colorOfText": Colors.green,
      },
      {
        "text": AppLocalizations.of(context).eight_to_nine,
        "colorOfBorder": Colors.teal,
        "colorOfContainer": Colors.tealAccent,
        "colorOfText": Colors.teal,
      },
    ];

    return QuestionnaireLayout(
      title: AppLocalizations.of(context).uniquest,
      questionText: AppLocalizations.of(context).whatAreYourGMATScores,
      containerData: containerData,
      onTapOfButton: () => context.goNamed(RouteNames.searchedUniversities),
      buttonText: AppLocalizations.of(context).next,
      hintTextForInputField: AppLocalizations.of(context).inputYourGMATScore,
      controller: textEditingController,
    );
  }
}
