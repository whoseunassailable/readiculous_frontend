import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../constants/routes.dart';
import '../../../widgets/questionnaire_layout.dart';
import '../../services/api_service.dart';
import '../domain/add_user_genre.dart';

class PreferredGenre extends StatefulWidget {
  const PreferredGenre({super.key});

  @override
  State<PreferredGenre> createState() => _PreferredGenreState();
}

class _PreferredGenreState extends State<PreferredGenre> {
  List<String> selectedGenres = [];
  final TextEditingController textEditingController = TextEditingController();
  Map<int, String> genreList = {};
  List<String> selectedGenreNames = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchGenres();
  }

  Future<void> fetchGenres() async {
    final apiService = ApiService();
    try {
      final genres = await apiService.getAllGenres();
      setState(() {
        genreList = genres;
      });
    } catch (e) {
      print('Error fetching genres: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load genres')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return QuestionnaireLayout(
      title: 'Smart Select',
      questionText: 'What genre are you most interested in?',
      containerData: const [],
      customInputField: MultiSelectDialogField<String>(
        items: genreList.values
            .map((name) => MultiSelectItem<String>(name, name))
            .toList(),
        title: Text('Select Genres'),
        selectedColor: Theme.of(context).primaryColor,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          border: Border.all(color: Colors.grey),
        ),
        buttonIcon: Icon(Icons.arrow_drop_down),
        buttonText: Text('Select genres'),
        onConfirm: (values) {
          setState(() {
            selectedGenreNames = values;
          });
        },
        chipDisplay: MultiSelectChipDisplay(
          onTap: (value) {
            setState(() {
              selectedGenreNames.remove(value);
            });
          },
        ),
      ),
      onTapOfButton: () async {
        final apiService = ApiService();
        if (selectedGenreNames.isNotEmpty) {
          final sharedPreferences = await SharedPreferences.getInstance();
          final userId = sharedPreferences.getString('userId');

          if (userId != null) {
            // Convert selected names to genre IDs
            final selectedGenreIds = genreList.entries
                .where((entry) => selectedGenreNames.contains(entry.value))
                .map((entry) => entry.key)
                .toList();

            await apiService.updateStudent(
              studentId: userId,
              createUserGenreModel: CreateUserGenreModel(
                userId: userId,
                genreIds: selectedGenreIds,
              ),
            );

            await sharedPreferences.setStringList(
              'preferred_genres',
              selectedGenreNames,
            );

            context.pushNamed(RouteNames.bookRecommendationPageForUser);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User ID not found.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select at least one genre')),
          );
        }
      },
      buttonText: AppLocalizations.of(context).next,
      hintTextForInputField: '',
      controller: null,
    );
  }
}
