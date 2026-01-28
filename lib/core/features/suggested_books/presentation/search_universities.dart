import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/routes.dart';
import '../../../utils/appbar.dart';
import '../../../widgets/searched_university_name_container.dart';
import '../../home/presentation/pages/home_page.dart';
import '../../services/api_service.dart';

class SearchedUniversities extends StatefulWidget {
  const SearchedUniversities({super.key});

  @override
  State<SearchedUniversities> createState() => _SearchedUniversitiesState();
}

class _SearchedUniversitiesState extends State<SearchedUniversities> {
  // Profile information
  String greScore = '';
  String toeflScore = '';
  String preferredLocation = '';
  final _apiservice = ApiService();
  int _currentIndex = 0; // To keep track of the selected tab

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  final List<Widget> _pages = [
    HomePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // Update the selected tab
    });
  }

  Future<void> _loadProfileData() async {
    final sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      greScore = sharedPreferences.getString('gre_score') ?? '';
      toeflScore = sharedPreferences.getString('toefl_score') ?? '';
      preferredLocation =
          sharedPreferences.getString('preferred_location') ?? '';
    });
  }

  Future<List<dynamic>?> _searchUniversities() async {
    try {
      return await _apiservice.searchUniversities(
        minGre: greScore.isNotEmpty ? int.parse(greScore) : 0,
        minToefl: toeflScore.isNotEmpty ? int.parse(toeflScore) : 0,
        preferredLocation: preferredLocation,
      );
    } catch (e) {
      print('Error during API call: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.bgColorForAppBar,
      appBar: StylishAppBar(
        title: AppLocalizations.of(context).uniquest,
        homepage: false,
      ),
      body: Column(
        children: [
          FutureBuilder<List<dynamic>?>(
            future: _searchUniversities(), // Call the API method
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No universities found'));
              } else {
                final universities = snapshot.data!;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: width * 0.9,
                            height: height * 0.65,
                            padding: EdgeInsets.all(height / 40),
                            decoration: BoxDecoration(
                              color: AppColors.bgColorForHomePage,
                              border:
                                  Border.all(color: AppColors.containerColor),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListView.builder(
                              itemCount: universities.length,
                              itemBuilder: (context, index) {
                                final university = universities[index];
                                return Column(
                                  children: [
                                    SearchedUniversityNameContainer(
                                      height: height * 0.35,
                                      width: width * 0.8,
                                      universityName:
                                          university['university_name'] ?? '',
                                      greScore: greScore,
                                      toeflScore: toeflScore,
                                      preferredLocation:
                                          university['location']?.toString() ??
                                              'N/A',
                                    ),
                                    SizedBox(height: height / 40),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          ElevatedButton(
            onPressed: () {
              context.pushNamed(
                  RouteNames.homePage); // Navigates back to the home page
            },
            child: Text(AppLocalizations.of(context).home),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                  vertical: height * 0.02,
                  horizontal: width * 0.3), // Adjust size
              textStyle: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold), // Text style
            ),
          ),
          SizedBox(height: height / 40),
        ],
      ),
    );
  }
}
