# 🚀 Bounce Zone

**Bounce Zone** is a neon survival dodge arena game built with Flutter. Surf a glowing ball through waves of spinning blades, homing chasers, and expanding mines — survive as long as you can, collect score gems, and climb the leaderboard.

Built as a complete rethink of the clicker concept into a **high-skill, reflex-based arcade game** with clear tutorial, escalating difficulty, and satisfying neon visual feedback.

## 🎮 How to Play

| Action | Desktop | Mobile |
|--------|---------|--------|
| Move ball | Arrow keys / WASD | Drag with finger |
| Pause / Restart | Space / Esc | Pause button |

**Objective:** Survive as long as possible. Avoid all hazards. Collect score orbs.

Each wave gets progressively harder — new hazard types appear, speeds increase, and spawn rates ramp up. One hit and it's game over.

## 🎯 Game Mechanics

### Ball
- Fast, responsive movement with drag/arrow controls
- Bounces off arena walls
- Trail particle effect for visual feedback
- **Invincibility power-up**: brief moment of immunity after pickup

### Hazards (6 types, introduced by wave)

| Wave | Hazard | Description |
|------|--------|-------------|
| 1 | **Spinner Blade** | Rotating line that arcs through the arena — learn its timing |
| 2 | **Chaser** | Slow homing orb that tracks your position |
| 3 | **Mine** | Stationary pulse mine that expands and contracts |
| 4 | **Burst** | Short-lived projectiles fired in random directions |
| 5 | **Orbit** | Twin orbs rotating around a center point |
| 6+ | **All combined** | Everything at once, faster and more frequent |

### Wave System
- Each wave lasts 20–25 seconds
- Between waves: 2-second breather with "Wave N" announcement
- 3-second grace period at wave start with invincibility
- Wave counter shown in HUD

### Power-Ups (spawn every 3 waves or on boss kills)

| Power-Up | Effect | Duration |
|----------|--------|----------|
| 🟡 **Score Magnet** | Doubles score orb collection | 8s |
| 🔵 **Invincibility** | Pass through hazards unharmed | 5s |
| 🟢 **Slow Time** | Everything slows down | 6s |
| 🟣 **Shield** | Absorbs one hit | Until used |
| ❤️ **Extra Life** | +1 life (max 3) | Instant |

### Scoring
- Small score gems: +10 pts
- Score Magnet active: +20 pts per gem
- Survival bonus: +5 pts per second alive
- Wave completion bonus: +100 × wave number
- Score multiplies with consecutive wave completions

### Difficulty Curve
- Waves 1–3: Tutorial pace, single hazard types
- Waves 4–6: Two hazard types, increased speed
- Waves 7–9: Three hazard types, chasers accelerate over time
- Waves 10+: All hazard types, maximum spawn rate, zero margin for error

## 🎨 Visual Design

- **Dark neon theme** (#0D0D1A background, #7C4DFF accent)
- **Glowing ball** with motion trail particles
- **Red/orange hazard glow** — high contrast against dark background
- **Neon text effects** — glowing score, wave announcements
- **Screen shake** on hit
- **Particle bursts** on gem collection and hazard destruction
- **Pulsing wave indicator** — arena border pulses faster as waves increase

## 📁 Project Structure

```
lib/
├── main.dart                      # App shell
├── game/
│   ├── bounce_zone.dart           # Core engine: physics, state, waves, hazards
│   └── game_painter.dart          # CustomPainter rendering + particles + HUD
├── screens/
│   ├── home_screen.dart           # Main menu with high score + how-to-play
│   └── game_screen.dart           # Game canvas, controls, overlays
└── services/
    └── storage_service.dart       # High score / best wave persistence
```

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

The game can be deployed to GitHub Pages by pushing the `build/web` directory to the `gh-pages` branch.

## 🛠 Tech Stack

- **Flutter** with shared_preferences for local persistence
- Custom 2D physics engine with AABB + circle collision
- CustomPainter for 60fps game rendering
- Ticker-based game loop
- Particle system with configurable emitters
