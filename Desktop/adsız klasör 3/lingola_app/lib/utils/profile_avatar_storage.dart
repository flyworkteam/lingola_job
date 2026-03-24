import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class ProfileAvatarStorage {
  ProfileAvatarStorage._();

  static const String avatarPrefsKey = 'profile_avatar_path';
  static const String _avatarDirectoryName = 'avatars';
  static const String _avatarFileBaseName = 'profile_avatar';

  static Future<File?> loadAvatarFile() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPath = prefs.getString(avatarPrefsKey);

    if (storedPath != null && storedPath.isNotEmpty) {
      final storedFile = File(storedPath);
      if (await storedFile.exists()) {
        return storedFile;
      }
    }

    final fallbackFile = await _findFallbackAvatarFile();
    if (fallbackFile != null) {
      await prefs.setString(avatarPrefsKey, fallbackFile.path);
    }
    return fallbackFile;
  }

  static Future<File?> savePickedAvatar(XFile pickedImage) async {
    final prefs = await SharedPreferences.getInstance();
    final previousPath = prefs.getString(avatarPrefsKey);
    final bytes = await pickedImage.readAsBytes();
    if (bytes.isEmpty) return null;

    final avatarsDir = await _ensureAvatarDirectory();
    final ext = p.extension(pickedImage.path).trim().toLowerCase();
    final normalizedExt = ext.isEmpty ? '.jpg' : ext;
    final avatarPath = p.join(
      avatarsDir.path,
      '${_avatarFileBaseName}_${DateTime.now().millisecondsSinceEpoch}$normalizedExt',
    );
    final avatarFile = File(avatarPath);

    if (previousPath != null && previousPath.isNotEmpty) {
      await FileImage(File(previousPath)).evict();
    }
    await avatarFile.writeAsBytes(bytes, flush: true);
    await FileImage(avatarFile).evict();
    await prefs.setString(avatarPrefsKey, avatarFile.path);

    await _cleanupOldAvatarFiles(
      currentPath: avatarFile.path,
      previousPath: previousPath,
    );

    return avatarFile;
  }

  static Future<Directory> _ensureAvatarDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final avatarsDir = Directory(p.join(docsDir.path, _avatarDirectoryName));
    if (!await avatarsDir.exists()) {
      await avatarsDir.create(recursive: true);
    }
    return avatarsDir;
  }

  static Future<File?> _findFallbackAvatarFile() async {
    final avatarsDir = await _ensureAvatarDirectory();
    final files = await avatarsDir
        .list()
        .where((entity) => entity is File)
        .cast<File>()
        .toList();
    if (files.isEmpty) return null;

    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    for (final file in files) {
      if (await file.exists()) {
        return file;
      }
    }
    return null;
  }

  static Future<void> _cleanupOldAvatarFiles({
    required String currentPath,
    String? previousPath,
  }) async {
    final avatarsDir = await _ensureAvatarDirectory();
    final files = await avatarsDir
        .list()
        .where((entity) => entity is File)
        .cast<File>()
        .toList();

    for (final file in files) {
      final path = file.path;
      if (path == currentPath) continue;
      if (previousPath != null && path == previousPath) {
        try {
          await file.delete();
        } catch (_) {}
        continue;
      }
      final fileName = p.basenameWithoutExtension(path);
      if (fileName.startsWith(_avatarFileBaseName) || fileName == 'avatar') {
        try {
          await file.delete();
        } catch (_) {}
      }
    }
  }
}
