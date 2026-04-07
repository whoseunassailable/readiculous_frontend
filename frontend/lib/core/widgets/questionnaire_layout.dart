import 'package:flutter/material.dart';
import 'package:readiculous_frontend/core/widgets/question_box_containter.dart';
import '../../l10n/app_localizations.dart';
import '../constants/app_colors.dart';
import '../utils/appbar.dart';
import 'aesthetic_input_field.dart';
import 'minimalistic_button.dart';

class QuestionnaireLayout extends StatelessWidget {
  final String title;
  final String? questionText;
  final String? hintTextForInputField;
  final TextEditingController? controller;
  final List<Map<String, dynamic>> containerData;
  final List<Map<String, dynamic>>? additionalFields;
  final void Function() onTapOfButton;
  final String buttonText;
  final Widget? customInputField; // ✅ New parameter

  const QuestionnaireLayout({
    super.key,
    required this.title,
    required this.questionText,
    required this.containerData,
    required this.onTapOfButton,
    required this.buttonText,
    this.controller,
    this.hintTextForInputField,
    this.additionalFields,
    this.customInputField, // ✅ In constructor
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.bgColorForAppBar,
      appBar: StylishAppBar(
        title: AppLocalizations.of(context).readiculous,
        homepage: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: width * 0.9,
                height: height * 0.65,
                padding: EdgeInsets.only(top: height / 20),
                decoration: BoxDecoration(
                  color: AppColors.bgColorForHomePage,
                  border: Border.all(color: AppColors.containerColor),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      QuestionBoxContainer(
                        height: height,
                        width: width,
                        text: questionText,
                      ),
                      SizedBox(height: height / 50),

                      // ✅ Render custom input field if provided
                      if (customInputField != null)
                        customInputField!

                      // 👇 Else render multiple fields if provided
                      else if (additionalFields != null &&
                          additionalFields!.isNotEmpty)
                        ...additionalFields!.map((field) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextField(
                              controller: field['controller'],
                              decoration: InputDecoration(
                                labelText: field['label'],
                                hintText: field['hint'],
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          );
                        }).toList()

                      // 👇 Fallback to single aesthetic input field
                      else if (controller != null &&
                          hintTextForInputField != null)
                        AestheticInputField(
                          hintText: hintTextForInputField!,
                          controller: controller!,
                        ),

                      SizedBox(height: height / 50),

                      MinimalistButton(
                        onPressed: onTapOfButton,
                        text: buttonText,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
