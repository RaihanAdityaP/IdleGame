# Idle Warung

> A simple idle clicker game built with Flutter. Tap to earn, upgrade your stall, and watch the coins roll in — even when you're not playing.

This project was built as a case study in Flutter game development, with a focus on clean architecture, an efficient game loop, and local data persistence.

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | UI and rendering |
| Dart | Programming language |
| Provider + ChangeNotifier | State management |
| SharedPreferences | Local data persistence |

---

## Features

- **Auto income** — coins accumulate every 100ms based on the total CPS from owned upgrades
- **8 upgrades** with scaling prices (increases 15% per purchase), split into two categories: IDLE (auto CPS) and TAP (manual CPC)
- **4 random event types** — Airdrop, Rush Hour, VIP Customer, and Disaster — triggered randomly every 30–90 seconds
- **Milestone rewards** — positive events are automatically triggered when coins reach 1K, 10K, 50K, 200K, and 1M
- **Tap animations** — scale press, pulse border, and floating numbers with randomized horizontal offset
- **Auto-save** every 5 seconds and immediately after each upgrade purchase

---

## Architecture

```
Flutter Widgets  →  GameState (ChangeNotifier)  →  SharedPreferences
   (UI layer)        (single source of truth)        (local storage)
```

All widgets call `context.watch<GameState>()` and rebuild automatically whenever state changes. No local widget state exists outside of animations.

### Core Components

| Component | Role |
|---|---|
| `MainScreen` | Root screen, assembles all panels |
| `TapZone` | Primary tap area, manages `AnimationController` for scale and pulse |
| `ShopPanel` | List of purchasable upgrades |
| `StatsPanel` | Displays real-time game statistics |
| `ActiveEventBar` | Shows the currently active event with a live countdown |
| `GameState` | All game logic: timers, upgrades, events, save/load |

---

## Timer System

The game runs on three parallel timers that start as soon as `GameState` is initialized:

| Timer | Interval | Function |
|---|---|---|
| Tick | 100ms | Adds coins automatically, checks milestones |
| Save | 5 seconds | Auto-saves state to SharedPreferences |
| Event | 30–90 seconds (random) | Triggers a random event, schedules the next recursively |

---

## Upgrades

| Name | Base Cost | Bonus | Type |
|---|---|---|---|
| Plastic Cup | 10 | +0.5/s | IDLE |
| New Cart | 100 | +3/s | IDLE |
| Extra Menu | 500 | +12/s | IDLE |
| Waiter | 2,000 | +40/s | IDLE |
| Express Kitchen | 10,000 | +150/s | IDLE |
| Pro Spatula | 50 | +5/tap | TAP |
| Quick Hands | 300 | +20/tap | TAP |
| Secret Recipe | 1,500 | +80/tap | TAP |

Price formula: `baseCost × 1.15^owned`

---

## Events

| Event | Effect | Duration |
|---|---|---|
| Airdrop | Instant coin bonus (`max(value, cps × 10)`) | 4 seconds |
| Rush Hour | CPS ×2 | 15 seconds |
| VIP Customer | Tap ×5 | 20 seconds |
| Disaster | Pay a penalty or lose 30% CPS | 10 seconds |

---

## Data Persistence

The following values are saved to SharedPreferences:

- `coins` — current coin count
- `upgrades` — `owned` count per upgrade, stored as `id:owned,id:owned,...`
- `milestones` — list of already-reached milestones

> **Design note:** Only the `owned` count per upgrade is persisted — not `_baseCps` or `_baseCpc` directly. On `load()`, those values are recalculated from `owned`. This prevents data corruption if upgrade definitions change in future versions.

---

## Getting Started

### Install APK (Android)

Download the APK from the releases page:

[github.com/RaihanAdityaP/IdleGame/releases/tag/v1.0.0](https://github.com/RaihanAdityaP/IdleGame/releases/tag/v1.0.0)

Extract the `.zip` file, then install `IdleWarungv1.0.0.apk` on your Android device. Make sure **Install from unknown sources** is enabled in your device settings.

### Run from Source

Requires Flutter SDK to be installed.

```bash
git clone https://github.com/RaihanAdityaP/IdleGame.git
cd IdleGame
flutter pub get
flutter run
```

---

## License

MIT
