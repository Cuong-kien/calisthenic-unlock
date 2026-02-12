# Planche Fitness

iOS fitness app with 5 progressive training levels built with SwiftUI and SwiftData.

## Project Structure

```
planche/planche/
├── plancheApp.swift          — Entry point, SwiftData container setup
├── ContentView.swift         — Wrapper for MainTabView
├── Models/
│   ├── Level.swift           — Level enum (foundation → mastery) with colors, icons, order
│   ├── Exercise.swift        — Exercise struct (not persisted)
│   ├── TrainingSession.swift — SwiftData model for completed sessions
│   └── UserProgress.swift    — SwiftData model for user progress
├── Managers/
│   ├── ExerciseStore.swift   — 10 placeholder exercises per level
│   └── ProgressManager.swift — Unlock logic, session tracking, progress reset
└── Views/
    ├── MainTabView.swift     — 3-tab navigation (Home, All Levels, Settings)
    ├── Home/
    │   └── HomeView.swift    — Current level, progress ring, start training
    ├── Levels/
    │   ├── AllLevelsView.swift      — List of 5 levels with lock status
    │   ├── LevelDetailView.swift    — 10 exercises for a level
    │   ├── ExerciseDetailView.swift — Single exercise detail
    │   └── TrainingView.swift       — Active training session flow
    └── Settings/
        └── SettingsView.swift       — Reset progress, app info
```

## Key Architecture Decisions

- **SwiftData** for persistence (TrainingSession, UserProgress models)
- **Xcode 16** file system synchronized groups (no manual pbxproj management needed)
- **Level unlock**: 5 completed training sessions on previous level required
- **Foundation** level is always unlocked by default
- **ProgressManager** is instantiated per-view using the SwiftData modelContext (not a singleton)

## Build

Open `planche/planche.xcodeproj` in Xcode and build. Target: iOS 17+.
