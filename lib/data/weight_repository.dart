import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env.dart';

class WeightRepository {
  WeightRepository(this._client);

  final SupabaseClient _client;

  bool get _ok => SupabaseEnv.isConfigured;

  /// Latest weight in kg, if any.
  Future<double?> fetchLatestWeightKg() async {
    if (!_ok) return null;
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;

    final row = await _client
        .from('weight_records')
        .select('weight')
        .eq('user_id', uid)
        .order('recorded_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (row == null) return null;
    return (row['weight'] as num).toDouble();
  }

  Future<void> insertWeight(double weightKg) async {
    if (!_ok) return;
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('Not signed in');

    await _client.from('weight_records').insert({
      'user_id': uid,
      'weight': weightKg,
    });
  }

  /// Latest weights for charts (newest first).
  Future<List<double>> recentWeights({int limit = 30}) async {
    if (!_ok) return const [];

    final uid = _client.auth.currentUser?.id;
    if (uid == null) return const [];

    final rows = await _client
        .from('weight_records')
        .select('weight')
        .eq('user_id', uid)
        .order('recorded_at', ascending: false)
        .limit(limit);

    final list = (rows as List<dynamic>)
        .map((e) => (Map<String, dynamic>.from(e as Map))['weight'])
        .whereType<num>()
        .map((n) => n.toDouble())
        .toList();
    return list.reversed.toList();
  }
}
