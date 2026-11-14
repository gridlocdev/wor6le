# Development

WOR6LE is a [Flutter](https://flutter.dev) app in Dart, with web and macOS targets. The lint rules are in `analysis_options.yaml`.

## Getting set up

You need the [Flutter SDK](https://docs.flutter.dev/get-started/install) with Dart 3.9.2 or later, and Xcode for the macOS target.

```bash
flutter pub get                # install the packages in pubspec.yaml
flutter run -d chrome          # run the web version in Chrome, with hot reload
flutter run -d macos           # run the macOS app
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0   # serve the web version to other devices on your network
```

With the last command, open `http://<your-computer's-local-IP>:8080` on a phone to test it there.

## Checking your work

Run both after every change:

```bash
flutter analyze   # the flutter_lints rules; tools/ and build/ are excluded
flutter test      # there is no test/ folder yet, so this has nothing to run
```

## Word lists

The game reads two lists from `assets/`, one uppercase word per line:

- `assets/answers.txt`: the words a game can pick as the answer.
- `assets/guesses.txt`: the words a guess may be. A guess that isn't in it shows **Not in word list**.

Only 6-letter lines are used. Two scripts in `tools/` tidy a list in place:

```bash
dart run tools/word_list_sorter.dart assets/answers.txt         # uppercase, sort and remove duplicates
dart run tools/filter_six_letter_words.dart assets/guesses.txt  # drop every line that isn't 6 characters long
```

### Adding answer words

1. Add the words to `assets/answers.txt`, and to `assets/guesses.txt` if they aren't there yet.
2. Run `word_list_sorter.dart` and `filter_six_letter_words.dart` on both files.
3. Run `flutter analyze`, then `flutter run -d chrome` and play a game.

## Layout

```
lib/main.dart          the app: theme and the game screen
lib/screens/           game_screen.dart: the app bar, grid, keyboard and dialogs
lib/controllers/       game_controller.dart: loads the word lists, picks the word, checks guesses and sets colors and arrows
lib/models/            game state, tile and letter states, arrow directions, statistics, theme mode
lib/widgets/           the grid, tiles, on-screen keyboard and row shake
lib/dialogs/           How to Play, Settings, Statistics and the game-over dialog
lib/services/          storage_service.dart: settings and statistics in shared_preferences
lib/utils/constants.dart  colors (standard and color blind), sizes and text styles
assets/                the word lists
tools/                 word list scripts (not part of the app)
web/                   index.html, the web manifest and icons
macos/                 the macOS runner
```

## Building and deploying

```bash
flutter build web --release   # write build/web/
flutter build macos --release # write build/macos/Build/Products/Release/wor6le.app
```

`web/index.html` sets `<base href="./">`, so `build/web/` works from any subfolder of a web server without `--base-href`. The `Dockerfile` builds the web version with the stable Flutter channel and serves it with BusyBox `httpd` on port 8080:

```bash
docker build -t wor6le .
docker run -p 8080:8080 wor6le
```

The version shown at the bottom of **Settings** (`WOR6LE v1.0.0`) is written in `lib/dialogs/settings_dialog.dart`; it is separate from `version` in `pubspec.yaml`.
