# Planche Fitness

> SwiftUI iOS app for progressive calisthenics skill training. Users choose a target skill (e.g. Planche, Handstand, Front Lever) and follow a structured level-based program to reach it.

## Stack

SwiftUI · SwiftData · Swift · Xcode 26.2 · iOS 17+ target · No third-party dependencies

## Build

Open `planche.xcodeproj` in Xcode. Run destination: **iPhone 17** (iOS 26.2 — "iPhone 16" no longer exists).

```
xcodebuild -project planche.xcodeproj -scheme planche -destination 'platform=iOS Simulator,name=iPhone 17' build
```

## Structure

```
planche/planche/
├── plancheApp.swift          — @main, ModelContainer (TrainingSession, UserProgress, ExerciseCustomization)
├── ContentView.swift         — wraps MainTabView
├── Models/
│   ├── Level.swift           — Level enum (7 levels), Color(hex:), Color.trainingBlue
│   ├── Exercise.swift        — Exercise struct: name, level, reps, sets, durationSeconds, exerciseType, repsByDifficulty
│   ├── ProgressiveExercise.swift — ExerciseStage (SpriteConfig optional) + ProgressiveExercise (4 stages)
│   ├── ExerciseCustomization.swift — SwiftData: custom reps/duration per exercise
│   ├── TrainingSession.swift — SwiftData: completed session record
│   └── UserProgress.swift    — SwiftData: per-level session count
├── Managers/
│   ├── ExerciseStore.swift       — Static data: exercises + skillProgressions per Level
│   ├── ProgressManager.swift     — Unlock logic (5 sessions), completeSession, currentLevel
│   └── CustomizationManager.swift — effectiveReps/effectiveDuration/effectiveDisplayText
├── Views/
│   ├── MainTabView.swift         — AppRoute enum, NavigationState ObservableObject, 3-tab custom tab bar
│   ├── SpriteAnimationView.swift — SpriteConfig + GeometryReader frame animator (async Task loop)
│   ├── Home/HomeView.swift       — Progress ring, current level card, start training button
│   ├── Levels/
│   │   ├── AllLevelsView.swift        — Level list with lock status
│   │   ├── LevelDetailView.swift      — Exercises + Skills sections, difficulty picker (Foundation only)
│   │   ├── ExerciseDetailView.swift   — Full-bleed image, +/- reps/duration customization
│   │   ├── SkillProgressionView.swift — 4-stage tab pills, SpriteAnimationView per stage (info only)
│   │   ├── TrainingView.swift         — countdown → exercise(set loop) → rest → navigationDestination to SkillTrainingView
│   │   ├── SkillTrainingView.swift    — stage tabs, global 3-session counter, rest timer, condition tips
│   │   └── SkillCompleteView.swift    — completion screen pushed after all 3 skill sets; "Done" → popToRoot
│   └── Settings/SettingsView.swift   — Reset progress, app info
└── Assets.xcassets/
    ├── sprite-frog-toe-tap.imageset        — 7 frames, 3 cols
    ├── sprite-frog-lean-and-raise.imageset — 8 frames, 4 cols
    ├── sprite-frog-raise.imageset          — orphaned/unused (can delete)
    └── sprite-pseudo-planche-pushup.imageset
```

## Skills & Levels

Each **Skill** (e.g. Planche, Handstand, Front Lever) has its own level progression. The current planche skill has 7 levels:

| rawValue | displayName | color |
|---|---|---|
| `foundation` | Base | `#067D41` green |
| `foundation2` | Frog Stand | `#067D41` green |
| `leanPlanche` | Lean Planche | `#0B67EC` blue |
| `tuckPlanche` | Tuck Planche | `#6E47EF` purple |
| `advTuckPlanche` | ADV Tuck Planche | `#E67E22` orange |
| `straddlePlanche` | Straddle Planche | `#A21832` red |
| `fullPlanche` | Full Planche | `#0D0D0D` black |

`foundation` and `foundation2` always unlocked. Others unlock after 5 sessions on `previousLevel`.

