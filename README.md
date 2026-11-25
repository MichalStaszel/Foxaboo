# Foxaboo

A home photo hunt for kids aged 4–8. The app picks something to find (an item
or a colour), the child runs around the house with the phone and takes a
photo, and a narrator says the word in two languages.

Everything runs on the phone: recognition is on-device, photos are deleted
right after the check, and the app has no account, analytics or ads.

## Status: recognition spike

Right now the app opens on a test screen, not the game. It lists 8 colours and
50 household items. Take a photo of each one at home; the summary at the top
shows how many were found within two photos. The goal is **at least 80%**.
If ML Kit misses that, the plan is to train our own small classifier.

## Run it

```sh
flutter pub get
flutter test
flutter run            # on an Android phone with USB debugging
```

Every pull request also builds a debug APK in GitHub Actions. The latest one
is published as the `spike-latest` prerelease, so a phone signed in to GitHub
can download it directly:
https://github.com/MichalStaszel/Foxaboo/releases/download/spike-latest/foxaboo-spike-debug.apk

## Layout

```
lib/
  app/          app, routing, theme (colours from the design)
  content/      content pack models and loading
  recognition/  Recognizer: ML Kit labels for items, HSV for colours
  features/
    spike/      recognition test screens
assets/content/base/pack.json   items, colours, words, model labels
```

To add an item, add it to `pack.json` with its words and the ML Kit labels
that count as finding it. The labels must come from the
[ML Kit base model label list](https://developers.google.com/ml-kit/vision/image-labeling/label-map);
`test/content/base_pack_test.dart` checks this.

Thresholds for hit / almost / miss live in `LabelThresholds` and
`ColorThresholds` and are meant to be tuned with spike results.
