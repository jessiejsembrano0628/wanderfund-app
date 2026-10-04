import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/main_menu/presentation/pages/main_menu_page.dart';

/// Wrapper widget that handles routing based on authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthRouteGate(authenticatedBuilder: (_) => const MainMenuPage());
  }
}

class AuthRouteGate extends StatefulWidget {
  final WidgetBuilder authenticatedBuilder;

  const AuthRouteGate({super.key, required this.authenticatedBuilder});

  @override
  State<AuthRouteGate> createState() => _AuthRouteGateState();
}

class _AuthRouteGateState extends State<AuthRouteGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isInitialized || authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!authProvider.isAuthenticated &&
            authProvider.canRetryInitialization) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      authProvider.errorMessage ??
                          'Unable to restore your session.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: authProvider.initialize,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (authProvider.isAuthenticated) {
          return widget.authenticatedBuilder(context);
        }
        return const LoginPage();
      },
    );
  }
}
