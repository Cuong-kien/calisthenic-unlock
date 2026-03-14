import SwiftUI
import SwiftData

struct AllLevelsView: View {
    @Environment(\.modelContext) private var modelContext
    private var progressManager: ProgressManager {
        ProgressManager(modelContext: modelContext)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("Process")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 4)

                VStack(spacing: 16) {
                    ForEach(Level.allCases) { level in
                        let isUnlocked = progressManager.isLevelUnlocked(level)
                        let sessions = progressManager.completedSessionCount(for: level)

                        NavigationLink(value: AppRoute.levelDetail(level, isUnlocked: isUnlocked)) {
                            LevelRow(level: level, sessions: sessions, isUnlocked: isUnlocked)
                        }
                        .buttonStyle(.plain)
                        .background(Color(white: 0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 100)
        }
        .background(Color.black)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct LevelRow: View {
    let level: Level
    let sessions: Int
    let isUnlocked: Bool

    private var isCompleted: Bool { sessions >= Level.sessionsToUnlock }

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            LevelIcon(level: level, isUnlocked: isUnlocked)

            // Text
            VStack(alignment: .leading, spacing: 3) {
                Text(level.categoryLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.5))
                    .tracking(0.5)

                Text(level.displayName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Spacer()

            // Right indicator
            if !isUnlocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.white.opacity(0.4))
            } else {
                Text("\(sessions)/\(Level.sessionsToUnlock)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

private struct LevelIcon: View {
    let level: Level
    let isUnlocked: Bool

    var body: some View {
        let imageName = level.levelIconImageName(active: isUnlocked)

        Group {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
            } else {
                // Fallback for levels without custom icons
                ZStack {
                    Image(systemName: "hexagon.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(isUnlocked ? Color.trainingBlue : Color(white: 0.25))
                        .frame(width: 72, height: 72)

                    Image(systemName: isUnlocked ? level.iconName : level.iconName)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}
