import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _nameKey = 'profile_name';
  static const _notifKey = 'notifications_enabled';
  static const _pinKey = 'security_pin';
  static const _pinEnabledKey = 'pin_enabled';

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? 'Pengguna';
  }

  static Future<void> setName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  static Future<bool> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notifKey) ?? true;
  }

  static Future<void> setNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifKey, value);
  }

  static Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey);
  }

  static Future<bool> isPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pinEnabledKey) ?? false;
  }

  static Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
    await prefs.setBool(_pinEnabledKey, true);
  }

  static Future<void> disablePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
    await prefs.setBool(_pinEnabledKey, false);
  }

  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
