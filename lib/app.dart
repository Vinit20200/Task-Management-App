import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/viewmodel/preferences_provider.dart';
import 'views/home_screen.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrefs = ref.watch(preferencesProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey.shade900,
      ),
      themeMode: userPrefs.isDarkMode ? ThemeMode.dark : ThemeMode.light, // ✅ Use userPrefs value
      home: const HomeScreen(),
    );
  }
}
