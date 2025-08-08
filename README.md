# KLIEM - Maltese Wordle Game

A beautiful Wordle game in Maltese, built with Flutter. This is a port of the React version with enhanced styling and functionality.

## Features

- **Maltese Language Support**: Full support for Maltese characters (Ġ, Ħ, Ż)
- **Multiple Themes**: 10 beautiful Maltese-inspired themes including:
  - Baħar u Sema (Sea & Sky)
  - Ħamra tal-Art (Earth Red)
  - Blu Mediterran (Mediterranean Blue)
  - Ġebla tal-Franka (Limestone)
  - Wirt Antik (Ancient Heritage)
  - Luzzu Tradizzjonali (Traditional Luzzu)
  - Port tal-Gżira (Island Harbor)
  - Laguna Torquoise (Turquoise Lagoon)
  - Lejl fil-Port (Night Harbor)
  - Dlam ta' Għar (Deep Cave)

- **Game Modes**:
  - Daily Word Challenge
  - Practice Mode
  - Statistics tracking

- **Beautiful UI**: Modern, responsive design with smooth animations
- **Persistent Data**: Game statistics and theme preferences are saved locally

## Getting Started

1. Ensure you have Flutter installed
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Dependencies

- `shared_preferences`: For persistent data storage
- `flutter`: Core Flutter framework

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── game_stats.dart       # Game statistics model
│   └── theme_model.dart      # Theme definitions
├── screens/
│   ├── main_menu_screen.dart # Main menu UI
│   ├── wordle_game_screen.dart # Game screen
│   └── styles_modal.dart     # Theme selection modal
└── utils/
    └── maltese_words.dart    # Maltese word list
```

## Features Implemented

✅ **Core Game Logic**: Complete Wordle gameplay with Maltese word support
✅ **Theme System**: 10 beautiful Maltese-inspired themes
✅ **Statistics Tracking**: Games played, win percentage, streaks
✅ **Responsive Design**: Works on various screen sizes
✅ **Persistent Storage**: Saves game progress and preferences
✅ **Modern UI**: Smooth animations and beautiful gradients
✅ **Accessibility**: Proper contrast and readable fonts

## Future Enhancements

- [ ] Sound effects
- [ ] Haptic feedback
- [ ] Share results functionality
- [ ] Dark mode toggle
- [ ] Tutorial mode
- [ ] Achievement system

## Contributing

Feel free to contribute to this project by submitting issues or pull requests.

## License

This project is open source and available under the MIT License.
