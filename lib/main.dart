import 'package:totplock/screens/totp_screen_list.dart';
import 'package:totplock/utils/app_theme.dart';
import 'package:totplock/utils/theme_settings.dart';
import 'package:totplock/providers/totp_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('darkMode') ?? false;
  runApp(ChangeNotifierProvider(
      create: (_) => TotpProvider(), child: MyApp(isDark: isDark)));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.isDark});

  final bool isDark;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => ThemeSettings(widget.isDark),
        builder: (context, snapshot) {
          final themeSettings = Provider.of<ThemeSettings>(context);

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'TotpLock',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeSettings.currentTheme,
            home: const TotpListScreen(),
          );
        });
  }
}
