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

  // Helper method to get text color based on theme
  Color _getTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColors.textDarkDark
        : AppColors.textDark;
  }

  // Helper method to get secondary text color based on theme
  Color _getTextLightColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColors.textLightDark
        : AppColors.textLight;
  }

  // Helper method to get card background color based on theme
  Color _getCardColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? AppColors.cardDark : Colors.white;
  }

  // Helper method to get background gradient based on theme
  LinearGradient _getBackgroundGradient(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppGradients.backgroundDark
        : AppGradients.background;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _getTextColor(context);
    final textLightColor = _getTextLightColor(context);
    final cardColor = _getCardColor(context);
    final backgroundGradient = _getBackgroundGradient(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                  Text(
                    'BeadNeko',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
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
              // Title Section
              Text(
                S.of(context).homeTitle,
                style: TextStyle(
                  fontSize: 32,
                  color: textColor,
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
                      style: TextStyle(color: textColor),
                    ),
                    TextSpan(
                      text: S.of(context).homeSubtitle2,
                      style: const TextStyle(
                        color: AppColors.primaryGradientStart,
                      ),
                    ),
                    TextSpan(
                      text: S.of(context).homeSubtitle3,
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                S.of(context).homeDesc,
                style: TextStyle(fontSize: 16, color: textLightColor),
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
                textColor: textColor,
                gradient: LinearGradient(colors: [cardColor, cardColor]),
                iconBackgroundColor: const Color(0xFF00C9B1).withOpacity(0.08),
                onTap: () {
                  _checkCameraPermissionAndPickImage(context);
                },
              ),
              const SizedBox(height: 40),
              // Recent Projects Section Header
              Row(
                children: [
                  const Icon(Icons.history, color: Color(0xFF00C9B1), size: 28),
                  const SizedBox(width: 8),
                  Text(
                    S.of(context).homeRecentProjects,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ValueListenableBuilder(
                  valueListenable: Hive.box<BeadProject>(
                    'projects',
                  ).listenable(),
                  builder: (context, Box<BeadProject> box, _) {
                    if (box.isEmpty) {
                      return _buildEmptyState(
                        context,
                        textColor,
                        textLightColor,
                      );
                    }
                    final projects = box.values.toList().reversed.toList();
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        final key = box.keyAt(box.length - 1 - index);
                        return _buildProjectItem(
                          context,
                          project,
                          key,
                          box,
                          textColor,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    Color textColor,
    Color textLightColor,
  ) {
    final brightness = Theme.of(context).brightness;
    final borderColor = brightness == Brightness.dark
        ? Colors.grey[700]
        : Colors.grey[300];
    final emptyTextColor = brightness == Brightness.dark
        ? Colors.grey[500]
        : Colors.grey;

    return DashedContainer(
      color: borderColor!,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context).homeEmptyState,
              textAlign: TextAlign.center,
              style: TextStyle(color: emptyTextColor, fontSize: 16),
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
                      color: AppColors.secondaryGradientStart.withOpacity(0.3),
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
    );
  }

  Widget _buildProjectItem(
    BuildContext context,
    BeadProject project,
    dynamic key,
    Box<BeadProject> box,
    Color textColor,
  ) {
    final cardColor = _getCardColor(context);
    final brightness = Theme.of(context).brightness;
    final shadowColor = brightness == Brightness.dark
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.05);

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          GestureDetector(
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
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: SizedBox.expand(
                  child: Image.file(
                    File(project.originalImagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${project.targetSize}x${project.targetSize}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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

  Future<void> _checkCameraPermissionAndPickImage(BuildContext context) async {
    // Check current status
    PermissionStatus status = await Permission.camera.status;

    if (status.isGranted) {
      if (context.mounted) {
        _pickImage(context, source: ImageSource.camera);
      }
      return;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showCameraSettingsDialog(context);
      }
      return;
    }

    // Show custom permission rationale dialog first
    if (context.mounted) {
      final bool shouldContinue =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(S.of(context).permissionCameraTitle),
              content: Text(S.of(context).permissionCameraContent),
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
        // Request system permission after user confirmed
        final result = await Permission.camera.request();
        if (result.isGranted && context.mounted) {
          _pickImage(context, source: ImageSource.camera);
        } else if (result.isPermanentlyDenied && context.mounted) {
          _showCameraSettingsDialog(context);
        }
      }
    }
  }

  Future<void> _showCameraSettingsDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).permissionSettingsTitle),
        content: Text(S.of(context).permissionCameraSettingsContent),
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
}
