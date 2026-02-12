import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var navigateToTraining = false

    private var progressManager: ProgressManager {
        ProgressManager(modelContext: modelContext)
    }

    private var currentLevel: Level {
        progressManager.currentLevel()
    }

    private var sessionsCompleted: Int {
        progressManager.completedSessionCount(for: currentLevel)
    }

    private var progress: Double {
        Double(sessionsCompleted) / Double(Level.sessionsToUnlock)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                // Level badge
                VStack(spacing: 12) {
                    Image(systemName: currentLevel.iconName)
                        .font(.system(size: 50))
                        .foregroundStyle(currentLevel.color)

                    Text(currentLevel.displayName)
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Current Level")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Progress ring
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                        .frame(width: 150, height: 150)

                    Circle()
                        .trim(from: 0, to: min(progress, 1.0))
                        .stroke(currentLevel.color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: progress)

                    VStack(spacing: 4) {
                        Text("\(sessionsCompleted)/\(Level.sessionsToUnlock)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Sessions")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Start training button
                NavigationLink {
                    TrainingView(level: currentLevel)
                } label: {
                    Label("Start Training", systemImage: "play.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(currentLevel.color)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 40)

                if sessionsCompleted >= Level.sessionsToUnlock {
                    Text("Level complete! Move to \(currentLevel.displayName) exercises or advance.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .navigationTitle("Planche Fitness")
        }
    }
}
