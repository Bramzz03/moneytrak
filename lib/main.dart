import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/storage_service.dart';
import 'services/settings_service.dart';
import 'theme.dart';
import 'screens/main_screen.dart';
import 'screens/pin_lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await StorageService.init();
  final pinEnabled = await SettingsService.isPinEnabled();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.navBg,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(MoneyTrakApp(requirePin: pinEnabled));
}

class MoneyTrakApp extends StatelessWidget {
  final bool requirePin;
  const MoneyTrakApp({super.key, required this.requirePin});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyTrak',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: requirePin ? const PinLockScreen() : const MainScreen(),
    );
  }
}
