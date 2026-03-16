# Planche Fitness

> SwiftUI iOS app for progressive calisthenics skill training. Architecture: **SkillGroup > Skill** hierarchy supporting multiple skill groups (Planche, Handstand, Front Lever, etc.). Users pick an active program (skill), track hold-time progress, and follow structured workouts.

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
├── plancheApp.swift          — @main, ModelContainer, VersionedSchema + SchemaMigrationPlan (V1→V2)
├── ContentView.swift         — wraps MainTabView
├── AppDelegate.swift         — UIApplicationDelegate adapter
├── Extensions/
│   └── Color+Extensions.swift — Color(hex:), Color.trainingBlue, Color.secondary
├── Models/
│   ├── SkillGroup.swift      — SkillGroup struct (id, displayName, iconName, skillIDs)
│   ├── Skill.swift           — Skill struct (replaces Level enum): id, groupID, displayName, etc.
│   ├── ActiveProgram.swift   — SwiftData: active program (skillID, groupID, currentProgressSeconds, isCompleted)
│   ├── Exercise.swift        — Exercise struct: name, skillID, reps, sets, category, videoName
│   ├── ProgressiveExercise.swift — ExerciseStage (SpriteConfig optional)
│   ├── ExerciseCustomization.swift — SwiftData: custom reps/duration per exercise (keyed by skillID)
│   ├── TrainingSession.swift — SwiftData: completed session (skillID, groupID, date, completed, duration)
│   ├── UserProgress.swift    — SwiftData: currentSkillID
│   ├── UserProfile.swift     — SwiftData: user profile data
│   └── Level.swift           — Legacy Level enum (kept for reference)
├── Managers/
│   ├── SkillCatalog.swift        — Static catalog: skill/exercise lookup, group iteration, nextSkill()
│   ├── SkillData/
│   │   └── PlancheSkillData.swift — All planche skills + exercises (extracted from old ExerciseStore)
│   ├── ProgressManager.swift     — Active program CRUD, progress %, calendar dates, soft recommendations
│   ├── CustomizationManager.swift — effectiveReps/effectiveDuration/effectiveDisplayText
│   ├── StoreManager.swift        — In-app subscription management
│   ├── AdManager.swift           — Interstitial ad loading & display for free users
│   ├── AuthManager.swift         — Authentication state
│   └── ExerciseStore.swift       — Legacy static data (superseded by SkillCatalog)
├── Views/
│   ├── MainTabView.swift         — AppRoute enum (.skillDetail, .training), NavigationState, 3-tab tab bar
│   ├── SpriteAnimationView.swift — SpriteConfig + GeometryReader frame animator (async Task loop)
│   ├── VideoLoopView.swift       — Looping AVPlayer video view
│   ├── Home/
│   │   ├── HomeView.swift        — Greeting, WeekStripView, ActiveProgramCard or NoProgramCard, RecommendSection
│   │   └── UpdateProgressModal.swift — Hold-time picker + requirements checklist + Save
│   ├── Levels/
│   │   ├── AllLevelsView.swift        — Skill list from SkillCatalog, premium/recommendation gating
│   │   ├── LevelDetailView.swift      — Exercises list, difficulty picker, Start Training
│   │   ├── SkillPreviewOverlay.swift  — Soft recommendation overlay (Keep Select / Try previous first)
│   │   ├── ExerciseDetailView.swift   — Full-bleed image, +/- reps/duration customization
│   │   ├── TrainingView.swift         — countdown → exercise (set loop) → rest → TrainingCompleteView
│   │   └── TrainingCompleteView.swift — Completion screen; "Done" → navigationState.popToRoot = true
│   ├── Onboarding/OnboardingView.swift — First-launch onboarding flow
│   ├── Paywall/PaywallView.swift     — Subscription paywall
│   ├── Auth/SignInView.swift         — Sign-in screen
│   ├── Ads/
│   │   ├── BannerAdView.swift        — Banner ad component
│   │   └── InterstitialAdPresenter.swift — Full-screen ad presenter
│   ├── Calendar/CalendarView.swift   — Training calendar view
│   └── Settings/
│       ├── SettingsView.swift        — Calendar, stats, app info
│       └── NotificationSettingsView.swift — Notification preferences
└── Assets.xcassets/
```

## Model Hierarchy: SkillGroup > Skill

**SkillGroup** — groups related skills (e.g. "Planche" contains 6 skills)
**Skill** — individual progression level (replaces old `Level` enum). Skill IDs match old Level rawValues for data continuity.

| Skill ID | displayName | group | progressGoalSeconds |
|---|---|---|---|
| `foundation` | Base | planche | 45s |
| `foundation2` | Frog Stand | planche | 15s |
| `tuckPlanche` | Tuck Planche | planche | 10s |
| `advTuckPlanche` | ADV Tuck Planche | planche | 10s |
| `straddlePlanche` | Straddle Planche | planche | 5s |
| `fullPlanche` | Full Planche | planche | 3s |

## Unlock Logic

- **All skills are freely accessible** — no hard locks based on previous completion
- **Soft recommendations**: `Skill.recommendedPreviousSkillID` provides a hint. `SkillPreviewOverlay` shows "Keep Select" + "Try X first" when previous skill progress is incomplete
- **Subscription gating**: `Skill.requiresSubscription` (straddlePlanche, fullPlanche) requires active subscription

## Exercise Categorization

```swift
enum ExerciseCategory: String, Codable {
    case supplementary  // general exercises — visible in future exercise library
    case specialized    // skill-specific — internal only
}
```
Currently all exercises default to `.supplementary`. Category is backend-only; training views show all exercises for a skill.

## Key Architecture

- **Navigation**: `AppRoute` enum (`.skillDetail(Skill)`, `.training(Skill, difficulty:)`) pushed onto `NavigationPath`. Tab bar hides when any path is non-empty.
- **Tabs (3)**: Home (tag 0) · Process/AllLevels (tag 1) · Settings (tag 2)
- **SkillCatalog**: `SkillCatalog.shared` — singleton providing `skill(for:)`, `exercises(for:)`, `skills(in:)`, `nextSkill(after:)`, `allSkills()`. Data lives in `SkillData/` extension files.
- **Active Program**: Single `ActiveProgram` SwiftData record. `ProgressManager.setActiveProgram(skill:)` replaces it. Progress = hold seconds / `skill.progressGoalSeconds` × 100. At 100% → `isCompleted = true` → home shows `RecommendSection` with next skill.
- **Training flow**: `TrainingPhase` — `.countdown` (5s) → `.exercise` → `.resting` (45s). Set loop driven by `currentSet` + `isLastSet`. After last exercise → `TrainingCompleteView`.
- **Navigation reset**: `NavigationState` (`ObservableObject`, `@Published var popToRoot: Bool`) via `@EnvironmentObject`. `MainTabView` resets `homePath`, `processPath` on `popToRoot = true`.
- **Customization**: `ExerciseCustomization` (SwiftData) keyed by `(exerciseName, skillID, difficultyRawValue?)`. `CustomizationManager` instantiated per-view.
- **Difficulty**: Only `foundation` skill uses `Difficulty` (starter/standard/solid). Others pass `difficulty: nil`.
- **Sprites**: `SpriteConfig(imageName:frameCount:columns:fps:)`. Default fps = 2.
- **Ads**: Free users see `BannerAdView` during rest and interstitial ads on session complete/quit. `AdManager` preloads interstitials on training start.
- **Subscriptions**: `StoreManager` manages in-app purchase state. `isSubscribed` gates premium skills and ad removal.
- **Colors**: `Color.trainingBlue = #035CD5`. Tab bar selected tint `#5EABF7`. `Color.secondary = #CCCCCC` (defined in `Extensions/Color+Extensions.swift` — use `Color.secondary` for all body/label/description text; never hardcode `Color(hex: "CCCCCC")` inline).
- **Theme-adaptive colors (MANDATORY)**: The app supports light and dark themes. **Never hardcode hex colors from Figma for UI chrome.** Always map to system-adaptive equivalents:

  | Figma hex (dark theme) | Use instead |
  |---|---|
  | `#191919`, `#1C1C1E`, dark backgrounds | `Color(.secondarySystemBackground)` |
  | `#2C2C2E`, `#2C2C2C`, inner card backgrounds | `Color(.tertiarySystemBackground)` |
  | `#F2F2F7`, light button backgrounds | `Color(.tertiarySystemBackground)` |
  | `white.opacity(0.1)`, `white.opacity(0.15)` overlays | `Color(.tertiarySystemBackground)` |
  | `white.opacity(0.2)`, thin dividers | `Color(.separator)` |
  | `#8E8E93`, `#666666`, secondary text | `Color(.secondaryLabel)` |
  | `#FFFFFF` / `.white` for text on dark bg | `.primary` (unless on a colored button — keep `.white`) |
  | `#0061EB`, brand blue | `Color.blue` (system adaptive) |
  | `#34C759`, success green | `Color.green` (system adaptive) |
  | `#FF3B30`, error red | `Color.red` (system adaptive) |
  | Border strokes from Figma | `Color(.separator)` |
  | `#3A3A3C`, `#48484A`, gray tracks | `Color(.systemGray5)` |

  Exception: `Color.trainingBlue` (#035CD5) is an intentional brand color — keep as-is.
- **SwiftData Migration**: `PlancheSchemaV1` → `PlancheSchemaV2` via `PlancheMigrationPlan`. V1 used `levelRawValue`/`currentLevelRawValue`, V2 uses `skillID`/`currentSkillID` + `groupID`. Migration clears old data; fallback deletes store on failure.

## Key Patterns

- `ProgressManager(modelContext:)` / `CustomizationManager(modelContext:)` — instantiated per-view (not singletons)
- `SkillCatalog.shared` — static singleton for skill/exercise data lookup
- SwiftData models: `TrainingSession`, `UserProgress`, `ExerciseCustomization`, `ActiveProgram`, `UserProfile`
- Non-persisted structs: `Skill`, `SkillGroup`, `Exercise`, `ExerciseStage`, `SpriteConfig`
- Font sizes: `.font(.system(size: 13))` not `.font(.caption)` for 13pt
- Subtitle format: `"30s × 3 sets"` or `"10 rep × 3 sets"`
- All training screens: `.navigationBarBackButtonHidden(true)` + `.navigationBarHidden(true)`
- `resetProgress()` clears all 4 SwiftData models including `ActiveProgram`

## Adding a New Skill Group

1. Create `Managers/SkillData/<SkillName>SkillData.swift`
2. Add `extension SkillCatalog` with `static let <name>Group`, `<name>Skills`, `<name>Exercises`
3. Register in `SkillCatalog.init()`: add group to `allGroups`, skills to `sMap`, exercises to `exerciseMap`
4. Done — views automatically iterate `SkillCatalog.shared.groups`

## Assets & Image Prompts

Prompts in `/Users/daokiencuong/Desktop/Planche/json prompt/` (outside Xcode project).

**Style:** Flat 2D cel-shaded, dark skin warm brown tone, dark gray shorts, no shirt. Diagonal split background — light gray `#E8E8E8` top / medium blue `#1565C0` bottom. Generated via Stable Diffusion img2img (denoising 0.85) + ControlNet openpose.

## App Direction

The app has been refactored from planche-only to a **multi-skill calisthenics platform**:
- Architecture supports multiple skill groups (Planche, Handstand, Front Lever, Dragon Flag, etc.)
- Each skill group contains ordered skills with independent progressions, exercises, and stages
- Planche is the first/reference skill group — fully implemented
- Adding new skill groups requires only creating a single data file + registering in `SkillCatalog.init()`
- All skills are freely accessible (no hard locks) with soft previous-skill recommendations

## Notes
<!-- Preserve any existing content from this section exactly as-is -->
<!-- This section is for manual notes that won't be overwritten -->
