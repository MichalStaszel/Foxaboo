import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_data.dart';

/// Opened in `main` before the first frame and injected with an override.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('override in main'),
);

/// The clock, swappable in tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

class AppStore extends Notifier<AppData> {
  static const _key = 'foxaboo.data.v1';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppData build() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const AppData();
    try {
      return AppData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return const AppData();
    }
  }

  void _save(AppData data) {
    state = data;
    _prefs.setString(_key, jsonEncode(data.toJson()));
  }

  String _newId() => 'p${ref.read(clockProvider)().microsecondsSinceEpoch}';

  /// First launch: one child and the language pair.
  void completeSetup({
    required String name,
    int? age,
    required String nativeLang,
    required String learnLang,
  }) {
    final profile = Profile(id: _newId(), name: name, age: age);
    _save(state.copyWith(
      profiles: [profile],
      activeProfileId: profile.id,
      settings: state.settings
          .copyWith(nativeLang: nativeLang, learnLang: learnLang),
    ));
  }

  void addProfile(String name, int? age) {
    if (state.profiles.length >= AppData.maxProfiles) return;
    final profile = Profile(
      id: _newId(),
      name: name,
      age: age,
      colorIndex: state.profiles.length,
    );
    _save(state.copyWith(
      profiles: [...state.profiles, profile],
      activeProfileId: profile.id,
    ));
  }

  void updateProfile(Profile profile) => _save(state.copyWith(profiles: [
        for (final p in state.profiles) p.id == profile.id ? profile : p,
      ]));

  void removeProfile(String id) {
    if (state.profiles.length <= 1) return;
    final profiles = state.profiles.where((p) => p.id != id).toList();
    _save(AppData(
      profiles: profiles,
      activeProfileId: profiles.first.id,
      settings: state.settings,
      progress: {...state.progress}..remove(id),
      fullUnlock: state.fullUnlock,
    ));
  }

  void selectProfile(String id) => _save(state.copyWith(activeProfileId: id));

  void updateSettings(GameSettings settings) =>
      _save(state.copyWith(settings: settings));

  void _updateProgress(Progress Function(Progress) change) {
    final id = state.activeProfile?.id;
    if (id == null) return;
    _save(state.copyWith(progress: {
      ...state.progress,
      id: change(state.progress[id] ?? const Progress()),
    }));
  }

  /// Returns true when this is the first time the child found it: a new
  /// sticker for the album.
  bool recordFind(String targetId, Duration time) {
    final isNew = !state.activeProgress.finds.containsKey(targetId);
    final now = ref.read(clockProvider)();
    _updateProgress((p) => p.withFind(targetId, time, now));
    return isNew;
  }

  void recordRound({
    required int found,
    required int total,
    required Duration foundTime,
  }) {
    final now = ref.read(clockProvider)();
    _updateProgress((p) => p.withRound(RoundRecord(
          at: now,
          found: found,
          total: total,
          foundMs: foundTime.inMilliseconds,
        )));
  }

  void setFullUnlock(bool value) => _save(state.copyWith(fullUnlock: value));
}

final appStoreProvider = NotifierProvider<AppStore, AppData>(AppStore.new);
