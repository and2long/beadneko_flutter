import 'dart:io';

import 'package:beadneko/components/action_card.dart';
import 'package:beadneko/components/dashed_container.dart';
import 'package:beadneko/i18n/i18n.dart';
import 'package:beadneko/models/bead_project.dart';
import 'package:beadneko/pages/editor_page.dart';
import 'package:beadneko/pages/settings_page.dart';
import 'package:beadneko/store.dart';
import 'package:beadneko/theme.dart';
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
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header: Logo, Title, Settings
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGradientStart.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pets,
                        color: AppColors.primaryGradientStart,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'BeadNeko',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Caughty Title Section
                Text(
                  S.of(context).homeTitle,
                  style: const TextStyle(
                    fontSize: 32,
                    color: AppColors.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 32,
                      letterSpacing: -0.5,
                    ),
                    children: [
                      TextSpan(
                        text: S.of(context).homeSubtitle1,
                        style: const TextStyle(color: AppColors.textDark),
                      ),
                      TextSpan(
                        text: S.of(context).homeSubtitle2,
                        style: const TextStyle(
                          color: AppColors.primaryGradientStart,
                        ),
                      ),
                      TextSpan(
                        text: S.of(context).homeSubtitle3,
                        style: const TextStyle(color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  S.of(context).homeDesc,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 32),
                // Action Grid
                ActionCard(
                  title: S.of(context).homeActionAlbum,
                  subtitle: S.of(context).homeActionAlbumSub,
                  icon: Icons.image_outlined,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5C9B), Color(0xFFFF86AC)],
                  ),
                  onTap: () => _checkPermissionAndPickImage(context),
                ),
                const SizedBox(height: 16),
                ActionCard(
                  title: S.of(context).homeActionCamera,
                  subtitle: S.of(context).homeActionCameraSub,
                  icon: Icons.camera_alt_outlined,
                  iconColor: const Color(0xFF00C9B1),
                  textColor: AppColors.textDark,
                  gradient: const LinearGradient(
                    colors: [Colors.white, Colors.white],
                  ),
                  onTap: () {
                    _pickImage(context, source: ImageSource.camera);
                  },
                ),
                const SizedBox(height: 40),
                // Recent Projects Section
                Text(
                  S.of(context).homeRecentProjects,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: Hive.box<BeadProject>(
                      'projects',
                    ).listenable(),
                    builder: (context, Box<BeadProject> box, _) {
                      if (box.isEmpty) {
                        return _buildEmptyState(context);
                      }
                      final projects = box.values.toList().reversed.toList();
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          final project = projects[index];
                          final key = box.keyAt(box.length - 1 - index);
                          return _buildProjectItem(context, project, key, box);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        DashedContainer(
          color: Colors.grey[300]!,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Column(
              children: [
                Text(
                  S.of(context).homeEmptyState,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => _checkPermissionAndPickImage(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppGradients.mainAction,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryGradientStart.withOpacity(
                            0.3,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_box, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          S.of(context).homeStartNew,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectItem(
    BuildContext context,
    BeadProject project,
    dynamic key,
    Box<BeadProject> box,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(project.originalImagePath),
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image),
          ),
        ),
        title: Text('${project.targetSize}x${project.targetSize}'),
        subtitle: Text(_formatDate(project.updatedAt)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          final store = Provider.of<BeadProjectProvider>(
            context,
            listen: false,
          );
          store.loadProject(project);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditorPage()),
          );
        },
        onLongPress: () {
          _showDeleteDialog(context, box, key);
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Box<BeadProject> box,
    dynamic key,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).deleteTitle),
        content: Text(S.of(context).deleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              box.delete(key);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(S.of(context).deleteBtn),
          ),
        ],
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
              title: Text(S.of(context).permissionPhotoTitle),
              content: Text(S.of(context).permissionPhotoContent),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(S.of(context).cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(S.of(context).permissionAllow),
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
        title: Text(S.of(context).permissionSettingsTitle),
        content: Text(S.of(context).permissionPhotoSettingsContent),
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

  Future<void> _pickImage(
    BuildContext context, {
    ImageSource source = ImageSource.gallery,
  }) async {
    final store = Provider.of<BeadProjectProvider>(context, listen: false);
    store.clearProject();
    await store.pickImage(source);
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
