# Foxaboo

A home photo hunt for kids aged 4–8. The app picks something to find (an item
or a colour), the child runs around the house with the phone and takes a
photo, and a narrator says the word in two languages.

Everything runs on the phone: recognition is on-device, photos are deleted
right after the check, and the app has no account, analytics or ads.

## Status: playable app

The app follows the design: start screen, task card, camera hunt with an
"almost" sheet, reward, time up, round summary, sticker album, parent gate
and parent zone. A round is 5 targets from colours or one room; the timer
(30/45/60 s per item, set by the parent) stops while the child reads a hint,
while a photo is checked and while the app is in the background.

Rules the code keeps:

- **Nothing leaves the phone.** Recognition is on-device, each photo is
  deleted right after the check, there is no account, analytics, ads or
  Firebase, and the main manifest has no INTERNET permission. Fonts are
  bundled (Baloo 2 and Nunito, OFL), never downloaded.
- **Any language pair.** UI and content in Polish, English, German, Spanish
  and French; the parent picks the child's language and the one to learn.
  The narrator uses the phone's own text-to-speech for now
  (`lib/narrator/narrator.dart`), to be replaced by recordings.
- **Parent gate** (three digits written as words) in front of the parent
  zone, the purchase and the "Grown-up: this is X" override.
- **Free play:** colours and the kitchen. The rest is one Google Play
  purchase (`full_unlock`), only in the parent zone. Debug builds have a
  "test unlock" button instead.
- **Album uses pictures, never photos.** Stickers are placeholders (Material
  icons or a letter) until the illustrated set exists.
- Up to three children, each with their own album and stats.

The recognition test from the spike is still there: parent zone →
"Recognition test". The goal stays **at least 80%** found within two photos.

## Run it

```sh
flutter pub get
flutter test
flutter run            # on an Android phone with USB debugging
flutter test tool/screenshots --update-goldens   # PNGs of every screen
```

Every pull request also builds a debug APK in GitHub Actions. The latest one
is published as the `spike-latest` prerelease, so a phone signed in to GitHub
can download it directly:
https://github.com/MichalStaszel/Foxaboo/releases/download/spike-latest/foxaboo-spike-debug.apk

## Layout

```
lib/
  app/          app, routing, theme (colours and fonts from the design)
  content/      content pack models and loading
  data/         profiles, settings, finds and rounds (shared_preferences)
  game/         round rules: picking targets, hunt clock, parent gate
  l10n/         languages and UI strings (pl, en, de, es, fr)
  narrator/     Narrator interface; text-to-speech for now
  purchase/     the one-time unlock (Google Play Billing)
  recognition/  Recognizer: ML Kit labels for items, HSV for colours
  widgets/      fox mascot, stickers, buttons, timer ring
  features/     home, round, album, parent (gate + zone), setup, spike
assets/content/base/pack.json   items, colours, words in 5 languages
assets/fonts/                   Baloo 2 and Nunito with their OFL licences
tool/screenshots/               renders every screen to PNG for review
```

To add an item, add it to `pack.json` with its words in every app language
and the ML Kit labels
that count as finding it. The labels must come from the
[ML Kit base model label list](https://developers.google.com/ml-kit/vision/image-labeling/label-map);
`test/content/base_pack_test.dart` checks this.

Thresholds for hit / almost / miss live in `LabelThresholds` and
`ColorThresholds` and are meant to be tuned with spike results.
