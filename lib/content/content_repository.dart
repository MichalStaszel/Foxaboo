import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models.dart';

class ContentRepository {
  ContentRepository(this._bundle);

  final AssetBundle _bundle;

  Future<ContentPack> loadPack(String packId) async {
    final raw = await _bundle.loadString('assets/content/$packId/pack.json');
    return ContentPack.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}

final contentRepositoryProvider =
    Provider<ContentRepository>((ref) => ContentRepository(rootBundle));

final basePackProvider = FutureProvider<ContentPack>(
  (ref) => ref.watch(contentRepositoryProvider).loadPack('base'),
);

/// The base pack, loaded once in `main` before the first frame so screens
/// can read it synchronously.
final contentPackProvider = Provider<ContentPack>(
  (ref) => throw UnimplementedError('override in main'),
);
