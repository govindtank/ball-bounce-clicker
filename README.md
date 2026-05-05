# 🎮 Ball Bounce Clicker

![Flutter](https://img.shields.io/badge/Flutter-3.24.0-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.5.0-0175C2?style=for-the-badge&logo=dart)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Web-FF6B9D?style=for-the-badge&logo=googlechrome)

A fun and addictive Flutter idle clicker game with stunning neon aesthetics. Tap your way to victory and become the ultimate ball bounce champion!

## 🎯 Features

### Core Gameplay
- **🎯 Tap-to-Earn**: Tap the bouncing ball to earn points
- **⚡ Score Multipliers**: Every 100 taps increases your multiplier (up to 5x!)
- **📊 Progress Tracking**: See your total taps and current multiplier in real-time
- **💾 Auto-Save**: Your progress is automatically saved

### Visual Effects
- **✨ Neon Particle Effects**: Beautiful burst animations on every tap
- **🌈 Gradient Score Display**: Animated score counter with color gradients
- **🎨 Dark Neon Theme**: Eye-catching dark mode with vibrant accents
- **📱 Responsive Design**: Works great on both mobile and web

### Web Features
- **🌐 GitHub Pages Hosted**: Play instantly at https://govindtank.github.io/ball-bounce-clicker/
- **⚡ Fast Loading**: Optimized web build with tree-shaking
- **📱 PWA Ready**: Add to home screen support

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.24.0 or higher
- Dart SDK 3.5.0 or higher

### Installation

1. Clone the repository
```bash
git clone https://github.com/govindtank/ball-bounce-clicker.git
cd ball-bounce-clicker
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

### Building for Web

```bash
# Development build
flutter build web

# Production build with base-href
flutter build web --release --base-href /ball-bounce-clicker/
```

## 🎮 How to Play

1. **Tap the Ball**: Click/tap on the pulsing ball to earn points
2. **Watch Your Score**: Your score increases with each tap
3. **Build Multipliers**: Every 100 taps increases your multiplier
4. **Reach the Goal**: Complete the game by reaching 10,000 taps!

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── constants/
│   │   └── app_constants.dart   # Colors, physics, animation constants
│   └── utils/
│       └── vector2d.dart        # 2D vector for physics calculations
├── features/
│   ├── game/
│   │   ├── models/
│   │   │   └── game_state.dart  # Game state management
│   │   ├── screens/
│   │   │   └── game_screen.dart # Main game screen
│   │   └── widgets/
│   │       ├── ball_widget.dart      # Ball rendering widget
│   │       ├── particle_effect.dart  # Tap particle effects
│   │       └── score_display.dart    # Animated score display
│   └── ui/
│       └── theme.dart           # App theme configuration
└── services/
    └── save_manager.dart        # Save/load functionality
```

## 🛠️ Tech Stack

| Technology | Description |
|------------|-------------|
| **Flutter** | Cross-platform UI framework |
| **Dart** | Programming language |
| **Provider** | State management |
| **SharedPreferences** | Local data persistence |
| **Material 3** | Design system |

## 🎨 Color Palette

| Color | Hex Code | Usage |
|-------|----------|-------|
| Deep Purple | `#7C4DFF` | Primary color |
| Neon Pink | `#FF6B9D` | Secondary/accent |
| Cyan | `#00F5FF` | Highlight effects |
| Electric Green | `#39FF14` | Multiplier indicator |
| Dark Background | `#0D0D1A` | Background color |

## 📝 Development

### Code Style
- Uses Material Design 3
- Follows Flutter best practices
- Dark theme by default with neon accents

### Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Govind Tank**
- GitHub: [@govindtank](https://github.com/govindtank)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for the design system
- All contributors who have helped improve this project

---

<p align="center">
  Made with ❤️ using Flutter
</p>
