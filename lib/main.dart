import 'package:darb_al_hoda_app/core/constants/app_colors.dart';
import 'package:darb_al_hoda_app/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:darb_al_hoda_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() {
  runApp(
    // Wrap the whole app to let it use 'Riverpod'
    const ProviderScope(child: DarbAlHodaApp()),
  );
}

// I use ConsumerStatefulWidget not StatefulWidget cause i dont need to mutate states locally, but globally using Riverpod
class DarbAlHodaApp extends ConsumerStatefulWidget {
  // To store this widget into flutter storage cause it will not be change in the future
  // pass the key to the parent directly
  const DarbAlHodaApp({super.key});

  // for state management and logic
  @override
  ConsumerState<DarbAlHodaApp> createState() => _DarbAlHodaAppState();
}

class _DarbAlHodaAppState extends ConsumerState<DarbAlHodaApp> {
  @override
  void initState() {
    super.initState();

    //check if we have session when we open the app
    Future.microtask(() => ref.read(authProvider.notifier).checkSession());
  }

  @override
  Widget build(BuildContext context) {
    // keep watch the state if change to update the UI
    final authState = ref.watch(authProvider);

    // the entry point of all our app widgets and UI components
    return MaterialApp(
      title: 'درب الهدى', //app name
      theme: AppTheme.theme, // use darb-al-hoda theme
      debugShowCheckedModeBanner: false, // hide the debug banner
      // RTL - from Right TO Left
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },

      // Navigate the App UI Pages
      home: _buildHome(authState),
    );
  }

  // === Navigation ===
  Widget _buildHome(AuthState authState) {
    // 1. if loading - show loading screen
    if (authState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    // 2. if not authenticated - login screen
    if (!authState.isAuthenticated) {
      return const LoginScreen();
    }

    // 3. if have more than a role - role selection screen
    if (authState.needsRoleSelection) {
      return const RoleSelectionScreen();
    }

    // 4. else render the dashboard
    return const DashboardScreen();
  }
}
