import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twiiter_clone/common/common.dart';
import 'package:twiiter_clone/common/loading_page.dart';
import 'package:twiiter_clone/features/auth/controller/auth_controller.dart';
import 'package:twiiter_clone/features/auth/view/signup_view.dart';
import 'package:twiiter_clone/features/home/view/home_view.dart';
import 'package:twiiter_clone/theme/theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Twitter clone',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: ref.watch(currentUserAccountProvider).when(
          data: (user) {
            if (user != null) {
              return const HomeView();
            }
            return const SignUpView();
          },
          error: (error, st) => ErrorPage(
                error: error.toString(),
              ),
          loading: () => const LoadingPage()),
    );
  }
}
