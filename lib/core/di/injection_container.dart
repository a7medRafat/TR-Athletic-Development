import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/admin/data/datasources/admin_firebase_service.dart';
import '../../features/admin/data/repositories/admin_repo.dart';
import '../../features/admin/presentaion/logic/admin_users_cubit.dart';
import '../../features/login/data/datasources/login_firebase_service.dart';
import '../../features/login/data/repositories/login_repo.dart';
import '../../features/login/presentaion/logic/login_cubit.dart';
import '../../features/post_training/data/datasources/post_training_firebase_service.dart';
import '../../features/post_training/data/repositories/post_training_repo.dart';
import '../../features/post_training/presentaion/logic/post_training_cubit.dart';
import '../../features/pre_training/data/datasources/pre_training_firebase_service.dart';
import '../../features/pre_training/data/repositories/pre_training_repo.dart';
import '../../features/pre_training/presentaion/logic/pre_training_cubit.dart';
import '../../features/register/data/datasources/register_firebase_service.dart';
import '../../features/register/data/repositories/register_repo.dart';
import '../../features/register/presentaion/logic/register_cubit.dart';
import '../../features/settings/data/datasources/settings_firebase_service.dart';
import '../../features/settings/data/datasources/update_profile_firebase_service.dart';
import '../../features/settings/data/repositories/settings_repo.dart';
import '../../features/settings/data/repositories/update_profile_repo.dart';
import '../../features/settings/presentaion/logic/settings_cubit.dart';
import '../../features/settings/presentaion/logic/update_profile_cubit.dart';
import '../../features/submission_history/presentaion/logic/submission_history_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // Firebase singletons
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Login
  getIt.registerLazySingleton<LoginFirebaseService>(
    () => LoginFirebaseService(getIt<FirebaseAuth>()),
  );
  getIt.registerLazySingleton<LoginRepo>(
    () => LoginRepo(getIt<LoginFirebaseService>()),
  );
  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(getIt<LoginRepo>()),
  );

  // Pre Training
  getIt.registerLazySingleton<PreTrainingFirebaseService>(
    () => PreTrainingFirebaseService(getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<PreTrainingRepo>(
    () => PreTrainingRepo(getIt<PreTrainingFirebaseService>()),
  );
  getIt.registerFactory<PreTrainingCubit>(
    () => PreTrainingCubit(getIt<PreTrainingRepo>()),
  );

  // Post Training
  getIt.registerLazySingleton<PostTrainingFirebaseService>(
    () => PostTrainingFirebaseService(getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<PostTrainingRepo>(
    () => PostTrainingRepo(getIt<PostTrainingFirebaseService>()),
  );
  getIt.registerFactory<PostTrainingCubit>(
    () => PostTrainingCubit(getIt<PostTrainingRepo>()),
  );

  // Settings
  getIt.registerLazySingleton<SettingsFirebaseService>(
    () => SettingsFirebaseService(getIt<FirebaseAuth>(), getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<SettingsRepo>(
    () => SettingsRepo(getIt<SettingsFirebaseService>()),
  );
  getIt.registerFactory<SettingsCubit>(
    () => SettingsCubit(getIt<SettingsRepo>()),
  );
  getIt.registerLazySingleton<UpdateProfileFirebaseService>(
    () => UpdateProfileFirebaseService(
      getIt<FirebaseAuth>(),
      getIt<FirebaseFirestore>(),
    ),
  );
  getIt.registerLazySingleton<UpdateProfileRepo>(
    () => UpdateProfileRepo(getIt<UpdateProfileFirebaseService>()),
  );
  getIt.registerFactory<UpdateProfileCubit>(
    () => UpdateProfileCubit(getIt<UpdateProfileRepo>()),
  );

  // Submission History
  getIt.registerFactory<SubmissionHistoryCubit>(
    () => SubmissionHistoryCubit(getIt<PreTrainingRepo>(), getIt<PostTrainingRepo>()),
  );

  // Admin
  getIt.registerLazySingleton<AdminFirebaseService>(
    () => AdminFirebaseService(getIt<FirebaseAuth>(), getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<AdminRepo>(
    () => AdminRepo(getIt<AdminFirebaseService>()),
  );
  getIt.registerFactory<AdminUsersCubit>(
    () => AdminUsersCubit(getIt<AdminRepo>()),
  );

  // Register
  getIt.registerLazySingleton<RegisterFirebaseService>(
    () => RegisterFirebaseService(
      getIt<FirebaseAuth>(),
      getIt<FirebaseFirestore>(),
    ),
  );
  getIt.registerLazySingleton<RegisterRepo>(
    () => RegisterRepo(getIt<RegisterFirebaseService>()),
  );
  getIt.registerFactory<RegisterCubit>(
    () => RegisterCubit(getIt<RegisterRepo>()),
  );
}
