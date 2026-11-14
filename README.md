# WOR6LE

A word-guessing game like Wordle, with two changes: the words have 6 letters instead of 5, and a yellow letter shows an arrow (**←** or **→**) pointing toward where it belongs. I kept coming up with 6-letter words in Wordle, and kept getting yellow letters without any idea where they went.

![A game in dark mode: the WOR6LE title over a six-by-six grid with three guesses filled in (RETAIN, FRIEND and SINGER), green tiles for S and I in place, yellow tiles for E and I with small arrows in their corners pointing left or right, gray tiles for the rest, three empty rows, and the on-screen keyboard below with the used letters colored](docs/images/game.webp)

- **Six letters, six tries.** Each game picks a random 6-letter word, and every guess must be a real 6-letter word.
- **Arrows on yellow letters.** A yellow letter has an arrow pointing to the side of the word where it belongs.
- **Statistics, themes and a color blind mode.** Your wins and streaks are saved, and **Settings** has light, dark and high contrast colors.

## Getting started

Play it at [gridloc.dev](https://gridloc.dev/games/wor6le/), or run it from source with Flutter:

```bash
flutter pub get && flutter run -d chrome
```

See [Getting started](docs/getting-started.md) for requirements and other ways to run it.

## Learn more

- [How to play](docs/features.md) · [Controls](docs/controls.md) · [Credits](docs/credits.md)
- [All documentation](docs/README.md) · [Working on the code](docs/development.md)

## License

[MIT](LICENSE). WOR6LE is a fan-made game and isn't affiliated with The New York Times or Wordle; see [Credits](docs/credits.md#disclaimer).
