import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../constants/routes.dart';
import '../../../widgets/questionnaire_layout.dart';

class IeltsPage extends StatelessWidget {
  const IeltsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController = TextEditingController();

    final List<Map<String, dynamic>> containerData = [
      {
        "text": AppLocalizations.of(context).six_or_below,
        "colorOfBorder": Colors.black,
        "colorOfContainer": Colors.white,
        "colorOfText": Colors.black,
      },
      {
        "text": AppLocalizations.of(context).six_to_seven,
        "colorOfBorder": Colors.blue,
        "colorOfContainer": Colors.lightBlue.shade50,
        "colorOfText": Colors.blue,
      },
      {
        "text": AppLocalizations.of(context).seven_to_eight,
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
      questionText: AppLocalizations.of(context).whatAreYourIELTSScore,
      containerData: containerData,
      onTapOfButton: () => context.pushNamed(RouteNames.toeflPage),
      buttonText: AppLocalizations.of(context).next,
      hintTextForInputField: AppLocalizations.of(context).inputYourIELTSScore,
      controller: textEditingController,
    );
  }
}
