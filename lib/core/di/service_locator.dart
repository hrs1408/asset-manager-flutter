import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Services
import '../services/firestore_service.dart';
import '../services/connectivity_service.dart';
import '../services/retry_service.dart';
import '../services/offline_cache_service.dart';
import '../services/sync_service.dart';
import '../error/error_handler.dart';

// Auth
import '../../features/auth/data/datasources/auth_service.dart';
import '../../features/auth/data/datasources/firebase_auth_service.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Assets
import '../../features/assets/data/repositories/asset_repository_impl.dart';
import '../../features/assets/domain/repositories/asset_repository.dart';
import '../../features/assets/domain/usecases/usecases.dart';
import '../../features/assets/presentation/bloc/asset_bloc.dart';

// Categories
import '../../features/expenses/data/repositories/category_repository_impl.dart';
import '../../features/expenses/domain/repositories/category_repository.dart';
import '../../features/expenses/domain/usecases/category_usecases.dart';
import '../../features/expenses/presentation/bloc/category_bloc.dart';

// Transactions
import '../../features/expenses/data/repositories/transaction_repository_impl.dart';
import '../../features/expenses/domain/repositories/transaction_repository.dart';
import '../../features/expenses/domain/usecases/transaction_usecases.dart';
import '../../features/expenses/presentation/bloc/transaction_bloc.dart';

// Dashboard
import '../../features/dashboard/domain/usecases/get_asset_summary_usecase.dart';
import '../../features/dashboard/domain/usecases/get_expense_summary_usecase.dart';
import '../../features/dashboard/domain/usecases/get_expenses_by_category_usecase.dart' as dashboard_expenses;
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

// Backup
import '../../features/backup/domain/usecases/export_data_usecase.dart';
import '../../features/backup/presentation/bloc/backup_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  
  // Initialize services
  ConnectivityService.instance.initialize();
  await OfflineCacheService.instance.initialize();

  // Core services
  sl.registerLazySingleton(() => ConnectivityService.instance);
  sl.registerLazySingleton(() => ErrorHandler.instance);
  sl.registerLazySingleton(() => RetryService.instance);
  sl.registerLazySingleton(() => OfflineCacheService.instance);
  sl.registerLazySingleton(() => SyncService.instance);
  
  sl.registerLazySingleton<FirestoreService>(
    () => FirestoreService(
      firestore: sl(),
      auth: sl(),
    ),
  );

  // Auth
  sl.registerLazySingleton<AuthService>(
    () => FirebaseAuthService(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authService: sl()),
  );

  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  sl.registerFactory(
    () => AuthBloc(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      signOutUseCase: sl(),
      resetPasswordUseCase: sl(),
      getCurrentUserUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // Assets
  sl.registerLazySingleton<AssetRepository>(
    () => AssetRepositoryImpl(firestoreService: sl()),
  );

  sl.registerLazySingleton(() => CreateAssetUseCase(sl()));
  sl.registerLazySingleton(() => GetAssetsUseCase(sl()));
  sl.registerLazySingleton(() => GetAssetByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAssetUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAssetUseCase(sl()));

  sl.registerFactory(
    () => AssetBloc(
      createAssetUseCase: sl(),
      getAssetsUseCase: sl(),
      getAssetByIdUseCase: sl(),
      updateAssetUseCase: sl(),
      deleteAssetUseCase: sl(),
    ),
  );

  // Categories
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(firestoreService: sl()),
  );

  sl.registerLazySingleton(() => CreateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));
  sl.registerLazySingleton(() => InitializeDefaultCategoriesUseCase(sl()));

  sl.registerFactory(
    () => CategoryBloc(
      createCategoryUseCase: sl(),
      getCategoriesUseCase: sl(),
      updateCategoryUseCase: sl(),
      deleteCategoryUseCase: sl(),
      initializeDefaultCategoriesUseCase: sl(),
    ),
  );

  // Transactions
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(firestoreService: sl()),
  );

  sl.registerLazySingleton(() => CreateTransactionUseCase(
    transactionRepository: sl(),
    assetRepository: sl(),
  ));
  sl.registerLazySingleton(() => GetTransactionsUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetTransactionByIdUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateTransactionUseCase(
    transactionRepository: sl(),
    assetRepository: sl(),
  ));
  sl.registerLazySingleton(() => DeleteTransactionUseCase(
    transactionRepository: sl(),
    assetRepository: sl(),
  ));
  sl.registerLazySingleton(() => GetTransactionsByAssetUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetTransactionsByCategoryUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetTransactionsByDateRangeUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetExpensesByCategoryUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetExpensesByAssetUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetDailyExpensesUseCase(repository: sl()));

  sl.registerFactory(
    () => TransactionBloc(
      createTransactionUseCase: sl(),
      getTransactionsUseCase: sl(),
      updateTransactionUseCase: sl(),
      deleteTransactionUseCase: sl(),
    ),
  );

  // Dashboard
  sl.registerLazySingleton(() => GetAssetSummaryUseCase(assetRepository: sl()));
  sl.registerLazySingleton(() => GetExpenseSummaryUseCase(transactionRepository: sl()));
  sl.registerLazySingleton(() => dashboard_expenses.GetExpensesByCategoryUseCase(
    transactionRepository: sl(),
    categoryRepository: sl(),
  ));

  sl.registerFactory(
    () => DashboardBloc(
      getAssetSummaryUseCase: sl(),
      getExpenseSummaryUseCase: sl(),
      getExpensesByCategoryUseCase: sl(),
      getTransactionsUseCase: sl(),
    ),
  );

  // Backup
  sl.registerLazySingleton(() => ExportDataUseCase(
    assetRepository: sl(),
    categoryRepository: sl(),
    transactionRepository: sl(),
    getCurrentUserUseCase: sl(),
  ));

  sl.registerFactory(
    () => BackupBloc(
      exportDataUseCase: sl(),
    ),
  );
}