import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/idle_session_manager.dart';
import 'service_locator.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/main_menu/presentation/pages/main_menu_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'auth_wrapper.dart';
import 'features/ledger/presentation/providers/ledger_provider.dart';
import 'features/travel_funds/presentation/providers/travel_fund_provider.dart';
import 'features/travel_funds/presentation/pages/create_travel_fund_page.dart';
import 'features/ledger/presentation/pages/ledger_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => getIt<AuthProvider>(),
        ),
        ChangeNotifierProvider<TravelFundProvider>(
          create: (_) => getIt<TravelFundProvider>(),
        ),
        ChangeNotifierProvider<LedgerProvider>(
          create: (_) => getIt<LedgerProvider>(),
        ),
      ],
      child: const _SessionShell(),
    );
  }
}

final _navigatorKey = GlobalKey<NavigatorState>();

class _SessionShell extends StatefulWidget {
  const _SessionShell();

  @override
  State<_SessionShell> createState() => _SessionShellState();
}

class _SessionShellState extends State<_SessionShell> {
  late final IdleSessionManager _idleSessionManager;
  bool _startedForAuthenticatedSession = false;

  @override
  void initState() {
    super.initState();
    _idleSessionManager = IdleSessionManager(
      timeout: const Duration(minutes: 10),
      onTimeout: _handleIdleTimeout,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
    if (isAuthenticated == _startedForAuthenticatedSession) return;
    _startedForAuthenticatedSession = isAuthenticated;
    if (isAuthenticated) {
      _idleSessionManager.start();
    } else {
      _idleSessionManager.stop();
    }
  }

  Future<void> _handleIdleTimeout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    _navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  @override
  void dispose() {
    _idleSessionManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _idleSessionManager.recordActivity(),
      child: Focus(
        autofocus: true,
        onKeyEvent: (_, _) {
          _idleSessionManager.recordActivity();
          return KeyEventResult.ignored;
        },
        child: MaterialApp(
          title: 'WanderFund',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const AuthWrapper(),
          navigatorKey: _navigatorKey,
          onGenerateRoute: _generateRoute,
        ),
      ),
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    final isPublicRoute =
        settings.name == '/login' || settings.name == '/register';
    final authProvider = context.read<AuthProvider>();
    if (!isPublicRoute && !authProvider.isAuthenticated) {
      return MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/login'),
        builder: (_) => const LoginPage(),
      );
    }

    switch (settings.name) {
      case '/login':
        return MaterialPageRoute<void>(builder: (_) => const LoginPage());
      case '/register':
        return MaterialPageRoute<void>(builder: (_) => const RegisterPage());
      case '/menu':
        return MaterialPageRoute<void>(builder: (_) => const MainMenuPage());
      case '/profile':
        return MaterialPageRoute<void>(builder: (_) => const ProfilePage());
      case '/ledger':
        final publicId = settings.arguments;
        if (publicId is! String || publicId.isEmpty) {
          return MaterialPageRoute<void>(builder: (_) => const MainMenuPage());
        }
        return MaterialPageRoute<void>(
          builder: (_) => LedgerPage(publicId: publicId),
        );
      case '/create-travel-fund':
        return MaterialPageRoute<void>(
          builder: (_) => const CreateTravelFundPage(),
        );
      default:
        return MaterialPageRoute<void>(builder: (_) => const LoginPage());
    }
  }
}
