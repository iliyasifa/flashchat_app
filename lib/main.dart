import 'package:flashchat_app/constants/app_theme.dart';
import 'package:flashchat_app/screens/chat_screen.dart';
import 'package:flashchat_app/screens/conversations_screen.dart';
import 'package:flashchat_app/screens/login_screen.dart';
import 'package:flashchat_app/screens/profile_screen.dart';
import 'package:flashchat_app/screens/registration_screen.dart';
import 'package:flashchat_app/screens/welcome_screen.dart';
import 'package:flashchat_app/screens/phone_login_screen.dart';
import 'package:flashchat_app/screens/phone_verify_screen.dart';
import 'package:flashchat_app/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final authRoutes = {
        '/',
        '/login',
        '/register',
        '/phone-login',
        '/phone-verify',
      };
      final goingToAuth = authRoutes.contains(state.matchedLocation);

      if (!isLoggedIn && !goingToAuth) {
        return '/';
      }
      if (isLoggedIn && goingToAuth) {
        return '/conversations';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/phone-login',
        builder: (context, state) => const PhoneLoginScreen(),
      ),
      GoRoute(
        path: '/phone-verify',
        builder: (context, state) {
          final verificationId =
              state.uri.queryParameters['verificationId'] ?? '';
          final phone = state.uri.queryParameters['phone'] ?? '';
          return PhoneVerifyScreen(
            verificationId: verificationId,
            phone: phone,
          );
        },
      ),
      GoRoute(
        path: '/conversations',
        builder: (context, state) => const ConversationsScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final peerId = state.uri.queryParameters['peerId'];
          final peerName = state.uri.queryParameters['peerName'];
          return ChatScreen(peerId: peerId, peerName: peerName);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI style for dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: FlashChat(),
    ),
  );
}

class FlashChat extends ConsumerWidget {
  const FlashChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Flash Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
