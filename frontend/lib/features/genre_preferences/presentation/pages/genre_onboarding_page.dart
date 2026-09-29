import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import '../../../../core/widgets/questionnaire_layout.dart';
import '../../../../generated/l10n.dart';
import '../../../../shared/genres/presentation/state_management/genres_providers.dart';
import '../state_management/genre_preferences_controller.dart';

/// First-login onboarding: a new reader picks the genres they like before
/// reaching the app. Route `/preferred_location` (historical name).
class GenreOnboardingPage extends ConsumerStatefulWidget {
  const GenreOnboardingPage({super.key});

  @override
  ConsumerState<GenreOnboardingPage> createState() =>
      _GenreOnboardingPageState();
}

class _GenreOnboardingPageState extends ConsumerState<GenreOnboardingPage> {
  List<int> _selectedGenreIds = [];

  /// Saved → the router lets the reader into the app; this navigates too in
  /// case the redirect hasn't run yet. Failed → say why.
  void _onSaveStateChanged(AsyncValue<void>? previous, AsyncValue<void> next) {
    next.whenOrNull(
      data: (_) {
        if (previous?.isLoading == true) context.go('/home_page');
      },
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      ),
    );
  }

  void _onNextPressed() {
    if (_selectedGenreIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).pleaseSelectAtLeastOneGenre)),
      );
      return;
    }
    ref
        .read(genrePreferencesControllerProvider.notifier)
        .save(_selectedGenreIds.toSet());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      genrePreferencesControllerProvider,
      _onSaveStateChanged,
    );
    final saving = ref.watch(
      genrePreferencesControllerProvider.select((s) => s.isLoading),
    );
    final genresAsync = ref.watch(allGenresProvider);

    return QuestionnaireLayout(
      title: 'Smart Select',
      questionText: 'What genre are you most interested in?',
      containerData: const [],
      customInputField: genresAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Failed to load genres: $e'),
        data: (genres) => MultiSelectDialogField<int>(
          items: [
            for (final genre in genres)
              MultiSelectItem<int>(genre.genreId, genre.name),
          ],
          title: const Text('Select Genres'),
          selectedColor: Theme.of(context).primaryColor,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            border: Border.all(color: Colors.grey),
          ),
          buttonIcon: const Icon(Icons.arrow_drop_down),
          buttonText: const Text('Select genres'),
          onConfirm: (values) => setState(() => _selectedGenreIds = values),
          chipDisplay: MultiSelectChipDisplay(
            onTap: (value) => setState(() => _selectedGenreIds.remove(value)),
          ),
        ),
      ),
      onTapOfButton: _onNextPressed,
      isLoading: saving,
      buttonText: S.of(context).next,
      hintTextForInputField: '',
      controller: null,
    );
  }
}
