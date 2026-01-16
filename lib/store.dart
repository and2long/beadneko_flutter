import 'dart:typed_data';

import 'package:beadneko/core/palette.dart';
import 'package:beadneko/core/pixel_processor.dart';
import 'package:beadneko/i18n/i18n.dart';
import 'package:beadneko/utils/image_saver.dart';
import 'package:beadneko/utils/sp_util.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

/// 全局状态管理
class Store {
  Store._internal();

  // 初始化
  static MultiProvider init(Widget child) {
    return MultiProvider(
      providers: [
        // 配置中心 (语言 + 主题)
        ChangeNotifierProvider(
          create: (_) => ConfigStore(
            locale: SPUtil.getLocale(),
            themeMode: SPUtil.getThemeMode(),
          ),
        ),
        // 项目状态
        ChangeNotifierProvider(create: (_) => BeadProjectProvider()),
      ],
      child: child,
    );
  }
}

/// 全局配置
class ConfigStore with ChangeNotifier {
  Locale _locale;
  ThemeMode _themeMode;

  ConfigStore({required Locale locale, ThemeMode themeMode = ThemeMode.system})
    : _locale = locale,
      _themeMode = themeMode;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  void setLocale(Locale locale) {
    if (_locale.toLanguageTag() == locale.toLanguageTag()) return;
    _locale = locale;
    SPUtil.setLocale(locale.languageCode);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    SPUtil.setThemeMode(mode);
    notifyListeners();
  }
}

/// 拼豆项目状态管理
class BeadProjectProvider with ChangeNotifier {
  Uint8List? _originalImage;
  List<List<ProcessedPixel>>? _grid;
  int _targetSize = 60; // Default 60x60
  bool _isProcessing = false;

  Uint8List? get originalImage => _originalImage;
  List<List<ProcessedPixel>>? get grid => _grid;
  int get targetSize => _targetSize;

  bool get isProcessing => _isProcessing;

  Map<BeadColor, int> get colorStats {
    if (_grid == null) return {};
    final stats = <BeadColor, int>{};
    for (var row in _grid!) {
      for (var pixel in row) {
        if (pixel.bead != null) {
          stats.update(pixel.bead!, (value) => value + 1, ifAbsent: () => 1);
        }
      }
    }
    return stats;
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      _originalImage = await image.readAsBytes();
      await processImage();
    }
  }

  void updateTargetSize(int size) {
    if (_targetSize != size) {
      _targetSize = size;
      processImage();
    }
  }

  Future<void> processImage() async {
    if (_originalImage == null) return;

    _isProcessing = true;
    notifyListeners();

    try {
      _grid = await PixelProcessor.processImage(
        _originalImage!,
        _targetSize,
        Palette.allColors,
      );
    } catch (e) {
      debugPrint("Error processing image: $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void clearProject() {
    _originalImage = null;
    _grid = null;
    notifyListeners();
  }

  Future<bool> saveImage(BuildContext context) async {
    if (_grid == null) return false;
    _isProcessing = true;
    notifyListeners();
    try {
      final locale = Localizations.localeOf(context);
      final s = S.of(context);
      final success = await ImageSaver.saveGridImage(
        _grid!,
        _targetSize,
        locale.languageCode,
        s.appName,
      );

      if (success) {
        await _incrementExportCount();
      }

      return success;
    } catch (e) {
      debugPrint("Save error: $e");
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<bool> shouldRequestReview() async {
    final exportCount = SPUtil.getExportCount();
    if (exportCount >= 2 && !SPUtil.hasPromptedReview()) {
      await SPUtil.setReviewPrompted(true);
      return true;
    }
    return false;
  }

  Future<void> _incrementExportCount() async {
    await SPUtil.incrementExportCount();
  }
}
