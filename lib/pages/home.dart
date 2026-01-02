import 'package:beadneko/components/action_card.dart';
import 'package:beadneko/i18n/i18n.dart';
import 'package:beadneko/pages/editor_page.dart';
import 'package:beadneko/pages/settings_page.dart';
import 'package:beadneko/store.dart';
import 'package:beadneko/theme.dart';
import 'package:flutter/material.dart';
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
        child: ListView(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24,
            top: 16 + MediaQuery.of(context).padding.top,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
          ),
          children: [
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
            const SizedBox(height: 32),
          ],
        ),
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

    if (context.mounted) {
      // Request permission directly; show settings only if permanently denied.
      final result = await Permission.photos.request();
      if ((result.isGranted || result.isLimited) && context.mounted) {
        _pickImage(context);
      } else if (result.isPermanentlyDenied && context.mounted) {
        _showSettingsDialog(context);
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

    if (context.mounted) {
      // Request system permission directly; show settings only if permanently denied.
      final result = await Permission.camera.request();
      if (result.isGranted && context.mounted) {
        _pickImage(context, source: ImageSource.camera);
      } else if (result.isPermanentlyDenied && context.mounted) {
        _showCameraSettingsDialog(context);
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
