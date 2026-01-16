import 'package:beadneko/constants.dart';
import 'package:beadneko/i18n/i18n.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SPUtil {
  SPUtil._internal();

  static late SharedPreferences _spf;

  static Future<SharedPreferences?> init() async {
    _spf = await SharedPreferences.getInstance();
    return _spf;
  }

  /// 首次引导
  static Future<bool> setFirst(bool first) {
    return _spf.setBool(ConstantsKeyCache.keyIsFirst, first);
  }

  static bool isFirst() {
    return _spf.getBool(ConstantsKeyCache.keyIsFirst) ?? true;
  }

  /// 主题模式
  static Future<bool> setThemeMode(ThemeMode mode) {
    return _spf.setString(ConstantsKeyCache.keyThemeMode, mode.name);
  }

  static ThemeMode getThemeMode() {
    final String? saved = _spf.getString(ConstantsKeyCache.keyThemeMode);
    if (saved == null) return ThemeMode.system;
    return ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  /// Locale 设置
  static Future<bool> setLocale(String languageCode) {
    return _spf.setString(ConstantsKeyCache.keyLanguageCode, languageCode);
  }

  static Locale getLocale() {
    final String? saved = _spf.getString(ConstantsKeyCache.keyLanguageCode);
    if (saved != null && saved.isNotEmpty) return Locale(saved);

    // 跟随系统，自动匹配支持的语言
    final Locale systemLocale =
        WidgetsBinding.instance.platformDispatcher.locale;
    final String systemCode = systemLocale.languageCode;
    final bool isSupported = S.supportedLocales.any(
      (locale) => locale.languageCode == systemCode,
    );

    return isSupported ? Locale(systemCode) : const Locale('en');
  }

  static Future<bool> saveAccessToken(String? token) {
    return _spf.setString(ConstantsKeyCache.keyAccessToken, token ?? '');
  }

  static String? getAccessToken() {
    return _spf.getString(ConstantsKeyCache.keyAccessToken);
  }

  static Future<bool> saveRefreshToken(String? token) {
    return _spf.setString(ConstantsKeyCache.keyRefreshToken, token ?? '');
  }

  static String? getRefreshToken() {
    return _spf.getString(ConstantsKeyCache.keyRefreshToken);
  }

  /// 导出图片次数
  static Future<bool> setExportCount(int count) {
    return _spf.setInt(ConstantsKeyCache.keyExportCount, count);
  }

  static int getExportCount() {
    return _spf.getInt(ConstantsKeyCache.keyExportCount) ?? 0;
  }

  static Future<bool> incrementExportCount() {
    final currentCount = getExportCount();
    return setExportCount(currentCount + 1);
  }

  /// 是否已弹出过评分提示
  static Future<bool> setReviewPrompted(bool prompted) {
    return _spf.setBool(ConstantsKeyCache.keyReviewPrompted, prompted);
  }

  static bool hasPromptedReview() {
    return _spf.getBool(ConstantsKeyCache.keyReviewPrompted) ?? false;
  }

  static void clean() async {
    // 清空所有本地数据，只保存是否是首次进入app的状态
    bool value = isFirst();
    await _spf.clear();
    await setFirst(value);
  }
}
