import 'dart:io';

import 'package:beadneko/components/grid_view.dart';
import 'package:beadneko/i18n/i18n.dart';
import 'package:beadneko/store.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(S.of(context).editorTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt, color: Color(0xFFFF4081)),
            onPressed: () async {
              await _checkPermissionAndSave(context);
            },
          ),
        ],
      ),
      body: Consumer<BeadProjectProvider>(
        builder: (context, project, child) {
          if (project.grid == null) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () => project.pickImage(ImageSource.gallery),
                icon: const Icon(Icons.add_photo_alternate),
                label: Text(S.of(context).editorSelectImage),
              ),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;

              return Stack(
                children: [
                  Column(
                    children: [
                      // Grid View at the top - fixed height equals screen width
                      SizedBox(
                        height: screenWidth,
                        width: double.infinity,
                        child: Container(
                          color: Colors.white,
                          child: InteractiveViewer(
                            minScale: 0.1,
                            maxScale: 10.0,
                            boundaryMargin: EdgeInsets.zero,
                            child: BeadGridView(grid: project.grid!),
                          ),
                        ),
                      ),
                      // Controls at the bottom - scrollable
                      Expanded(
                        child: _ControlPanel(
                          project: project,
                          onShowStats: () =>
                              _showColorStatsBottomSheet(context, project),
                        ),
                      ),
                    ],
                  ),
                  // Loading indicator overlay at top - doesn't hide bottom content
                  if (project.isProcessing)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.9),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF4081),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              S.of(context).editorExporting,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1C1E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showColorStatsBottomSheet(
    BuildContext context,
    BeadProjectProvider project,
  ) {
    final stats = project.colorStats;
    final sortedStats = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            // Tap outside to close
            Navigator.of(context).pop();
          },
          child: GestureDetector(
            // Prevent taps inside the sheet from closing it
            onTap: () {},
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (_, controller) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              S.of(context).editorStatsTitle,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1C1E),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Color(0xFF1A1C1E),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.separated(
                          controller: controller,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          itemCount: sortedStats.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: Colors.grey[100]),
                          itemBuilder: (context, index) {
                            final entry = sortedStats[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: entry.key.color,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: entry.key.color.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      border: Border.all(color: Colors.black12),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.black12,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.key.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1A1C1E),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Code: ${entry.key.code}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "x${entry.value}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF42474E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _checkPermissionAndSave(BuildContext context) async {
    // For iOS, we need photosAddOnly or photos.
    // For Android < 10, we usually need storage.
    // For Android 10+, image_gallery_saver_plus handles it, but we can check if strictly required.
    // sticking to Permission.photos (or photosAddOnly for iOS if available, but Permission.photos covers both usually).

    // Check status
    var status = await Permission.photos.status;

    if (Platform.isAndroid) {
      // Android logic specific if needed.
      // For simplicity and user request, we just check photos/storage generic status
      // Note: implementation details might vary by sdk version
    }

    if (status.isGranted || status.isLimited) {
      if (context.mounted) _saveImage(context);
      return;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) _showSettingsDialog(context);
      return;
    }

    if (context.mounted) {
      // Request permission directly; show settings only if permanently denied.
      final result = await Permission.photos.request();
      if ((result.isGranted || result.isLimited) && context.mounted) {
        _saveImage(context);
      } else if (result.isPermanentlyDenied && context.mounted) {
        _showSettingsDialog(context);
      }
    }
  }

  Future<void> _saveImage(BuildContext context) async {
    final project = Provider.of<BeadProjectProvider>(context, listen: false);
    final success = await project.saveImage(context);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? S.of(context).editorSaveSuccess
                : S.of(context).editorSaveFailure,
          ),
        ),
      );
    }
  }

  Future<void> _showSettingsDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).permissionSettingsTitle),
        content: Text(S.of(context).permissionSaveSettingsContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(S.of(context).permissionOpenSettings),
          ),
        ],
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  final BeadProjectProvider project;
  final VoidCallback onShowStats;

  const _ControlPanel({required this.project, required this.onShowStats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    _buildGridSizeControl(context, project),
                    const SizedBox(height: 24),
                    _buildPerlerBrandNotice(context),
                  ],
                ),
              ),
              // Action Button at the very bottom
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onShowStats,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4081),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      S.of(context).editorStatsTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridSizeControl(
    BuildContext context,
    BeadProjectProvider project,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4081).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.grid_view,
                      color: Color(0xFFFF4081),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    S.of(context).editorPixelSize,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1C1E),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4081).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  "${project.targetSize}",
                  style: const TextStyle(
                    color: Color(0xFFFF4081),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFFF4081),
              inactiveTrackColor: const Color(
                0xFFFF4081,
              ).withValues(alpha: 0.1),
              thumbColor: const Color(0xFFFF4081),
              overlayColor: const Color(0xFFFF4081).withValues(alpha: 0.1),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: project.targetSize.toDouble(),
              min: 20,
              max: 100,
              divisions: 8, // 20, 30, 40, 50, 60, 70, 80, 90, 100
              onChanged: (value) {
                project.updateTargetSize(value.toInt());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "20x",
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
                Text(
                  "40x",
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
                Text(
                  "60x",
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
                Text(
                  "80x",
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
                Text(
                  "100x",
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerlerBrandNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4081).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF4081).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4081).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.palette,
              color: Color(0xFFFF4081),
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Using official Perler® bead colors',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
