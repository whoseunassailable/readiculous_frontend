import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/cache/app_cache_service.dart';
import '../../../../core/session/session_provider.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(
    ProfileRemoteDataSourceImpl(),
    AppCacheService.instance,
  ),
);

final getProfileProvider = Provider<GetProfile>(
  (ref) => GetProfile(ref.watch(profileRepositoryProvider)),
);

final updateProfileProvider = Provider<UpdateProfile>(
  (ref) => UpdateProfile(ref.watch(profileRepositoryProvider)),
);

final changePasswordProvider = Provider<ChangePassword>(
  (ref) => ChangePassword(ref.watch(profileRepositoryProvider)),
);

/// The logged-in user's profile, or null when nobody is logged in.
final currentUserProfileProvider = FutureProvider.autoDispose<UserProfile?>(
  (ref) async {
    final userId = ref.watch(sessionProvider.select((s) => s.userId));
    if (userId == null) return null;
    return ref.watch(getProfileProvider).call(userId);
  },
);
