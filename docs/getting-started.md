# Getting started

You can play WOR6LE in a browser, run it from source on the web or macOS, or host the web version yourself with Docker.

## What you need

- A browser, on a computer or a phone.
- Only for running from source: the [Flutter SDK](https://docs.flutter.dev/get-started/install) with Dart 3.9.2 or later. The macOS version also needs Xcode.

## Play online

Open [gridloc.dev/games/wor6le](https://gridloc.dev/games/wor6le/). Nothing needs installing.

## Run it from source

```bash
git clone https://github.com/gridlocdev/wor6le.git
cd wor6le
flutter pub get          # install the packages
flutter run -d chrome    # run the web version in Chrome
flutter run -d macos     # or run it as a macOS app
```

The project has web and macOS targets only, and those are the two it has been tested on.

To try the web version on a phone, serve it on all network interfaces and open `http://<your-computer's-local-IP>:8080` in the phone's browser:

```bash
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
```

## Run it with Docker

The `Dockerfile` builds the web version and serves it with BusyBox `httpd` on port 8080:

```bash
docker build -t wor6le .
docker run -p 8080:8080 wor6le
```

Then open http://localhost:8080. The build works from any subfolder of a web server, so you can also copy `build/web/` from `flutter build web --release` to any static host.

## First run

A new game starts with a random 6-letter word and an empty grid. Type a guess and press `Enter`. The **How to Play** button (**?**) at the top right opens a page that explains the colors and arrows. Your statistics, theme and color blind setting are saved on the device (in the browser's storage on the web).
