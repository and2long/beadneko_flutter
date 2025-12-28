import 'dart:io';

import 'package:beadneko/i18n/i18n.dart';
import 'package:beadneko/store.dart';
import 'package:beadneko/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const String _feedbackEmail = 'and2long@icloud.com';
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${info.version}+${info.buildNumber}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      strings.settingsTheme,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      _themeModeLabel(context.watch<ConfigStore>().themeMode),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: _showThemeSelector,
                  ),
                  const Divider(height: 1, indent: 0, endIndent: 0),
                  ListTile(
                    title: Text(
                      strings.settingsLanguage,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      _localeLabel(context.watch<ConfigStore>().locale),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: _showLanguageSelector,
                  ),
                ],
              ),
            ),
            Card(
              child: ListTile(
                title: Text(
                  strings.settingsFeedbackTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  strings.settingsFeedbackSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: _sendFeedbackEmail,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                '${strings.settingsVersion} $_version',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    final strings = S.of(context);
    switch (mode) {
      case ThemeMode.light:
        return strings.settingsThemeLight;
      case ThemeMode.dark:
        return strings.settingsThemeDark;
      case ThemeMode.system:
        return strings.settingsThemeSystem;
    }
  }

  Future<void> _showThemeSelector() async {
    final strings = S.of(context);
    final options = [
      MapEntry(ThemeMode.light, strings.settingsThemeLight),
      MapEntry(ThemeMode.dark, strings.settingsThemeDark),
      MapEntry(ThemeMode.system, strings.settingsThemeSystem),
    ];

    final selectedMode = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final currentMode = context.read<ConfigStore>().themeMode;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    strings.settingsTheme,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              RadioGroup<ThemeMode>(
                groupValue: currentMode,
                onChanged: (mode) {
                  if (mode != null) {
                    Navigator.of(context).pop(mode);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: options
                      .map(
                        (option) => RadioListTile<ThemeMode>(
                          value: option.key,
                          title: Text(option.value),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selectedMode != null && mounted) {
      context.read<ConfigStore>().setThemeMode(selectedMode);
    }
  }

  String _localeLabel(Locale locale) {
    return S.localeSets[locale.languageCode] ?? locale.languageCode;
  }

  Future<void> _showLanguageSelector() async {
    final strings = S.of(context);
    final options = [
      ...S.supportedLocales.map(
        (locale) => MapEntry<String, String>(
          locale.languageCode,
          S.localeSets[locale.languageCode] ?? locale.languageCode,
        ),
      ),
    ];

    // 返回所选的 Locale，如果直接关闭则返回 null
    final selectedLocale = await showModalBottomSheet<Locale>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final currentLocale = context.read<ConfigStore>().locale;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    strings.settingsLanguage,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              RadioGroup<String>(
                groupValue: currentLocale.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    final locale = S.supportedLocales.firstWhere(
                      (l) => l.languageCode == value,
                      orElse: () => S.supportedLocales.first,
                    );
                    Navigator.of(context).pop(locale);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: options
                      .map(
                        (option) => RadioListTile<String>(
                          value: option.key,
                          title: Text(option.value),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    // 只有用户明确选择了选项才更新
    if (selectedLocale != null && mounted) {
      context.read<ConfigStore>().setLocale(selectedLocale);
    }
  }

  String _buildFeedbackBody(S strings, String version, String systemInfo) {
    return [
      strings.settingsFeedbackBodyIntro,
      '',
      '${strings.settingsFeedbackAppVersion}: $version',
      '${strings.settingsFeedbackSystemInfo}: $systemInfo',
    ].join('\n');
  }

  String _getSystemInfo() {
    final osName = Platform.operatingSystem;
    final osVersion = Platform.operatingSystemVersion;
    return '$osName $osVersion';
  }

  Future<String> _getVersionForFeedback() async {
    if (_version.isNotEmpty) return _version;
    final info = await PackageInfo.fromPlatform();
    final version = '${info.version}+${info.buildNumber}';
    if (mounted) {
      setState(() {
        _version = version;
      });
    }
    return version;
  }

  Future<void> _sendFeedbackEmail() async {
    final strings = S.of(context);
    final version = await _getVersionForFeedback();
    final systemInfo = _getSystemInfo();
    final body = _buildFeedbackBody(strings, version, systemInfo);
    final uri = Uri(
      scheme: 'mailto',
      path: _feedbackEmail,
      queryParameters: {
        'subject': strings.settingsFeedbackSubject,
        'body': body,
      },
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ToastUtil.show(strings.settingsFeedbackLaunchFailure);
      }
    } catch (_) {
      if (mounted) {
        ToastUtil.show(strings.settingsFeedbackLaunchFailure);
      }
    }
  }
}
