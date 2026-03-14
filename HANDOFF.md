# Handoff Log

A shared message board between **Frontend (Claude app)** and **Backend (CLI)**.
After finishing your work, append a new entry below. The other side reads this before starting.

---

## How to use

**Frontend finishes** → add entry under `## Frontend → Backend`
**Backend finishes** → add entry under `## Backend → Frontend`

Keep entries short. Include: what changed, what files were touched, anything the other side must know.

---

## Backend → Frontend

### 2026-03-07
- Added `.preferredColorScheme(.dark)` to `ContentView` — all screens now force dark mode
- All `View` files updated: black backgrounds, white text
- `TrainingView`, `ExerciseDetailView`, `TrainingCompleteView`, `HomeView`, `CalendarView` all patched
- **Action needed**: If you add any new View, use `Color.black` as background and `.white` for primary text. Do NOT use `Color(.systemBackground)` or `.primary` — they are unreliable without dark mode enforcement.

---

## Frontend → Backend

### 2026-03-07
- **Redesigned `HomeView.swift`** — matches Figma 499:3389. Full dark card style (`#191919` bg, `rgba(255,255,255,0.1)` border). Key changes:
  - `WeekStripView`: 2-letter day labels (Mo/Tu…), no background container, 16×16 indicators (blue check = trained, gray circle = past, outlined = today, number = future)
  - `ActiveProgramCard`: icon 80×80, stats in two-column grid (Day+start date | time+progress), green `#34C759` progress bar, removed old "Update process"/"Start Training" buttons
  - `RecommendSection`: full-width blue "Unlock Programs" button, icon 80×80
  - `NoProgramCard`: restyled to dark card aesthetic
- **Redesigned `SettingsView.swift`** — matches Figma 499:3546. Entirely replaced the old plain List with:
  - Profile section: 80×80 circular avatar + "Username" text
  - Stats row: 3 equal cards (Skill unlock count, Records count, Durations hours) — computed live from `ProgressManager`
  - "Remove Ads" full-width blue button (IAP placeholder — no-op for now)
  - "Records" inline calendar: Sunday-start (`firstWeekday = 1`), blue check for trained days, `#1C1C1E` card bg, prev/next month nav
  - Settings group list: Notification, Sign out, Report a bug, Add to Home Screen (all no-op placeholders)
  - "Reset All Progress" destructive button kept at bottom
  - All backgrounds: `Color.black` / `Color(hex:"1C1C1E")` — no `.systemBackground` or `.primary`
  - Added private `startOfSettingsMonth` Calendar extension (named to avoid collision with CalendarView's private one)
- **No new SwiftData models added** — SettingsView reads from existing `TrainingSession` + `ActiveProgram` via `ProgressManager`
- **SourceKit false positives** on both files (ProgressManager, Level, Color(hex:) "not in scope") — these resolve on full Xcode build; not real errors