**Future direction**: `ExerciseStore` and `Level` will be refactored to support multiple skills. Each skill will have its own level set, exercise list, and skill progressions. The home screen will let the user pick which skill to train.

## Key Architecture

- **Navigation**: `AppRoute` enum (`.levelDetail`, `.training`) pushed onto `NavigationPath` in `MainTabView`. Tab bar auto-hides when path is non-empty.
- **Exercises**: `ExerciseStore.shared` — static, non-persisted. `foundation2` has custom exercises; all others use 10 shared templates. Each exercise has `sets: Int = 3` (default).
- **Training flow**: `TrainingPhase` — `.countdown` (5s) → `.exercise` → `.resting` (45s). `currentSet` + `isLastSet` drive the set loop. After last exercise: completion alert (no skills) or `.navigationDestination` to `SkillTrainingView` (has skills).
- **Last-exercise button**: always blue. Label = `"Finish"` when no skill follows (`skillProgressions.isEmpty`); `"Take the Rest"` otherwise.
- **Skill training flow**: `SkillTrainingPhase` — `.exercise` → `.resting` (45s). Global counter `totalSessions = 3` (any mix of stages). After 3 completions → `SkillCompleteView` pushed via `.navigationDestination`. "Done" → `navigationState.popToRoot = true`.
- **Navigation reset**: `NavigationState` (`ObservableObject`, `@Published var popToRoot: Bool`) via `@EnvironmentObject`. `MainTabView` resets both `homePath` and `processPath` to `NavigationPath()` on `popToRoot = true`.
- **Skill data**: Only `.foundation2` has skill progressions (Frog Stand, 4 stages). `ExerciseStage.nextStageCondition` shown as tip in `SkillTrainingView`.
- **Customization**: `ExerciseCustomization` (SwiftData) keyed by `(exerciseName, levelRawValue, difficultyRawValue?)`. `CustomizationManager` instantiated per-view.
- **Difficulty**: Only `foundation` uses `Difficulty` (starter/standard/solid). Others pass `difficulty: nil`.
- **Sprites**: `SpriteConfig(imageName:frameCount:columns:fps:)`. `SpriteAnimationView` uses `UIImage(named:)` for `frameAspectRatio` then `.aspectRatio(contentMode: .fit).frame(maxWidth: .infinity)` on `GeometryReader`. Default fps = 2.
- **Colors**: `Color.trainingBlue = #035CD5`. Tab bar selected tint `#5EABF7`.

## Key Patterns

- `ProgressManager(modelContext:)` / `CustomizationManager(modelContext:)` — instantiated per-view (not singletons)
- SwiftData models: `TrainingSession`, `UserProgress`, `ExerciseCustomization`
- Non-persisted structs: `Exercise`, `ProgressiveExercise`, `ExerciseStage`, `SpriteConfig`
- Tab bar hidden on push: `tabBarVisible = homePath.isEmpty && processPath.isEmpty`
- Font sizes: `.font(.system(size: 13))` not `.font(.caption)` for 13pt
- Subtitle format: `"30s × 3 sets"` or `"10 rep × 3 sets"`
- All training screens: `.navigationBarBackButtonHidden(true)` + `.navigationBarHidden(true)`

## Assets & Image Prompts

Prompts in `/Users/daokiencuong/Desktop/Planche/json prompt/` (outside Xcode project).

**Style:** Flat 2D cel-shaded, dark skin warm brown tone, dark gray shorts, no shirt. Diagonal split background — light gray `#E8E8E8` top / medium blue `#1565C0` bottom. Generated via Stable Diffusion img2img (denoising 0.85) + ControlNet openpose.

## App Direction

The app is expanding from planche-only to a **multi-skill calisthenics trainer**:
- User selects a skill goal (Planche, Handstand, Front Lever, etc.) on first launch or from settings
- Each skill has its own independent level progression, exercises, and skill stages
- The existing planche program is the first/reference skill — architecture should be generalized to support others
- `Level`, `ExerciseStore`, and progression logic will eventually be scoped per-skill

## Notes
<!-- Preserve any existing content from this section exactly as-is -->
<!-- This section is for manual notes that won't be overwritten -->
