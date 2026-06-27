# 🧠 Pair IQ

[![Flutter](https://img.shields.io/badge/Flutter-3.12+-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-lightgrey)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Pair IQ** is a 50-stage progressive memory challenge built with Flutter. Each stage raises the difficulty with more pairs and faster reveal times, pushing your memory to the limit. Featuring 3D card flips, particle confetti, procedural audio, and a sleek dark theme.

---

## ✨ Features

- **50 Stages** — Progressive difficulty curve (3→7 pairs, 2200→700ms reveal)
- **High Score** — Automatically tracked across all sessions
- **Auto-Resume** — Pick up exactly where you left off
- **3D Card Animations** — Flip, tap scale, wrong-match shake, matched glow
- **Stage Intro** — Animated overlay showing stage number and difficulty
- **Confetti Burst** — 30-particle celebration on stage clear
- **Procedural Soundtrack & SFX** — 6 dynamically generated WAV files
- **Sound Toggle** — Mute all audio from the top bar or settings
- **Dark Theme** — Deep navy gradient with crimson accents
- **100% Local** — All data stored on-device, no internet required

---

## 📱 Screens

| Screen | Preview |
|--------|---------|
| **Home** | Animated logo, high score, last stage, play button, reset + settings |
| **Game** | Stage intro overlay → card grid with progress bar, info row, flip animations |
| **Stage Complete** | Checkmark animation, score card, new-high-score badge, confetti |
| **Game Complete** | Pulsing trophy, final score display, confetti rain |
| **Settings** | Sound toggle, game info tiles, about section |

---

## 📊 Stage Progression

| Stages | Pairs | Cards | Reveal Time |
|--------|-------|-------|-------------|
| 1–10   | 3     | 6     | 2200–1930ms |
| 11–20  | 4     | 8     | 1900–1630ms |
| 21–30  | 5     | 10    | 1600–1330ms |
| 31–40  | 6     | 12    | 1300–1030ms |
| 41–50  | 7     | 14    | 1000–700ms |

Grid adapts between 4 and 5 columns to keep card sizes comfortable across all stages.

---

## 🚀 Quick Start

```bash
# Clone the repo
git clone https://github.com/rutambh/pairiq.git
cd pairiq

# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Build for release
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
flutter build windows      # Windows
flutter build macos        # macOS
flutter build linux        # Linux
```

---

## 🏗️ Tech Stack

| Dependency | Purpose |
|------------|---------|
| Flutter SDK | Cross-platform UI framework |
| `shared_preferences` | Persistent key-value storage |
| `audioplayers` | WAV playback (SFX + looping background music) |
| `google_fonts` | Plus Jakarta Sans typography |

---

## 📁 Project Structure

```
lib/
├── main.dart                     # Entry point
├── app.dart                      # MaterialApp + theme config
├── models/
│   ├── game_state.dart           # Player progress models
│   └── stage_data.dart           # Per-stage difficulty configuration
├── screens/
│   ├── home_screen.dart          # Main menu
│   ├── game_screen.dart          # Core gameplay loop
│   └── settings_screen.dart      # Preferences & about
├── services/
│   ├── settings_service.dart     # Sound mute persistence
│   ├── sound_service.dart        # Dual AudioPlayer management
│   └── storage_service.dart      # Game state read/write
├── shared/
│   ├── app_colors.dart           # Full color palette
│   ├── app_text_styles.dart      # Typography system
│   └── game_shell.dart           # Reusable scaffold
└── widgets/
    ├── confetti_overlay.dart     # Particle burst effect
    ├── memory_card.dart          # Flip-animated card widget
    └── stage_banner.dart         # HUD during gameplay
```

---

## 🎨 Design

Pair IQ features a **dark navy** aesthetic with **crimson red** accents and **gold** reward highlights. The design philosophy balances high-energy gameplay with accessible, multi-generational usability.

- **Typography**: Plus Jakarta Sans — friendly, rounded terminals
- **Animations**: 3D card flips, elastic stage intros, particle confetti
- **Color Language**: Crimson for interaction, green for success, gold for achievement

---

## 🧪 Testing

```bash
flutter test
```

---

## 📄 License

This project is licensed under the MIT License.
