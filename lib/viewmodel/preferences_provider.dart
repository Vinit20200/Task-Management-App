import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final preferencesProvider = StateNotifierProvider<PreferencesNotifier, UserPreferences>((ref) {
  return PreferencesNotifier();
});

class UserPreferences {
  bool isDarkMode;
  UserPreferences({this.isDarkMode = false});
}

class PreferencesNotifier extends StateNotifier<UserPreferences> {
  PreferencesNotifier() : super(UserPreferences()) {
    loadPreferences();
  }

  void loadPreferences() {
    final box = Hive.box('preferences');
    state = UserPreferences(isDarkMode: box.get('isDarkMode', defaultValue: false));
  }

  void toggleTheme() {
    final box = Hive.box('preferences');
    box.put('isDarkMode', !state.isDarkMode);
    state = UserPreferences(isDarkMode: !state.isDarkMode);
  }
}
