import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/cache/app_cache_service.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    AuthRemoteDataSourceImpl(),
    AppCacheService.instance,
  ),
);

final loginUserProvider = Provider<LoginUser>(
  (ref) => LoginUser(ref.watch(authRepositoryProvider)),
);

final registerUserProvider = Provider<RegisterUser>(
  (ref) => RegisterUser(ref.watch(authRepositoryProvider)),
);
