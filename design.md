# Design Document — Pair IQ v2.0

## Table of Contents
1. [Architecture](#architecture)
2. [Screens & States](#screens--states)
3. [UI Elements Inventory](#ui-elements-inventory)
4. [Animations](#animations)
5. [Popups & Dialogs](#popups--dialogs)
6. [Toast / Snackbar Messages](#toast--snackbar-messages)
7. [Audio](#audio)
8. [Stage Difficulty Formula](#stage-difficulty-formula)
9. [Scoring](#scoring)
10. [Data Persistence](#data-persistence)
11. [State Flow](#state-flow)
12. [Visual Theme](#visual-theme)
13. [Typography](#typography)
14. [Grid Layout](#grid-layout)

---

## Architecture

```
lib/
  main.dart                            # Entry point, ensures bindings, runs app
  app.dart                             # MaterialApp dark theme config
  models/
    game_state.dart                    # Player progress, high score, total score
    stage_data.dart                    # Per-stage config + 20 icon/color card data
  services/
    storage_service.dart               # SharedPreferences read/write for game state
    settings_service.dart              # SharedPreferences for sound mute
    sound_service.dart                 # Dual AudioPlayer: SFX + background music
  screens/
    home_screen.dart                   # Main menu: logo, stats, play button
    game_screen.dart                   # Core game: grid, stage intro, stage complete, game complete
    settings_screen.dart               # Sound toggle, game info, about section
  widgets/
    memory_card.dart                   # Flip-animated card: back/front, tap scale, shake, glow
    stage_banner.dart                  # Progress bar + stats during gameplay
    confetti_overlay.dart              # 30-piece particle burst overlay
  shared/
    app_colors.dart                    # Full color palette (20+ constants)
    app_text_styles.dart               # Typography (18 styles)
    game_shell.dart                    # Reusable scaffold: gradient bg, top bar, mute
```

### File Roles

| File | Role | Key Exports |
|------|------|-------------|
| `main.dart` | Entry point | `main()` |
| `app.dart` | App shell | `PairIQApp` |
| `game_state.dart` | Data model | `GameState` (currentStage, highScore, totalScore, bestMoves, bestTime) |
| `stage_data.dart` | Config | `StageData`, `getStageData()`, `totalStages`, `cardIcons[]`, `cardColors[]` |
| `storage_service.dart` | Persistence | `StorageService` (singleton, loadGameState, saveGameState, resetProgress) |
| `settings_service.dart` | Preference | `SettingsService` (singleton, isSoundMuted, setSoundMuted) |
| `sound_service.dart` | Audio | `SoundService` (singleton, tap/match/wrong/stageComplete/gameComplete/startMusic/stopMusic/toggleMute) |
| `home_screen.dart` | Screen | `HomeScreen` |
| `game_screen.dart` | Screen | `GameScreen` |
| `settings_screen.dart` | Screen | `SettingsScreen` |
| `memory_card.dart` | Widget | `MemoryCardWidget`, `MemoryCard` class, `generateCards()` |
| `stage_banner.dart` | Widget | `StageBanner` |
| `confetti_overlay.dart` | Widget | `ConfettiOverlay` |
| `app_colors.dart` | Theme | `AppColors` (30 color constants) |
| `app_text_styles.dart` | Theme | `AppTextStyles` (18 text styles) |
| `game_shell.dart` | Layout | `GameShell` (optional back, title, actions, mute) |

---

## Screens & States

### 1. HomeScreen

**States:**
- **Loading state**: Centered `CircularProgressIndicator` + "Loading..." text below it
- **Loaded state**: Full menu with fade-in animation (600ms `Curves.easeOut`)
- **Empty state** (first launch): High Score = 0, Last Stage = Stage 1/50

**UI Elements (top to bottom):**

| # | Element | Type | Details |
|---|---------|------|---------|
| 1 | Top bar | `GameShell` | Title "PAIR IQ", mute button right |
| 2 | Background | Gradient | `LinearGradient` top-to-bottom: #1A1A2E → #16213E → #0F3460 |
| 3 | Logo | Circle 110x110 | Red gradient (`E94560` → `C23152`), `psychology_rounded` icon 60px white, box shadow: accent 40% opacity, blur 25, spread 3 |
| 4 | Title | Text | "Pair IQ", 32px bold, letter-spacing 1.2 |
| 5 | Badge | Container | "50 STAGES OF CHALLENGE", 13px, accentLight color, accent 15% bg, pill shape 20px radius, letter-spacing 1.5 |
| 6 | Stats card | Container 18px radius | Surface 70% opacity bg, accent 25% border 1px, shadow accent 8% offset y4 blur12. Two columns: |
| 6a | | Trophy icon | `emoji_events_rounded` gold 22px, "High Score" label 11px, value 20px bold gold |
| 6b | | Divider | 1px vertical, `divider` color |
| 6c | | Flag icon | `flag_rounded` accentLight 22px, "Last Stage" label 11px, value "X / 50" 20px bold accentLight |
| 7 | Play button | `ElevatedButton` 62px | Full-width, 18px radius, accent bg, shadow accent 50%. Icon `play_arrow_rounded` 30px + "PLAY STAGE X" button text + pill badge showing high score "Xpts" |
| 8 | Reset button | `OutlinedButton` 48px | "Reset", `refresh_rounded` icon 18px accentLight, accent 40% border 1.5px |
| 9 | Settings button | `OutlinedButton` 48px | "Settings", `settings_rounded` icon 18px accentLight, same style as reset |

**Interactions:**
- Play → pushes `GameScreen` with `startStage: _lastStage`
- Reset → shows confirmation dialog (see [Dialogs](#popups--dialogs))
- Settings → pushes `SettingsScreen`
- Mute toggle → calls `_sound?.toggleMute()`, rebuilds top bar icon
- Back button (OS) → exits app (no custom handling)

---

### 2. GameScreen

**States:**
- **Stage intro overlay**: Brief full-screen overlay with stage number animation (1200ms)
- **Playing state**: Grid with cards, banner, info row
- **Card matched**: Card marked matched, slight delay (300ms) before allowing next
- **Card wrong**: Cards shake, then flip back after `revealMs`
- **Stage complete**: Overlay with checkmark, score, "Next Stage" button
- **Stage complete (high score beaten)**: Same as above + gold "NEW HIGH SCORE!" badge
- **Game complete** (stage 50): Trophy animation, final score, "Play Again"
- **Last stage reached** (in stage complete): Button text changes to "See Results →"

**UI Elements (top to bottom) - Playing State:**

| # | Element | Type | Details |
|---|---------|------|---------|
| 1 | Top bar | `GameShell` | Dynamic title: "Stage X" / "Stage X Complete!" / "Congratulations!". Back button + mute button |
| 2 | StageBanner | Widget | See [StageBanner](#widget-stagebanner) |
| 3 | Info row | Row | Left: `check_circle_outline` icon (green if >0 pairs found, muted otherwise) + "X/Y" pairs. Right: `speed_rounded` icon + "Xms" speed, `touch_app_rounded` icon + "X" moves |
| 4 | Card grid | `GridView.builder` | Dynamic columns (4 or 5), padding h12 v8, spacing 8px. Cards are `MemoryCardWidget` (see [MemoryCardWidget](#widget-memorycardwidget)) |
| 5 | Background | Same gradient as HomeScreen | From `GameShell` |

**UI Elements - Stage Complete (overlay replacing grid):**

| # | Element | Type | Details |
|---|---------|------|---------|
| 1 | Checkmark circle | Container 100x100 | Green gradient (`4CAF50` → `388E3C`), `check_rounded` icon 56px white. Shadow green 40% blur20 spread3. Animates scale 0.3→1.0 (elasticOut) |
| 2 | Title | Text | "Stage X Complete!", 28px bold green, letter-spacing 1.2 |
| 3 | Score card | Container | Surface 60% bg, 12px radius. Shows "X moves • +Y pts" (16px textSecondary), "Score: Z" (gold 22px). If new high score: gold badge "NEW HIGH SCORE!" with trophy icon |
| 4 | Next Stage button | `ElevatedButton` 58px | Full-width, 18px radius, accent bg, shadow accent 50%. Text: "Next Stage →" or "See Results →" on last stage |
| 5 | Retry button | `OutlinedButton` 46px | "Retry This Stage", accent 40% border 1.5px, 14px radius |
| 6 | Confetti overlay | `ConfettiOverlay` | 30 pieces, gold accent, ignores pointer input. Driven by `_celebrateAnimation` |
| 7 | Fade transition | `FadeTransition` | Opacity driven by `_celebrateAnimation` |

**UI Elements - Game Complete (stage 50):**

| # | Element | Type | Details |
|---|---------|------|---------|
| 1 | Trophy circle | Container 130x130 | Gold gradient (`FFD700` → `FFA500`), `emoji_events_rounded` icon 72px white. Shadow gold 50% blur35 spread6. Pulsing scale 0.85↔1.0 (1500ms, reverse) |
| 2 | Title | Text | "You Win!", 28px bold green |
| 3 | Subtitle | Text | "All 50 Stages Completed!", 16px textSecondary |
| 4 | Score card | Container | Surface 70% bg, gold 30% border 1px, 16px radius. Shows final score (36px bold gold), "Final Score" label, divider, high score (22px bold accentLight), "High Score" label |
| 5 | Play Again button | `ElevatedButton` 58px | Full-width, 18px radius, gold bg, black text, shadow gold 50%. Resets to stage 1 |
| 6 | Confetti overlay | `ConfettiOverlay` | 30 pieces, gold accent, driven by `_pulseController` (repeating) |

**Stage Intro Overlay:**

| # | Element | Type | Details |
|---|---------|------|---------|
| 1 | Backdrop | Container | Full-screen, `overlay` color (black 50%) |
| 2 | Flag icon circle | Container 80x80 | Circle, accent border 3px, accent 10% bg, `flag_rounded` icon 40px accent |
| 3 | "STAGE" text | Text | 64px bold, textPrimary, letter-spacing 4, shadow accentGlow blur30 |
| 4 | Stage number | Text | 80px bold, accent color, letter-spacing 4, shadow accentGlow blur40 |
| 5 | Info text | Text | "X pairs • Xms speed", 13px textSecondary |
| 6 | Animation | Scale + Fade | Scale 0.3→1.0 (elasticOut 1200ms), fade 1.0→0.0 starting at 50% of animation |

**Interactions:**
- Card tap → if not disabled/flipped/matched: flip card, track first/second selection
- Two cards selected → `_checkMatch()`: if match, play match sound, 300ms delay, mark matched; if wrong, play wrong sound, stagger `_triggerWrongMatch`, flip back after `revealMs`
- Stage complete → auto-saves, shows overlay
- "Next Stage" → saves state, advances to `_gameState.currentStage + 1`
- "Retry" → resets stage, re-shuffles cards
- Back button → saves state, pops to home

---

### 3. SettingsScreen

**States:**
- **Loaded state**: Scrollable content with audio toggle and info

**UI Elements (top to bottom):**

| # | Element | Type | Details |
|---|---------|------|---------|
| 1 | Top bar | `GameShell` | "Settings", back button, mute button |
| 2 | "Audio" section header | Text | 22px bold heading |
| 3 | Sound toggle tile | Container | 16px radius, surface 60% bg, accent 20% border. Row: icon container (40x40, accent 10% bg, 12px radius) with `volume_up_rounded` accentLight → title "Sound Effects & Music" + subtitle "Tap sounds, match effects, and background music" → `Switch` (activeTrack: accent, inactiveThumb: textMuted, inactiveTrack: progressBg) |
| 4 | "Game" section header | Text | 22px bold heading |
| 5 | Info tile: Stage Range | Container | Same style as tile 3 but no trailing widget. Icon `flag_rounded`, title "Stage Range", subtitle "50 stages (3–7 pairs, 2200–700ms reveal)" |
| 6 | Info tile: Scoring | Container | Same. Icon `score_rounded`, title "Scoring", subtitle "Stage pts + pairs bonus, high score tracked" |
| 7 | Info tile: Save | Container | Same. Icon `storage_rounded`, title "Save", subtitle "Auto-saves after each stage, resumes last stage" |
| 8 | "About" section header | Text | 22px bold heading |
| 9 | About card | Container | 16px radius, surface 60% bg, accent 15% border. Row: mini logo circle (40px, red gradient, psychology icon 22px) + "Pair IQ" 17px bold + "Version 2.0" 13px textSecondary. Below: description text "50 stages of progressive memory challenges..." 14px textSecondary, height 1.6 |

---

### Widget: StageBanner

**Location:** Top of GameScreen during playing state

| Element | Type | Details |
|---------|------|---------|
| Row | Row | Three stat items |
| Flag stat | Icon + Text | `flag_rounded` 16px accentLight + "Stage X/50" 13px bold textPrimary |
| Moves stat | Icon + Text | `touch_app_rounded` 16px accentLight + "Xmv" 13px bold textPrimary |
| Score stat | Icon + Text | `emoji_events_rounded` 16px accentLight + "X" 13px bold textPrimary |
| Progress bar | `LinearProgressIndicator` | 6px height, 6px radius clip, `progressBg` bg, `accent` color fill, value = currentStage/totalStages |

---

### Widget: MemoryCardWidget

**Location:** Inside the game grid

**States:**
- **Hidden (back)**: Red gradient card, `?` icon 32px 90% white, "?" text 12px 70% white
- **Flipped (front)**: White card, colored icon + number, colored border 2.5px, colored shadow
- **Matched**: Front card with reduced border (2px, 50% color), reduced shadow, pulsing glow: `BoxShadow` with color alpha animated 0.2↔0.5, blur 8↔16, spread 1↔3 (800ms reverse loop)
- **Wrong**: Shake animation: horizontal offset sequence 0→8→-6→4→-2→0 over 400ms
- **Disabled**: GestureDetector onTap = null, no interaction

**Animations (in order of activation):**
1. **Tap scale**: 150ms scale 1.0→0.92→1.0 (on tap down/up)
2. **Flip**: 400ms 3D Y-axis rotation using `Matrix4.rotateY`. Two-phase `TweenSequence`: 0→π/2 (weight 50) then π/2→π (weight 50). At midpoint (>π/2), switches from back to front widget
3. **Glow pulse** (matched only): 800ms repeat/reverse, adjusts shadow alpha/blur/spread
4. **Wrong shake**: 400ms horizontal `Transform.translate` using 5-point `TweenSequence`, auto-resets

**Properties:**
- `card`: MemoryCard data (id, icon, color, isFlipped, isMatched)
- `onTap`: Tap callback
- `index`: Card position in grid
- `disabled`: Blocks interaction when true
- `wrongMatch`: Triggers shake animation

---

### Widget: ConfettiOverlay

**Location:** Stacked above game content during celebrations

| Element | Type | Details |
|---------|------|---------|
| Pieces | 30 `ConfettiPiece` | Each has: start (x, y normalized), end (x, y), rotation, size (4-10px), color (random from [accent, accentLight, gold, goldLight, success]), delay (0-0.3s) |
| Shape | Container | Width = size, height = size*1.5, 2px borderRadius |
| Animation | Per piece | Position interpolated start→end. Opacity: 0 before delay, 1 during (0→0.8), fades out (0.8→1.0). Rotation applied via `Transform.rotate` |
| Trajectory | Radial + slight downward | Random angle, random distance, +0.2 downward bias |
| Sizing | `LayoutBuilder` | Converts normalized coords to pixel positions |

---

## Animations

### Complete Animation Inventory

| Animation | Widget | Duration | Curve | Trigger | Description |
|-----------|--------|----------|-------|---------|-------------|
| Home fade-in | HomeScreen body | 600ms | `easeOut` | Screen loaded | Entire body fades in |
| Card tap scale | MemoryCardWidget | 150ms | `easeInOut` | Tap down/up | Scales 1.0→0.92→1.0 |
| Card flip | MemoryCardWidget | 400ms | `easeInOut` | Card selection | 3D Y-axis rotation, swaps front/back at midpoint |
| Card glow | MemoryCardWidget | 800ms | `reverse` | Card matched | Shadow pulse: alpha 0.2↔0.5, blur 8↔16 |
| Card shake | MemoryCardWidget | 400ms | `linear` | Wrong match | Horizontal offset 0→8→-6→4→-2→0 |
| Stage intro scale | GameScreen overlay | 1200ms | `elasticOut` | Stage starts | Scale 0.3→1.0 |
| Stage intro fade | GameScreen overlay | 1200ms | `easeOut` at 50% | Stage starts | Fade 1.0→0.0 |
| Stage complete scale | Stage complete icon | 1200ms | `elasticOut` | Stage cleared | Scale 0.3→1.0 |
| Stage complete fade | Stage complete panel | 1200ms | - | Stage cleared | Opacity 0→1 |
| Confetti burst | ConfettiOverlay | 1200ms | - | Stage cleared / game won | 30 particles explode from center |
| Trophy pulse | Game complete trophy | 1500ms | `reverse` | Game complete | Scale 0.85↔1.0 |
| Confetti continuous | ConfettiOverlay | 1500ms | `reverse` | Game complete | Continuous particle burst while on screen |

### Animation Controller Summary

| Controller | Owner | Purpose |
|------------|-------|---------|
| `_fadeController` | HomeScreen | Entrance fade-in |
| `_flipController` | MemoryCardWidget (per card) | Card flip |
| `_tapController` | MemoryCardWidget (per card) | Tap scale feedback |
| `_shakeController` | MemoryCardWidget (per card) | Wrong match shake |
| `_glowController` | MemoryCardWidget (per card) | Matched card glow pulse |
| `_celebrateController` | GameScreen | Stage complete animations + confetti |
| `_pulseController` | GameScreen | Game complete trophy pulse + confetti |
| `_introController` | GameScreen | Stage intro overlay |

---

## Popups & Dialogs

### 1. Reset Progress Confirmation Dialog

**Trigger:** Tapping "Reset" on HomeScreen

**Type:** `AlertDialog`

**Appearance:**
- Background: `surface` (#16213E)
- Shape: 20px radius, 1px border `accent` 30%
- Title row: `warning_amber_rounded` icon 24px `warning` color + "Reset Progress" 20px bold
- Content: "This will erase all your progress including high score and current stage. This cannot be undone." 15px textSecondary, height 1.5
- Actions row (bottom right): "Cancel" textButton (textSecondary) / "Reset" textButton (accent, bold)

**Outcome:**
- Cancel → closes dialog, no action
- Reset → clears game state via `StorageService.resetProgress()`, updates UI, shows success snackbar

---

## Toast / Snackbar Messages

### 1. Progress Reset Success Toast

**Trigger:** After confirming "Reset" in dialog

**Type:** `SnackBar`

**Appearance:**
- Background: `surfaceLight` (#1E2A4A)
- Behavior: `SnackBarBehavior.floating`
- Shape: 12px radius
- Content: Row: `check_circle_outline` icon 20px `success` + "Progress has been reset" 14px bold
- Duration: 2 seconds

### 2. New High Score Badge (not a toast, embedded in UI)

**Trigger:** When `_gameState.totalScore > _gameState.highScore` at stage complete

**Location:** Inside the stage complete score card, below the score

**Appearance:**
- Container: gold 15% bg, gold 40% border, 20px radius pill
- Icon: `emoji_events_rounded` 16px gold
- Text: "NEW HIGH SCORE!" 13px bold gold, letter-spacing 1.0

---

## Audio

6 procedurally generated WAV files in `assets/sounds/`:

| File | Duration | Freq | Envelope | Played When |
|------|----------|------|----------|-------------|
| `tap.wav` | 60ms | 1200Hz | Sharp attack, fast decay (40%) | Any card tap |
| `match.wav` | 250ms | 880Hz + 1320Hz (two-tone chord) | Fade out at 60% | Two cards match |
| `wrong.wav` | 200ms | 280Hz + 200Hz (low dissonant) | Fade out at 40% | Two cards don't match |
| `stage_complete.wav` | 500ms | 523Hz + 784Hz (C5 + G5) | Fade out at 70% | All pairs found (stages 1-49) |
| `game_complete.wav` | 900ms | 523Hz + 1047Hz (C5 + C6) | Fade out at 80% | All 50 stages done |
| `background_loop.wav` | 4s | 220Hz + 330Hz + 440Hz (A3+E4+A4 ambient) | Slow amplitude modulation at 0.25Hz, volume 15% | Continuous loop while on HomeScreen |

### SoundService API

| Method | AudioPlayer | Effect |
|--------|-------------|--------|
| `tap()` | SFX (stops previous) | Plays `tap.wav` |
| `match()` | SFX (stops previous) | Plays `match.wav` |
| `wrong()` | SFX (stops previous) | Plays `wrong.wav` |
| `stageComplete()` | SFX (stops previous) | Plays `stage_complete.wav` |
| `gameComplete()` | SFX (stops previous) | Plays `game_complete.wav` |
| `startMusic()` | Music (loop) | Plays `background_loop.wav` with `ReleaseMode.loop` |
| `stopMusic()` | Music | Stops music |
| `toggleMute()` | Both | Toggles `_muted` flag; pauses or resumes music |

### Audio Flow

```
App launch → HomeScreen.initState() → SoundService.getInstance() → startMusic()
  ↓
User navigates to GameScreen → music continues playing
  ↓
Card tap → tap()
Card match → match()
Card wrong → wrong()
Stage complete → stageComplete()
Game complete → gameComplete()
  ↓
User navigates back → GameScreen.dispose() → (music continues on HomeScreen)
  ↓
App paused/closed → audio stops (no explicit dispose on app close)
```

---

## Stage Difficulty Formula

```dart
StageData getStageData(int stage) {
  clamped = stage.clamp(1, 50);

  pairs = clamped <= 10 ? 3
        : clamped <= 20 ? 4
        : clamped <= 30 ? 5
        : clamped <= 40 ? 6
        : 7;

  revealMs = (2200 - (clamped - 1) * 30).clamp(700, 2200);

  return StageData(stage, pairs, revealMs);
}
```

### Full Difficulty Table

| Stage | Pairs | Cards | Columns | Reveal Time |
|-------|-------|-------|---------|-------------|
| 1 | 3 | 6 | 4 | 2200ms |
| 5 | 3 | 6 | 4 | 2080ms |
| 10 | 3 | 6 | 4 | 1930ms |
| 11 | 4 | 8 | 4 | 1900ms |
| 15 | 4 | 8 | 4 | 1780ms |
| 20 | 4 | 8 | 4 | 1630ms |
| 21 | 5 | 10 | 5 | 1600ms |
| 25 | 5 | 10 | 5 | 1480ms |
| 30 | 5 | 10 | 5 | 1330ms |
| 31 | 6 | 12 | 4 | 1300ms |
| 35 | 6 | 12 | 4 | 1180ms |
| 40 | 6 | 12 | 4 | 1030ms |
| 41 | 7 | 14 | 5 | 1000ms |
| 45 | 7 | 14 | 5 | 880ms |
| 50 | 7 | 14 | 5 | 700ms |

Grid columns change to keep card sizes comfortable:
- 4 cols for ≤12 cards (6–12 cards, card aspect ratio 1.0)
- 5 cols for >12 cards (14 cards, card aspect ratio 0.9)

### Card Icon/Color Selection

During `generateCards()`, icons are selected from a pool of 20. Used IDs are tracked across restarts to prevent same-icon repetition. If more pairs are needed than available unique icons, IDs are reused from the full pool.

---

## Scoring

```
Stage points = stageNumber × 10 + (pairs × 50 ÷ moves)
```

- `stageNumber`: Current stage (1-50), base multiplier
- `pairs`: Pairs for this stage (3-7), higher = bigger bonus pool
- `moves`: How many pair attempts the player used (fewer = higher score)
- Minimum moves divisor: 1 (prevents division by zero)

**Stage completion bonus:**
```
on "Next Stage": totalScore += stageNumber × 50
```

**High score:**
```
highScore = max(totalScore during the session, historical highScore)
```

**Example scoring:**
- Stage 10, 3 pairs, 6 moves: `10×10 + (3×50/6) = 100 + 25 = 125 pts`
- Stage 30, 5 pairs, 10 moves: `30×10 + (5×50/10) = 300 + 25 = 325 pts`
- Stage 50, 7 pairs, 14 moves: `50×10 + (7×50/14) = 500 + 25 = 525 pts`

---

## Data Persistence

All data stored via `shared_preferences` under two keys:

### `game_state` key (JSON string)

```json
{
  "currentStage": 1,
  "highScore": 0,
  "totalScore": 0,
  "bestMoves": 0,
  "bestTime": 0
}
```

### `sound_muted` key (boolean)

```json
true / false
```

### Persistence Triggers

| When | What is saved | Method |
|------|--------------|--------|
| GameScreen back press | `GameState` | `storage.saveGameState()` |
| After "Next Stage" tap | `GameState` (with incremented stage, score) | `storage.saveGameState()` |
| Game complete (stage 50) | `GameState` (final) | `storage.saveGameState()` |
| "Play Again" from game complete | `GameState` (reset to stage 1, score 0) | `storage.saveGameState()` |
| "Reset Progress" confirmed | `GameState` (fresh, all defaults) | `storage.resetProgress()` |
| Mute toggle | `sound_muted` boolean | `settings.setSoundMuted()` |
| Settings mute switch | `sound_muted` boolean | `settings.setSoundMuted()` |

### Load Triggers

| When | What is loaded | Method |
|------|---------------|--------|
| HomeScreen init | `GameState` + `isSoundMuted` | `storage.loadGameState()` + `settings.isSoundMuted` |
| GameScreen init | `GameState` | `storage.loadGameState()` |
| SoundService init | `isSoundMuted` | `settings.isSoundMuted` |

---

## State Flow

```
APP LAUNCH
  │
  ├── main() → WidgetsFlutterBinding.ensureInitialized()
  │
  └── HomeScreen.initState()
        ├── SoundService.getInstance() → SettingsService → check mute
        ├── StorageService.getInstance() → load GameState
        ├── Set highScore, lastStage from state
        ├── Start background music
        └── Fade in UI
              │
              ├── "PLAY STAGE X" tapped
              │     └── GameScreen(startStage: lastStage)
              │           ├── Load GameState
              │           ├── Show Stage Intro (1200ms)
              │           ├── Generate cards for stage
              │           ├── Play game until all pairs found
              │           ├── Stage Complete
              │           │     ├── Calculate score, update state
              │           │     ├── Check/save high score
              │           │     ├── Show confetti + overlay
              │           │     ├── "Next Stage" → save state → repeat
              │           │     └── "Retry" → regenerate same stage
              │           ├── Stage 50 Complete → Game Complete
              │           │     ├── Save final state
              │           │     ├── Show trophy + continuous confetti
              │           │     └── "Play Again" → reset to stage 1 → pop
              │           └── Back press → save state → pop
              │
              ├── "Reset" tapped
              │     └── Confirmation dialog
              │           ├── Cancel → nothing
              │           └── Confirm → reset state → show snackbar
              │
              ├── "Settings" tapped
              │     └── SettingsScreen
              │           └── Back press → pop
              │
              └── Mute toggle → SoundService.toggleMute()
```

---

## Visual Theme

### Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#1A1A2E` | Primary bg (dark blue-black) |
| `surface` | `#16213E` | Card/surface bg |
| `surfaceLight` | `#1E2A4A` | Snackbar bg |
| `cardBg` | `#0F3460` | Secondary card bg |
| `shellBg` | `#0D1B2A` | Top bar bg |
| `accent` | `#E94560` | Primary accent (red) |
| `accentLight` | `#FF6B81` | Light accent, secondary elements |
| `accentGlow` | `#40E94560` | Glow shadow for accent |
| `success` | `#4CAF50` | Success states |
| `successLight` | `#81C784` | Light success |
| `warning` | `#FF9800` | Warning icon |
| `error` | `#F44336` | Error states |
| `gold` | `#FFD700` | High score, trophies |
| `goldLight` | `#FFF3CD` | Light gold bg |
| `goldGlow` | `#40FFD700` | Gold glow shadow |
| `textPrimary` | `#EEEEEE` | Main text |
| `textSecondary` | `#AAAAAA` | Secondary text |
| `textMuted` | `#666666` | Muted text |
| `divider` | `#2A2A4A` | Dividers, progress bg |
| `progressBg` | `#2A2A4A` | Progress bar track |
| `overlay` | `#80000000` | Modal overlay |

### Gradients

| Gradient | Colors | Location |
|----------|--------|----------|
| Screen bg | `#1A1A2E` → `#16213E` → `#0F3460` | `GameShell` body |
| Logo circle | `#E94560` → `#C23152` | HomeScreen logo |
| Card back | `#E94560` → `#C23152` | MemoryCardWidget back |
| Stage complete checkmark | `#4CAF50` → `#388E3C` | Stage complete icon |
| Game complete trophy | `#FFD700` → `#FFA500` | Game complete icon |

### Shadows

| Element | Shadow |
|---------|--------|
| Logo | `accent` 40%, blur 25, spread 3 |
| Stats card | `accent` 8%, blur 12, offset y4 |
| Play button | `accent` 50%, blur size depends on elevation |
| Card back | `accent` 30%, blur 8, offset y3 |
| Card front | `card.color` 30%, blur 10, offset y3 |
| Matched card glow | `card.color` 20-50%, blur 8-16, spread 1-3 (animated) |
| Stage complete checkmark | `success` 40%, blur 20, spread 3 |
| Game complete trophy | `gold` 50%, blur 35, spread 6 |
| Stage intro number | `accentGlow`, blur 40 |
| Stage intro "STAGE" | `accentGlow`, blur 30 |

### Borders

| Element | Width | Color | Radius |
|---------|-------|-------|--------|
| Stats card | 1px | `accent` 25% | 18px |
| Play button | - | - | 18px |
| Secondary buttons | 1.5px | `accent` 40% | 14px |
| Card front | 2.5px | `card.color` | 14px |
| Card front (matched) | 2px | `card.color` 50% | 14px |
| Card back | - | - | 14px |
| Settings tile | 1px | `accent` 15-20% | 16px |
| About card | 1px | `accent` 15% | 16px |
| Dialog | 1px | `accent` 30% | 20px |
| Confirmation pill | 1px | `gold` 40% | 20px |

---

## Typography

| Style | Size | Weight | Color | Letter-Spacing | Usage |
|-------|------|--------|-------|----------------|-------|
| `title` | 32 | Bold | textPrimary | 1.2 | HomeScreen title |
| `titleGlow` | 32 | Bold | textPrimary | 1.2 | HomeScreen title (alt) |
| `heading` | 22 | SemiBold | textPrimary | - | Section headers |
| `body` | 16 | Normal | textPrimary | - | Body text |
| `bodySmall` | 13 | Normal | textSecondary | - | Subtitles, info |
| `button` | 20 | SemiBold | buttonText | 1.0 | Primary buttons |
| `buttonSmall` | 15 | SemiBold | buttonText | - | Small buttons |
| `success` | 28 | Bold | success | 1.2 | "Stage X Complete!" |
| `gold` | 22 | Bold | gold | 1.0 | Score display |
| `goldLarge` | 36 | Bold | gold | 1.5 | Final score |
| `stageLabel` | 14 | Medium | textSecondary | - | Info row text |
| `scoreLabel` | 16 | Bold | accentLight | - | High score |
| `highScoreLabel` | 14 | Bold | gold | - | "NEW HIGH SCORE!" badge |
| `toast` | 14 | SemiBold | textPrimary | - | Snackbar text |
| `overlay` | 64 | Bold | textPrimary | 4.0 | "STAGE" text |
| `dialogTitle` | 20 | Bold | textPrimary | - | Dialog title |
| `dialogContent` | 15 | Normal | textSecondary | - | Dialog body |

---

## Grid Layout

### Column Calculation

```dart
int get columns {
  if (totalCards <= 12) return 4;  // 6, 8, 12 cards
  return 5;                         // 14+ cards
}
```

### Aspect Ratio

```dart
double get childAspectRatio => totalCards <= 12 ? 1.0 : 0.9;
```

### Grid Matrix by Stage

| Stage Range | Pairs | Cards | Columns | Rows | Aspect Ratio |
|-------------|-------|-------|---------|------|-------------|
| 1-10 | 3 | 6 | 4 | 2 (last row 2) | 1.0 |
| 11-20 | 4 | 8 | 4 | 2 | 1.0 |
| 21-30 | 5 | 10 | 5 | 2 | 1.0 |
| 31-40 | 6 | 12 | 4 | 3 | 1.0 |
| 41-50 | 7 | 14 | 5 | 3 (last row 4) | 0.9 |

### Card Sizing (approximate on 360px wide screen)

| Columns | Card Width | Card Height | Padding |
|---------|-----------|-------------|---------|
| 4 | ~76px | ~76px (1.0) or ~68px (0.9) | 12px horizontal + 8px spacing |
| 5 | ~58px | ~64px (0.9) | 12px horizontal + 8px spacing |

### Grid Padding

- Horizontal: 12px on each side
- Between cards: 8px both axis
- Top padding: 8px
- Bottom: natural from Expanded

### Scroll Physics

`NeverScrollableScrollPhysics()` — grid is sized to exactly fit all cards without scrolling.

---

## Responsive Behavior

The entire UI uses relative sizing (SizedBox, Flex, padding) except for:
- Icon sizes (fixed px)
- Font sizes (fixed px)
- Grid columns (calculated from card count, not screen width)
- Card aspect ratio (adjusted per stage)

Expected minimum device width: 320px (iPhone SE). No explicit breakpoints.

---

## Performance Considerations

- Each `MemoryCardWidget` owns 4 `AnimationController`s. With max 14 cards on screen: 56 controllers. Acceptable with `SingleTickerProviderStateMixin` on each card.
- `ConfettiOverlay` uses `LayoutBuilder` + 30 `Positioned` widgets + `Opacity` + `Transform`. Only active during celebrations.
- `GameShell` gradients use `const BoxDecoration` — no rebuild overhead.
- All audio files are under 180KB total. Background loop is 4s, ~176KB WAV.
- `SharedPreferences` reads are cached in memory after first load.
