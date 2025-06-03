import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../constants/routes.dart';
import '../../../widgets/questionnaire_layout.dart';

class QuestionnairePage extends StatelessWidget {
  const QuestionnairePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController = TextEditingController();

    final List<Map<String, dynamic>> containerData = [
      {
        "text": "Undergraduate",
        "colorOfBorder": Colors.black,
        "colorOfContainer": Colors.white,
        "colorOfText": Colors.black,
      },
      {
        "text": "Postgraduate",
        "colorOfBorder": Colors.blue,
        "colorOfContainer": Colors.lightBlue.shade50,
        "colorOfText": Colors.blue,
      },
      {
        "text": "PhD",
        "colorOfBorder": Colors.green,
        "colorOfContainer": Colors.lightGreen.shade50,
        "colorOfText": Colors.green,
      },
    ];

    return QuestionnaireLayout(
      title: AppLocalizations.of(context).uniquest,
      questionText:
          AppLocalizations.of(context).whatIsYourPreferredLevelOfStudy,
      containerData: containerData,
      onTapOfButton: () => context.pushNamed(RouteNames.preferredGenre),
      buttonText: AppLocalizations.of(context).next,
      hintTextForInputField: 'lol',
      controller: textEditingController,
    );
  }
}
