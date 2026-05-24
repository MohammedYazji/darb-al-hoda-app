import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() {
  runApp(
    // Wrap the whole app to let it use 'Riverpod'
    const ProviderScope(
      child: DarbAlHodaApp(),
    ),
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
    Future.microtask(() =>
      ref.read(authProvider.notifier).checkSession()
    );
  }

  @override
  Widget build(BuildContext context) {
    // the entry point of all our app widgets and UI components
    return MaterialApp(
      title: 'درب الهدى',  //app name 
      theme: AppTheme.theme, // use darb-al-hoda theme
      debugShowCheckedModeBanner: false, // hide the debug banner

      // RTL - from Right TO Left
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },

      // Navigate the App UI Pages
      home: const LoginScreen(),
    );
  }
}