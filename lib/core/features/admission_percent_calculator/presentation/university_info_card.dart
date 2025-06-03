import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:readiculous_frontend/core/features/admission_percent_calculator/presentation/university_info_header.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_font_size.dart';
import '../../../theme/university_info_card_styles.dart';
import 'info_tile.dart';

class UniversityInfoCard extends StatefulWidget {
  final double height;
  final double width;
  final int universityRank;
  final String universityName;
  final String universityCourse;
  final int greScore;
  final int toeflScore;
  final double gpa;

  const UniversityInfoCard({
    super.key,
    required this.height,
    required this.width,
    required this.universityRank,
    required this.universityName,
    required this.greScore,
    required this.toeflScore,
    required this.gpa,
    required this.universityCourse,
  });

  @override
  State<UniversityInfoCard> createState() => _UniversityInfoCardState();
}

class _UniversityInfoCardState extends State<UniversityInfoCard> {
  @override
  Widget build(BuildContext context) {
    List<String> listOfInfoMapTitles = [
      AppLocalizations.of(context).gre,
      AppLocalizations.of(context).toefl,
      AppLocalizations.of(context).gpa,
      AppLocalizations.of(context).course
    ];
    List<dynamic> listOfInfoMapValues = [
      widget.greScore.toString(),
      widget.toeflScore.toString(),
      widget.gpa.toStringAsFixed(2),
      widget.universityCourse
    ];
    Map infoTileMappedValues =
        Map.fromIterables(listOfInfoMapTitles, listOfInfoMapValues);

    return Hero(
      tag: 'cardHero_${widget.universityName}', // unique tag
      child: Container(
        width: widget.width * 0.9,
        height: widget.height,
        margin: const EdgeInsets.all(16),
        decoration: UniversityInfoCardStyles.containerDecoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UniversityInfoHeader(
                    universityName: widget.universityName,
                    height: widget.height,
                    universityRank: widget.universityRank,
                    progressValue: 0.89,
                  ),
                  SizedBox(height: widget.height * 0.04),

                  /// GRE, TOEFL, GPA, COURSE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: infoTileMappedValues.entries.map((entry) {
                      return InfoTile(
                        title: entry.key,
                        value: entry.value.toString(),
                        height: widget.height,
                      );
                    }).toList(),
                  ),
                  SizedBox(height: widget.height * 0.04),

                  /// ACTIONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(MaterialCommunityIcons.heart,
                          size: widget.height * 0.2, color: Colors.redAccent),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(AppLocalizations.of(context).statusSafe,
                                style: TextStyle(
                                    color: AppColors.safeGreen,
                                    fontSize:
                                        widget.height * AppFontSize.xxxl)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: UniversityInfoCardStyles.applyButtonStyle,
                        onPressed: () {},
                        child: Text(
                          AppLocalizations.of(context).applyNow,
                          style: const TextStyle(
                            color: AppColors.applyButtonTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// import 'dart:ui';
// import 'package:flutter/material.dart';
//
// class UniversityInfoCard extends StatelessWidget {
//   final String universityName;
//   final int universityRank;
//   final int greScore;
//   final int toeflScore;
//   final double gpa;
//   final String course;
//   final double safetyPercentage;
//
//   const UniversityInfoCard({
//     super.key,
//     required this.universityName,
//     required this.universityRank,
//     required this.greScore,
//     required this.toeflScore,
//     required this.gpa,
//     required this.course,
//     required this.safetyPercentage,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       width: double.infinity,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFFf9a825), Color(0xFFf57c00)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black26,
//             blurRadius: 15,
//             offset: Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           /// TOP ROW: Icon + Name + Badge
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const CircleAvatar(
//                 radius: 26,
//                 backgroundColor: Colors.white,
//                 child: Icon(Icons.account_balance, color: Colors.deepPurple),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       universityName,
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       'Rank #$universityRank',
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               /// SAFE STATUS BADGE
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(14),
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           '${safetyPercentage.toStringAsFixed(0)}%',
//                           style: const TextStyle(
//                               color: Colors.white, fontWeight: FontWeight.bold),
//                         ),
//                         const Text(
//                           'SAFE',
//                           style: TextStyle(
//                               color: Colors.greenAccent,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 20),
//
//           /// MIDDLE: Scores
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _infoStat('GRE', greScore.toString()),
//               _infoStat('TOEFL', toeflScore.toString()),
//               _infoStat('GPA', gpa.toStringAsFixed(2)),
//               _infoStat('Course', course),
//             ],
//           ),
//
//           const SizedBox(height: 24),
//
//           /// BOTTOM: Icons & Button
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Icon(Icons.school_rounded, color: Colors.white),
//               const Icon(Icons.favorite_border, color: Colors.redAccent),
//               ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blueAccent,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 ),
//                 child: const Text('APPLY NOW'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _infoStat(String title, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Text(
//           title,
//           style:
//               const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(color: Colors.white70),
//         ),
//       ],
//     );
//   }
// }
