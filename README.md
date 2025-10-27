# WOR6LE - 6-Letter Wordle Game with Directional Arrows

A Flutter implementation of Wordle with two innovative twists:
1. **6-letter words** instead of 5-letter words
2. **Directional arrows** showing where letters belong

## 🎯 Features

### Core Gameplay
- **6×6 grid**: Guess 6-letter words in 6 attempts
- **Daily puzzles**: New word each day at midnight
- **Visual feedback**: Color-coded tiles (green/yellow/gray)
- **Physical & on-screen keyboard**: Type with your keyboard or tap on-screen keys

### Unique Features
- **Directional Arrows** 🎨
  - **Yellow letters**: Arrow (← or →) points to the correct position
  - **Duplicate green letters**: Arrows point to other occurrences
- **Flip animations**: Smooth tile reveals after each guess
- **Shake animation**: Invalid word feedback
- **Smart keyboard**: Keys change color based on letter status

### Additional Features
- **Statistics tracking**: Games played, win %, streaks, guess distribution
- **Share results**: Copy emoji grid to clipboard (🟩🟨⬜)
- **Persistent storage**: Progress saved using SharedPreferences
- **Settings**: Color-blind mode, dark mode toggles
- **Help dialog**: Interactive tutorial with examples
- **Responsive design**: Works on various screen sizes

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                    # App entry point
├── controllers/
│   └── game_controller.dart     # Game logic & state management
├── models/
│   ├── arrow_direction.dart     # Arrow direction enum
│   ├── game_state.dart          # Game state model
│   ├── game_statistics.dart     # Statistics model
│   ├── game_status.dart         # Game status enum
│   ├── letter_status.dart       # Letter status enum
│   └── tile_state.dart          # Tile state model
├── screens/
│   └── game_screen.dart         # Main game screen
├── widgets/
│   ├── game_grid.dart           # 6×6 tile grid
│   ├── game_keyboard.dart       # On-screen QWERTY keyboard
│   ├── wordle_tile.dart         # Animated tile with arrows
│   └── shake_widget.dart        # Shake animation wrapper
├── dialogs/
│   ├── help_dialog.dart         # How to play instructions
│   ├── settings_dialog.dart     # Settings panel
│   └── stats_dialog.dart        # Statistics & share
├── services/
│   └── storage_service.dart     # SharedPreferences wrapper
├── utils/
│   └── constants.dart           # Colors, sizes, styles
└── assets/
    └── words.txt                # 6-letter word dictionary
```

### Key Components

#### GameController
Manages game state and logic:
- Word validation against dictionary
- Guess evaluation with arrow direction calculation
- Daily word generation (date-based seed)
- Letter status tracking for keyboard

#### Arrow Direction Algorithm
```dart
// For yellow letters: find target position, show arrow
if (letter is present but wrong position) {
  arrow = targetPosition < currentPosition ? LEFT : RIGHT
}

// For correct letters with duplicates: show arrow to other occurrence
if (letter is correct && appears multiple times) {
  arrow = otherPosition < currentPosition ? LEFT : RIGHT
}
```

#### Animation System
- **Flip animation**: Tiles rotate on reveal (500ms)
- **Shake animation**: Row shakes for invalid words (500ms)
- **Staggered reveals**: Each tile flips with 100ms delay

## 🎮 How to Play

1. Guess the 6-letter word in 6 tries
2. Each guess must be a valid 6-letter word
3. Press ENTER to submit your guess
4. Color feedback after each guess:
   - 🟩 **Green**: Letter is correct and in the right spot
   - 🟨 **Yellow**: Letter is in the word but wrong spot (arrow shows direction)
   - ⬜ **Gray**: Letter is not in the word
5. Duplicate letters show arrows pointing to each other

### Example
If the word is **TESTER** and you guess **BETTER**:
- B → Gray (not in word)
- E → Green (correct, position 1)
- T → Green (correct, position 2)
- T → Green (correct, position 3)
- E → Yellow with → (in word, should be at position 4)
- R → Green (correct, position 5)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK (included with Flutter)

### Installation
```bash
# Clone the repository
git clone <repository-url>
cd wor6le

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Available Platforms
- ✅ Web
- ✅ macOS (without CocoaPods)
- ✅ Windows
- ✅ Linux
- ✅ Android
- ✅ iOS

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.2.2  # Local storage
  intl: ^0.19.0               # Date formatting
```

## 🎨 Design

### Color Palette
- **Correct**: `#6AAA64` (Green)
- **Present**: `#C9B458` (Yellow)
- **Absent**: `#787C7E` (Gray)
- **Border**: `#D3D6DA` (Light gray)

### Typography
- **Title**: 36px, bold, 2px letter spacing
- **Tiles**: 32px, bold
- **Keyboard**: 18px, bold

## 🧪 Testing

Run tests:
```bash
flutter test
```

Test coverage includes:
- Arrow direction logic
- Word validation
- Letter status tracking
- Daily word consistency
- Error handling

## 📱 Features Comparison

| Feature | Original Wordle | WOR6LE |
|---------|----------------|---------|
| Word Length | 5 letters | **6 letters** |
| Grid Size | 5×6 | **6×6** |
| Directional Arrows | ❌ | **✅** |
| Flip Animations | ✅ | ✅ |
| Statistics | ✅ | ✅ |
| Share Results | ✅ | ✅ |
| Daily Puzzle | ✅ | ✅ |
| Color-blind Mode | ✅ | ✅ |
| Dark Mode | ❌ | **✅** |

## 🔮 Future Enhancements

- [ ] Hard mode (must use revealed hints)
- [ ] Custom word length (4-8 letters)
- [ ] Multiplayer mode
- [ ] Leaderboards
- [ ] Sound effects
- [ ] More animation polish
- [ ] Accessibility improvements (screen reader support)

## 📄 License

This project is created for educational purposes.

## 🙏 Acknowledgments

- Original Wordle by Josh Wardle
- Flutter team for excellent documentation
- Word list sourced from common English dictionaries

---

**Made with ❤️ using Flutter**
