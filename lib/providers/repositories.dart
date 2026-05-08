import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env.dart';
import '../data/comments_repository.dart';
import '../data/posts_repository.dart';
import '../data/storage_service.dart';
import '../data/weight_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  if (!SupabaseEnv.isConfigured) return null;
  return Supabase.instance.client;
});

final postsRepositoryProvider = Provider<PostsRepository?>((ref) {
  final c = ref.watch(supabaseClientProvider);
  if (c == null) return null;
  return PostsRepository(c);
});

final commentsRepositoryProvider = Provider<CommentsRepository?>((ref) {
  final c = ref.watch(supabaseClientProvider);
  if (c == null) return null;
  return CommentsRepository(c);
});

final weightRepositoryProvider = Provider<WeightRepository?>((ref) {
  final c = ref.watch(supabaseClientProvider);
  if (c == null) return null;
  return WeightRepository(c);
});

final storageServiceProvider = Provider<StorageService?>((ref) {
  final c = ref.watch(supabaseClientProvider);
  if (c == null) return null;
  return StorageService(c);
});
