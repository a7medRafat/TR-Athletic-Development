import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/login/data/datasources/login_firebase_service.dart';
import '../../features/login/data/repositories/login_repo.dart';
import '../../features/login/presentaion/logic/login_cubit.dart';
import '../../features/post_training/data/datasources/post_training_firebase_service.dart';
import '../../features/post_training/data/repositories/post_training_repo.dart';
import '../../features/post_training/presentaion/logic/post_training_cubit.dart';
import '../../features/pre_training/data/datasources/pre_training_firebase_service.dart';
import '../../features/pre_training/data/repositories/pre_training_repo.dart';
import '../../features/pre_training/presentaion/logic/pre_training_cubit.dart';

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
}
