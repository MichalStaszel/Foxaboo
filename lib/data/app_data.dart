/// Everything the app remembers. It lives only in this phone's storage:
/// no account, no sync, nothing sent anywhere.
library;

class Profile {
  const Profile({
    required this.id,
    required this.name,
    this.age,
    this.colorIndex = 0,
  });

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        id: j['id'] as String,
        name: j['name'] as String,
        age: j['age'] as int?,
        colorIndex: (j['color'] as int?) ?? 0,
      );

  final String id;
  final String name;
  final int? age;
  final int colorIndex;

  Profile copyWith({String? name, int? age, int? colorIndex}) => Profile(
        id: id,
        name: name ?? this.name,
        age: age ?? this.age,
        colorIndex: colorIndex ?? this.colorIndex,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'age': age, 'color': colorIndex};
}

class GameSettings {
  const GameSettings({
    this.roundSeconds = 60,
    this.nativeLang = 'en',
    this.learnLang = 'es',
    this.narrator = true,
  });

  factory GameSettings.fromJson(Map<String, dynamic> j) => GameSettings(
        roundSeconds: (j['seconds'] as int?) ?? 60,
        nativeLang: (j['native'] as String?) ?? 'en',
        learnLang: (j['learn'] as String?) ?? 'es',
        narrator: (j['narrator'] as bool?) ?? true,
      );

  /// Time per item: 30, 45 or 60 seconds.
  final int roundSeconds;
  final String nativeLang;
  final String learnLang;
  final bool narrator;

  static const secondsOptions = [30, 45, 60];

  GameSettings copyWith({
    int? roundSeconds,
    String? nativeLang,
    String? learnLang,
    bool? narrator,
  }) =>
      GameSettings(
        roundSeconds: roundSeconds ?? this.roundSeconds,
        nativeLang: nativeLang ?? this.nativeLang,
        learnLang: learnLang ?? this.learnLang,
        narrator: narrator ?? this.narrator,
      );

  Map<String, dynamic> toJson() => {
        'seconds': roundSeconds,
        'native': nativeLang,
        'learn': learnLang,
        'narrator': narrator,
      };
}

/// One target (item or colour) a child has found at least once.
class FindRecord {
  const FindRecord({
    required this.targetId,
    required this.firstAt,
    required this.lastAt,
    required this.count,
    required this.bestMs,
  });

  factory FindRecord.fromJson(Map<String, dynamic> j) => FindRecord(
        targetId: j['id'] as String,
        firstAt: DateTime.fromMillisecondsSinceEpoch(j['first'] as int),
        lastAt: DateTime.fromMillisecondsSinceEpoch(j['last'] as int),
        count: j['count'] as int,
        bestMs: j['best'] as int,
      );

  final String targetId;
  final DateTime firstAt;
  final DateTime lastAt;
  final int count;
  final int bestMs;

  Map<String, dynamic> toJson() => {
        'id': targetId,
        'first': firstAt.millisecondsSinceEpoch,
        'last': lastAt.millisecondsSinceEpoch,
        'count': count,
        'best': bestMs,
      };
}

class RoundRecord {
  const RoundRecord({
    required this.at,
    required this.found,
    required this.total,
    required this.foundMs,
  });

  factory RoundRecord.fromJson(Map<String, dynamic> j) => RoundRecord(
        at: DateTime.fromMillisecondsSinceEpoch(j['at'] as int),
        found: j['found'] as int,
        total: j['total'] as int,
        foundMs: j['ms'] as int,
      );

  final DateTime at;
  final int found;
  final int total;

  /// Time spent on the targets that were found, summed.
  final int foundMs;

  Map<String, dynamic> toJson() => {
        'at': at.millisecondsSinceEpoch,
        'found': found,
        'total': total,
        'ms': foundMs,
      };
}

class Progress {
  const Progress({this.finds = const {}, this.rounds = const []});

  factory Progress.fromJson(Map<String, dynamic> j) => Progress(
        finds: {
          for (final f in (j['finds'] as List<dynamic>? ?? const []))
            (f as Map<String, dynamic>)['id'] as String: FindRecord.fromJson(f),
        },
        rounds: [
          for (final r in (j['rounds'] as List<dynamic>? ?? const []))
            RoundRecord.fromJson(r as Map<String, dynamic>),
        ],
      );

