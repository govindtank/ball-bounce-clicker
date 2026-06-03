# 🚀 Bounce Arena

**Bounce Arena** is a neon-themed brick-breaker game built with Flutter. Smash through 15 increasingly challenging levels, chain combos, collect power-ups, and dominate the leaderboard.

## 🎮 Features

- **15 Unique Levels** — Each with distinct brick layouts and increasing difficulty
- **5 Brick Types** — Standard, Tough, Steel, Explosive, and Golden bricks
- **5 Power-Ups** — Wide Paddle, Fire Ball, Slow Motion, Extra Life, and Multi-Ball
- **Combo System** — Chain brick breaks for massive score multipliers
- **Neon Cyberpunk Visuals** — Glowing gradients, particle explosions, and screen shake
- **Level Select** — Unlock levels as you progress
- **High Score Persistence** — Your best runs are saved locally

## 🎯 How to Play

| Action | Desktop | Mobile |
|--------|---------|--------|
| Move paddle | Arrow keys / Drag | Drag with finger |
| Launch ball | Space / Click | Tap screen |
| Pause | Escape | Pause button |

Break all destroyable bricks to clear each level. Don't let the ball fall!

### Visual Effects
- **✨ Neon Particle Effects**: Beautiful burst animations on every tap
- **🌈 Gradient Score Display**: Animated score counter with color gradients
- **🎨 Dark Neon Theme**: Eye-catching dark mode with vibrant accents
- **📱 Responsive Design**: Works great on both mobile and web

## ⚡ Power-Ups

| Power-Up | Effect | Duration |
|----------|--------|----------|
| 🟦 **Wide** | Enlarges paddle | 8s |
| 🟪 **Multi** | Ball splits | Instant |
| 🟧 **Fire** | Breaks tough bricks in one hit | 10s |
| 🟩 **Slow** | Time slows down | 6s |
| ❤️ **1UP** | Extra life | Instant |

## 🔧 Build & Run

```bash
# Get dependencies
flutter pub get

# Run in browser
flutter run -d chrome

# Build for web
flutter build web --release

# Build for Android
flutter build apk
```

## 🌐 Deployment

The game auto-deploys to GitHub Pages via GitHub Actions on every push.

## 📁 Project Structure

```
lib/
├── main.dart                 # App shell & level select
├── game/
│   ├── game_engine.dart        # Core engine: physics, state, levels, models
│   └── game_painter.dart       # CustomPainter rendering
├── screens/
│   ├── home_screen.dart        # Main menu
│   └── game_screen.dart        # Game canvas & HUD
└── services/
    └── storage_service.dart    # High score persistence
```

## 🛠 Tech Stack

- **Flutter** with shared_preferences for local persistence
- Custom physics engine with AABB collision detection
- CustomPainter for 60fps game rendering
- Ticker-based game loop
