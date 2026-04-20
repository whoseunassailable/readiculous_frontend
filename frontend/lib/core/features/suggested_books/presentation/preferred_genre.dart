import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import '../../../../generated/l10n.dart';
import '../../../features/home/presentation/state_management/genres_provider.dart';
import '../../../network/clients/genres_api_client.dart';
import '../../../network/clients/user_genres_api_client.dart';
import '../../../network/dio_client.dart';
import '../../../session/session_provider.dart';
import '../../../widgets/questionnaire_layout.dart';

class PreferredGenre extends ConsumerStatefulWidget {
  const PreferredGenre({super.key});

  @override
  ConsumerState<PreferredGenre> createState() => _PreferredGenreState();
}

class _PreferredGenreState extends ConsumerState<PreferredGenre> {
  List<String> selectedGenreNames = [];

  @override
  Widget build(BuildContext context) {
    final genresAsync = ref.watch(allGenresProvider);

    return QuestionnaireLayout(
      title: 'Smart Select',
      questionText: 'What genre are you most interested in?',
      containerData: const [],
      customInputField: genresAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Failed to load genres: $e'),
        data: (genres) => MultiSelectDialogField<String>(
          items: genres
              .map((name) => MultiSelectItem<String>(name, name))
              .toList(),
          title: const Text('Select Genres'),
          selectedColor: Theme.of(context).primaryColor,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            border: Border.all(color: Colors.grey),
          ),
          buttonIcon: const Icon(Icons.arrow_drop_down),
          buttonText: const Text('Select genres'),
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
      ),
      onTapOfButton: () async {
        if (selectedGenreNames.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select at least one genre')),
          );
          return;
        }

        final userId = ref.read(sessionProvider).userId;
        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User ID not found.')),
          );
          return;
        }

        // Fetch genre id map to resolve names → ids
        final allGenres = await GenresApiClient(DioClient.main).getAllGenres();
        final genreMap = {
          for (final g in allGenres.cast<Map<String, dynamic>>())
            g['name'] as String: (g['genre_id'] ?? g['id']).toString(),
        };

        final selectedGenreIds = selectedGenreNames
            .where((name) => genreMap.containsKey(name))
            .map((name) => genreMap[name]!)
            .toList();

        await UserGenresApiClient(DioClient.main).addUserGenrePreferences({
          'user_id': userId,
          'genre_ids': selectedGenreIds,
        });

        await ref.read(sessionProvider.notifier).markGenrePrefsSet();

        if (!context.mounted) return;
        context.go('/home_page');
      },
      buttonText: S.of(context).next,
      hintTextForInputField: '',
      controller: null,
    );
  }
}
