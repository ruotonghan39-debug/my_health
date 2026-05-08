import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../core/env.dart';

class StorageService {
  StorageService(this._client);

  final SupabaseClient _client;
  static const _bucket = 'post-images';
  static const _uuid = Uuid();

  Future<String> uploadPostImage(XFile file) async {
    if (!SupabaseEnv.isConfigured) {
      throw StateError('Supabase not configured');
    }
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('Not signed in');

    final bytes = await file.readAsBytes();
    final mimeType = lookupMimeType(file.name, headerBytes: bytes) ??
        lookupMimeType(file.path, headerBytes: bytes) ??
        'application/octet-stream';
    final ext = _pickExtension(mimeType, file.name, file.path);
    final objectPath = '$uid/${_uuid.v4()}.$ext';

    await _client.storage.from(_bucket).uploadBinary(
          objectPath,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: mimeType, upsert: true),
        );

    return _client.storage.from(_bucket).getPublicUrl(objectPath);
  }

  String _pickExtension(String mimeType, String name, String path) {
    if (mimeType.contains('jpeg')) return 'jpg';
    if (mimeType.contains('png')) return 'png';
    if (mimeType.contains('webp')) return 'webp';
    if (mimeType.contains('gif')) return 'gif';
    final n = name.isNotEmpty ? name : path;
    final dot = n.lastIndexOf('.');
    if (dot != -1 && dot < n.length - 1) {
      return n.substring(dot + 1).toLowerCase();
    }
    return 'jpg';
  }
}
