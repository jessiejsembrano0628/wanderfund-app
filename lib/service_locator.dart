import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/api_service.dart';
import 'core/services/token_storage.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/auth_usecase.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/ledger/data/datasources/ledger_remote_data_source.dart';
import 'features/ledger/data/repositories/ledger_repository_impl.dart';
import 'features/ledger/domain/repositories/ledger_repository.dart';
import 'features/ledger/domain/usecases/ledger_usecase.dart';
import 'features/ledger/presentation/providers/ledger_provider.dart';
import 'features/travel_funds/data/datasources/travel_fund_remote_data_source.dart';
import 'features/travel_funds/data/repositories/travel_fund_repository_impl.dart';
import 'features/travel_funds/domain/repositories/travel_fund_repository.dart';
import 'features/travel_funds/domain/usecases/travel_fund_usecase.dart';
import 'features/travel_funds/presentation/providers/travel_fund_provider.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // HTTP Client
  getIt.registerSingleton<http.Client>(http.Client());

  // Shared Preferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Services
  getIt.registerSingleton<ApiService>(ApiService(client: getIt<http.Client>()));
  getIt.registerSingleton<TokenStorage>(
    TokenStorage(getIt<SharedPreferences>()),
  );

  // Data Sources
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(apiService: getIt<ApiService>()),
  );
  getIt.registerSingleton<TravelFundRemoteDataSource>(
    TravelFundRemoteDataSourceImpl(apiService: getIt<ApiService>()),
  );
  getIt.registerSingleton<LedgerRemoteDataSource>(
    LedgerRemoteDataSourceImpl(apiService: getIt<ApiService>()),
  );

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
          remoteDataSource: getIt<AuthRemoteDataSource>(),
          tokenStorage: getIt<TokenStorage>(),
        )
        as AuthRepository,
  );
  getIt.registerSingleton<TravelFundRepository>(
    TravelFundRepositoryImpl(
      remoteDataSource: getIt<TravelFundRemoteDataSource>(),
      tokenStorage: getIt<TokenStorage>(),
    ),
  );
  getIt.registerSingleton<LedgerRepository>(
    LedgerRepositoryImpl(
      remoteDataSource: getIt<LedgerRemoteDataSource>(),
      tokenStorage: getIt<TokenStorage>(),
    ),
  );

  // Use Cases
  getIt.registerSingleton<LoginUsecase>(
    LoginUsecase(repository: getIt<AuthRepository>()),
  );
  getIt.registerSingleton<RegisterUsecase>(
    RegisterUsecase(repository: getIt<AuthRepository>()),
  );
  getIt.registerSingleton<LogoutUsecase>(
    LogoutUsecase(repository: getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetCurrentUserUsecase>(
    GetCurrentUserUsecase(repository: getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetTravelFundsUsecase>(
    GetTravelFundsUsecase(repository: getIt<TravelFundRepository>()),
  );
  getIt.registerSingleton<GetTravelFundInviteCodeUsecase>(
    GetTravelFundInviteCodeUsecase(repository: getIt<TravelFundRepository>()),
  );
  getIt.registerSingleton<CreateTravelFundUsecase>(
    CreateTravelFundUsecase(repository: getIt<TravelFundRepository>()),
  );
  getIt.registerSingleton<JoinTravelFundUsecase>(
    JoinTravelFundUsecase(repository: getIt<TravelFundRepository>()),
  );
  getIt.registerSingleton<ArchiveTravelFundUsecase>(
    ArchiveTravelFundUsecase(repository: getIt<TravelFundRepository>()),
  );
  getIt.registerSingleton<GetLedgerUsecase>(
    GetLedgerUsecase(repository: getIt<LedgerRepository>()),
  );
  getIt.registerSingleton<GetLedgerMembersUsecase>(
    GetLedgerMembersUsecase(repository: getIt<LedgerRepository>()),
  );
  getIt.registerSingleton<GetJoinRequestsUsecase>(
    GetJoinRequestsUsecase(repository: getIt<LedgerRepository>()),
  );
  getIt.registerSingleton<UpdateJoinRequestUsecase>(
    UpdateJoinRequestUsecase(repository: getIt<LedgerRepository>()),
  );
  getIt.registerSingleton<CreateTransactionUsecase>(
    CreateTransactionUsecase(repository: getIt<LedgerRepository>()),
  );
  getIt.registerSingleton<GetTransactionApprovalRequestsUsecase>(
    GetTransactionApprovalRequestsUsecase(repository: getIt<LedgerRepository>()),
  );
  getIt.registerSingleton<UpdateTransactionApprovalUsecase>(
    UpdateTransactionApprovalUsecase(repository: getIt<LedgerRepository>()),
  );

  // Providers
  getIt.registerSingleton<AuthProvider>(
    AuthProvider(
      loginUsecase: getIt<LoginUsecase>(),
      registerUsecase: getIt<RegisterUsecase>(),
      logoutUsecase: getIt<LogoutUsecase>(),
      getCurrentUserUsecase: getIt<GetCurrentUserUsecase>(),
    ),
  );
  getIt.registerSingleton<TravelFundProvider>(
    TravelFundProvider(
      getTravelFundsUsecase: getIt<GetTravelFundsUsecase>(),
      getTravelFundInviteCodeUsecase:
          getIt<GetTravelFundInviteCodeUsecase>(),
      createTravelFundUsecase: getIt<CreateTravelFundUsecase>(),
      joinTravelFundUsecase: getIt<JoinTravelFundUsecase>(),
      archiveTravelFundUsecase: getIt<ArchiveTravelFundUsecase>(),
    ),
  );
  getIt.registerSingleton<LedgerProvider>(
    LedgerProvider(
      getLedgerUsecase: getIt<GetLedgerUsecase>(),
      getLedgerMembersUsecase: getIt<GetLedgerMembersUsecase>(),
      getJoinRequestsUsecase: getIt<GetJoinRequestsUsecase>(),
      updateJoinRequestUsecase: getIt<UpdateJoinRequestUsecase>(),
        createTransactionUsecase: getIt<CreateTransactionUsecase>(),
        getTransactionApprovalRequestsUsecase:
          getIt<GetTransactionApprovalRequestsUsecase>(),
        updateTransactionApprovalUsecase:
          getIt<UpdateTransactionApprovalUsecase>(),
    ),
  );
}