  final Map<String, FindRecord> finds;

  /// Most recent last; capped so storage stays small.
  final List<RoundRecord> rounds;

  static const maxRounds = 200;

  Progress withFind(String targetId, Duration time, DateTime now) {
    final old = finds[targetId];
    final ms = time.inMilliseconds;
    return Progress(
      finds: {
        ...finds,
        targetId: FindRecord(
          targetId: targetId,
          firstAt: old?.firstAt ?? now,
          lastAt: now,
          count: (old?.count ?? 0) + 1,
          bestMs: old == null || ms < old.bestMs ? ms : old.bestMs,
        ),
      },
      rounds: rounds,
    );
  }

  Progress withRound(RoundRecord round) {
    final all = [...rounds, round];
    return Progress(
      finds: finds,
      rounds: all.length > maxRounds
          ? all.sublist(all.length - maxRounds)
          : all,
    );
  }

  int roundsSince(DateTime since) =>
      rounds.where((r) => r.at.isAfter(since)).length;

  /// Average seconds per found target over all rounds, or null before any.
  double? get averageSeconds {
    final found = rounds.fold<int>(0, (s, r) => s + r.found);
    if (found == 0) return null;
    final ms = rounds.fold<int>(0, (s, r) => s + r.foundMs);
    return ms / found / 1000;
  }

  /// Found targets, most recently found first.
  List<FindRecord> get recent =>
      finds.values.toList()..sort((a, b) => b.lastAt.compareTo(a.lastAt));

  Map<String, dynamic> toJson() => {
        'finds': [for (final f in finds.values) f.toJson()],
        'rounds': [for (final r in rounds) r.toJson()],
      };
}

class AppData {
  const AppData({
    this.profiles = const [],
    this.activeProfileId,
    this.settings = const GameSettings(),
    this.progress = const {},
    this.fullUnlock = false,
  });

  factory AppData.fromJson(Map<String, dynamic> j) => AppData(
        profiles: [
          for (final p in (j['profiles'] as List<dynamic>? ?? const []))
            Profile.fromJson(p as Map<String, dynamic>),
        ],
        activeProfileId: j['active'] as String?,
        settings: GameSettings.fromJson(
          (j['settings'] as Map<String, dynamic>?) ?? const {},
        ),
        progress: {
          for (final e
              in ((j['progress'] as Map<String, dynamic>?) ?? const {}).entries)
            e.key: Progress.fromJson(e.value as Map<String, dynamic>),
        },
        fullUnlock: (j['unlock'] as bool?) ?? false,
      );

  final List<Profile> profiles;
  final String? activeProfileId;
  final GameSettings settings;
  final Map<String, Progress> progress;

  /// The one-time purchase. Free play covers colours and the kitchen.
  final bool fullUnlock;

  static const maxProfiles = 3;
  static const freeModes = {'colors', 'kitchen'};

  bool get isSetUp => profiles.isNotEmpty;

  Profile? get activeProfile =>
      profiles.where((p) => p.id == activeProfileId).firstOrNull ??
      profiles.firstOrNull;

  Progress get activeProgress =>
      progress[activeProfile?.id] ?? const Progress();

  bool isModeUnlocked(String mode) => fullUnlock || freeModes.contains(mode);

  AppData copyWith({
    List<Profile>? profiles,
    String? activeProfileId,
    GameSettings? settings,
    Map<String, Progress>? progress,
    bool? fullUnlock,
  }) =>
      AppData(
        profiles: profiles ?? this.profiles,
        activeProfileId: activeProfileId ?? this.activeProfileId,
        settings: settings ?? this.settings,
        progress: progress ?? this.progress,
        fullUnlock: fullUnlock ?? this.fullUnlock,
      );

  Map<String, dynamic> toJson() => {
        'profiles': [for (final p in profiles) p.toJson()],
        'active': activeProfileId,
        'settings': settings.toJson(),
        'progress': {
          for (final e in progress.entries) e.key: e.value.toJson(),
        },
        'unlock': fullUnlock,
      };
}
