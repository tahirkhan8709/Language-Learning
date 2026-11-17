import 'package:material_ui/material_ui.dart';

import 'data/learn_store.dart';
import 'screens/home_shell.dart';
import 'widgets/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = LearnStore();
  await store.load();
  runApp(LanguageApp(store: store));
}

class LanguageApp extends StatelessWidget {
  const LanguageApp({
    super.key,
    required this.store,
    this.themeMode = ThemeMode.system,
  });

  final LearnStore store;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Language Learning',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: HomeShell(store: store),
    );
  }
}
