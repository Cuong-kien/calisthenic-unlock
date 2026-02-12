import SwiftUI
import SwiftData

struct AllLevelsView: View {
    @Environment(\.modelContext) private var modelContext

    private var progressManager: ProgressManager {
        ProgressManager(modelContext: modelContext)
    }

    var body: some View {
        NavigationStack {
            List(Level.allCases) { level in
                let isUnlocked = progressManager.isLevelUnlocked(level)
                let sessions = progressManager.completedSessionCount(for: level)

                if isUnlocked {
                    NavigationLink {
                        LevelDetailView(level: level)
                    } label: {
                        LevelRow(level: level, sessions: sessions, isUnlocked: true)
                    }
                } else {
                    LevelRow(level: level, sessions: sessions, isUnlocked: false)
                        .opacity(0.5)
                }
            }
            .navigationTitle("All Levels")
        }
    }
}

private struct LevelRow: View {
    let level: Level
    let sessions: Int
    let isUnlocked: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: level.iconName)
                .font(.title2)
                .foregroundStyle(level.color)
                .frame(width: 44, height: 44)
                .background(level.color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(level.displayName)
                    .font(.headline)
                Text("\(sessions)/\(Level.sessionsToUnlock) sessions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if !isUnlocked {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
            } else if sessions >= Level.sessionsToUnlock {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }
}
