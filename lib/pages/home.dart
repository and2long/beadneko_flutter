import 'dart:io';

import 'package:beadneko/models/bead_project.dart';
import 'package:beadneko/pages/editor_page.dart';
import 'package:beadneko/pages/settings_page.dart';
import 'package:beadneko/store.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<BeadProject>('projects').listenable(),
        builder: (context, Box<BeadProject> box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.palette_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No projects yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to create a new BeadNeko project',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final keys = box.keys.toList().reversed.toList(); // Newest first

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final key = keys[index];
              final project = box.get(key)!;

              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    final store = Provider.of<BeadProjectProvider>(
                      context,
                      listen: false,
                    );
                    store.loadProject(project);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditorPage(),
                      ),
                    );
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Project'),
                        content: const Text(
                          'Are you sure you want to delete this project?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              box.delete(key);
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Image.file(
                          File(project.originalImagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) =>
                              const Icon(Icons.broken_image),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${project.targetSize}x${project.targetSize}",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              _formatDate(project.updatedAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _checkPermissionAndPickImage(context);
        },
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }

  Future<void> _checkPermissionAndPickImage(BuildContext context) async {
    // Check current status
    PermissionStatus status = await Permission.photos.status;

    if (status.isGranted || status.isLimited) {
      if (context.mounted) {
        _pickImage(context);
      }
      return;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsDialog(context);
      }
      return;
    }

    // If denied (but not permanently), show custom rationale
    if (context.mounted) {
      final bool shouldContinue =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Photo Access Required'),
              content: const Text(
                'BeadNeko needs access to your photos to let you select images for creating bead patterns.',
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
        // Request permission
        final result = await Permission.photos.request();
        if ((result.isGranted || result.isLimited) && context.mounted) {
          _pickImage(context);
        } else if (result.isPermanentlyDenied && context.mounted) {
          _showSettingsDialog(context);
        }
      }
    }
  }

  Future<void> _showSettingsDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'BeadNeko cannot access your photos. Please enable Photo access in the app settings to continue.',
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

  Future<void> _pickImage(BuildContext context) async {
    final store = Provider.of<BeadProjectProvider>(context, listen: false);
    store.clearProject();
    await store.pickImage(ImageSource.gallery);
    if (store.originalImage != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditorPage()),
      );
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }
}
