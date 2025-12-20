import 'dart:io';

import 'package:beadneko/components/grid_view.dart';
import 'package:beadneko/core/palette.dart';
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
      appBar: AppBar(
        title: const Text('BeadNeko Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: () async {
              await _checkPermissionAndSave(context);
            },
          ),
        ],
      ),
      body: Consumer<BeadProjectProvider>(
        builder: (context, project, child) {
          if (project.isProcessing) {
            return const Center(child: CircularProgressIndicator());
          }

          if (project.grid == null) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () => project.pickImage(ImageSource.gallery),
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Select Image'),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.1,
                    maxScale: 5.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: BeadGridView(grid: project.grid!),
                    ),
                  ),
                ),
              ),
              _buildControls(context, project),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControls(BuildContext context, BeadProjectProvider project) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Pixel Size"),
              DropdownButton<int>(
                value: project.targetSize,
                items: [16, 32, 48, 64, 80, 96, 112, 128].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('${value}x$value'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    project.updateTargetSize(newValue);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Palette Size"),
              DropdownButton<int>(
                value: project.paletteSize,
                items: [72, 96, 120, 144, 168, 291].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(
                      value == 291 ? 'All Colors ($value)' : '$value Colors',
                    ),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    project.setPaletteSize(newValue);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _showColorStats(context, project.colorStats);
                },
                icon: const Icon(Icons.show_chart),
                label: const Text('Stats'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showColorStats(BuildContext context, Map<BeadColor, int> stats) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final sortedStats = stats.entries.toList()
          ..sort(
            (a, b) => b.value.compareTo(a.value),
          ); // Sort by count descending

        final totalBeads = stats.values.fold(0, (sum, count) => sum + count);

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Color Statistics",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    "Total: $totalBeads",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: sortedStats.length,
                  itemBuilder: (context, index) {
                    final entry = sortedStats[index];
                    return ListTile(
                      leading: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: entry.key.color,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.black12),
                        ),
                      ),
                      title: Text("${entry.key.code} - ${entry.key.name}"),
                      trailing: Text(
                        "${entry.value} beads", // Added "beads" unit
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            ],
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

    // Rationale
    if (context.mounted) {
      final bool shouldContinue =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Save Permission Required'),
              content: const Text(
                'BeadNeko needs access to save your bead patterns to the photo library.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Allow'),
                ),
              ],
            ),
          ) ??
          false;

      if (shouldContinue) {
        final result = await Permission.photos.request();
        if ((result.isGranted || result.isLimited) && context.mounted) {
          _saveImage(context);
        } else if (result.isPermanentlyDenied && context.mounted) {
          _showSettingsDialog(context);
        }
      }
    }
  }

  Future<void> _saveImage(BuildContext context) async {
    final project = Provider.of<BeadProjectProvider>(context, listen: false);
    final success = await project.saveImage();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Saved to Photos' : 'Failed to save or permission denied',
          ),
        ),
      );
    }
  }

  Future<void> _showSettingsDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'BeadNeko cannot save photos without permission. Please enable Photo access in the app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
