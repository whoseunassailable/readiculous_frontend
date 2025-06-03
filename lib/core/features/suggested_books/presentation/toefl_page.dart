// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../../l10n/app_localizations.dart';
// import '../../../constants/routes.dart';
// import '../../../widgets/questionnaire_layout.dart';
// import '../../services/api_service.dart';
//
// class ToeflPage extends StatelessWidget {
//   const ToeflPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController textEditingController = TextEditingController();
//     final List<Map<String, dynamic>> containerData = [
//       {
//         "text": AppLocalizations.of(context).sixty_to_eighty,
//         "colorOfBorder": Colors.black,
//         "colorOfContainer": Colors.white,
//         "colorOfText": Colors.black,
//       },
//       {
//         "text": AppLocalizations.of(context).eighty_to_hundred,
//         "colorOfBorder": Colors.blue,
//         "colorOfContainer": Colors.lightBlue.shade50,
//         "colorOfText": Colors.blue,
//       },
//       {
//         "text": AppLocalizations.of(context).hundred_to_one_twenty,
//         "colorOfBorder": Colors.green,
//         "colorOfContainer": Colors.lightGreen.shade50,
//         "colorOfText": Colors.green,
//       },
//       {
//         "text": AppLocalizations.of(context).eight_to_nine,
//         "colorOfBorder": Colors.teal,
//         "colorOfContainer": Colors.tealAccent,
//         "colorOfText": Colors.teal,
//       },
//     ];
//
//     return QuestionnaireLayout(
//       title: AppLocalizations.of(context).uniquest,
//       questionText: AppLocalizations.of(context).whatAreYourTOEFLScores,
//       containerData: containerData,
//       onTapOfButton: () async {
//         final sharedPreferences = await SharedPreferences.getInstance();
//         final studentId = sharedPreferences.getString('student_id');
//         final _apiservice = ApiService();
//         print('studentId : $studentId');
//         _apiservice.updateStudent(
//           studentId: studentId!,
//           updates: {
//             'toefl_score': textEditingController.text,
//           },
//         );
//         sharedPreferences.setString('toefl_score', textEditingController.text);
//         context.pushNamed(RouteNames.grePage);
//       },
//       buttonText: AppLocalizations.of(context).next,
//       hintTextForInputField: AppLocalizations.of(context).inputYourTOEFLScore,
//       controller: textEditingController,
//     );
//   }
// }
