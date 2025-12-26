import 'dart:io';
import 'dart:typed_data';

import 'package:beadneko/core/palette.dart';
import 'package:beadneko/core/pixel_processor.dart';
import 'package:beadneko/i18n/i18n.dart';
import 'package:beadneko/models/bead_project.dart';
import 'package:beadneko/utils/image_saver.dart';
import 'package:beadneko/utils/sp_util.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
  String? _originalImagePath; // Keep track of path
  List<List<ProcessedPixel>>? _grid;
  int _targetSize = 60; // Default 60x60
  bool _isProcessing = false;

  dynamic _currentProjectKey; // Hive key for current project

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
      _originalImagePath = image.path;
      _originalImage = await image.readAsBytes();
      _currentProjectKey = null; // New project, no key yet
      await processImage();
    }
  }

  // Load from history (re-open)
  Future<void> loadProject(BeadProject project) async {
    final file = File(project.originalImagePath);
    if (await file.exists()) {
      _originalImagePath = project.originalImagePath;
      _originalImage = await file.readAsBytes();
      _targetSize = project.targetSize;

      // Find key for this project in Hive
      if (Hive.isBoxOpen('projects')) {
        final box = Hive.box<BeadProject>('projects');
        // This is a bit inefficient (O(n)), but for small lists it's ok.
        // Better would be to pass the key from the UI if possible.
        // Alternatively, since we are iterating, we can just find it.
        // However, in HomePage we iterate values.
        // Ideally HomePage passes the key.
        // For now, let's just find the key by ID since ID is unique timestamp string.
        final map = box.toMap();
        map.forEach((key, value) {
          if (value.id == project.id) {
            _currentProjectKey = key;
          }
        });
      }

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
    _originalImagePath = null;
    _currentProjectKey = null;
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
      if (success && _originalImagePath != null) {
        await _saveToHistory();
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

  Future<void> _saveToHistory() async {
    try {
      String safePath = _originalImagePath!;

      // Only copy image if it's new (not already in safe path)
      // Actually, if we are editing an existing project, the path is already safe.
      // We should check if path contains app directory?
      // For simplicity: If _currentProjectKey is null, it's new, so copy.
      // If not null, path is likely already safe, unless we picked a NEW image?
      // When picking new image, we set _currentProjectKey = null. Correct.

      if (_currentProjectKey == null) {
        final appDir = await getApplicationDocumentsDirectory();
        final String fileName =
            'bead_${DateTime.now().millisecondsSinceEpoch}.jpg';
        safePath = '${appDir.path}/$fileName';
        await File(_originalImagePath!).copy(safePath);
      }

      // 2. Save to Hive
      if (Hive.isBoxOpen('projects')) {
        final box = Hive.box<BeadProject>('projects');

        final project = BeadProject(
          id: _currentProjectKey != null
              ? (box.get(_currentProjectKey) as BeadProject).id
              : DateTime.now().toString(),
          originalImagePath: safePath,
          targetSize: _targetSize,
          updatedAt: DateTime.now(),
        );

        if (_currentProjectKey != null) {
          // Update existing
          await box.put(_currentProjectKey, project);
          debugPrint("Updated project: $_currentProjectKey");
        } else {
          // Add new
          _currentProjectKey = await box.add(project);
          _originalImagePath = safePath; // Update current path to safe path
          debugPrint("Added new project: $_currentProjectKey");
        }
      }
    } catch (e) {
      debugPrint("History save error: $e");
    }
  }
}
