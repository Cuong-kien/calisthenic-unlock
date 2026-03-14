import SwiftUI
import SwiftData

struct UpdateProgressModal: View {
    let activeProgram: ActiveProgram
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var heldSeconds: Double

    init(activeProgram: ActiveProgram) {
        self.activeProgram = activeProgram
        _heldSeconds = State(initialValue: activeProgram.currentProgressSeconds)
    }

    private var progressManager: ProgressManager {
        ProgressManager(modelContext: modelContext)
    }

    private var skill: Skill? { activeProgram.skill }

    private var formattedTime: String {
        let secs = Int(heldSeconds)
        return String(format: "%02d : %02d", secs / 60, secs % 60)
    }

    private var lastUpdatedText: String? {
        guard let date = activeProgram.lastUpdated else { return nil }
        let fmt = DateFormatter()
        fmt.dateFormat = "dd MMM yyyy"
        return "Last updated: \(fmt.string(from: date))"
    }

    private func starsView(for value: Double) -> some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { i in
                let d = Double(i)
                Image(systemName: value >= d ? "star.fill"
                               : value >= d - 0.5 ? "star.leadinghalf.filled"
                               : "star")
                    .font(.system(size: 13))
                    .foregroundStyle(.yellow)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let skill {
                        // Icon + name + stars
                        VStack(spacing: 8) {
                            if let imageName = skill.skillIconImageName(active: true) {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                            } else {
                                Image(systemName: skill.iconName)
                                    .font(.system(size: 50))
                                    .foregroundStyle(.primary)
                                    .frame(width: 80, height: 80)
                            }

                            Text(skill.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)

                            starsView(for: skill.difficultyStars)
                        }

                        Divider()

                        // Goal info
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Goal: \(skill.progressGoalDescription)")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text("How long did you hold it")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)

                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(skill.progressRequirements, id: \.self) { req in
                                    HStack(alignment: .top, spacing: 6) {
                                        Text("•")
                                            .foregroundStyle(Color.secondary)
                                        Text(req)
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color.secondary)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Divider()

                    // Timer picker
                    VStack(spacing: 8) {
                        Text("Hold time")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)

                        HStack(spacing: 24) {
                            Button {
                                if heldSeconds > 0 { heldSeconds -= 1 }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(.secondary)
                            }

                            Text(formattedTime)
                                .font(.system(size: 36, weight: .bold, design: .monospaced))
                                .foregroundStyle(.primary)
                                .frame(minWidth: 120)

                            Button {
                                heldSeconds += 1
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(.blue)
                            }
                        }

                        if let text = lastUpdatedText {
                            Text(text)
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                        }
                    }

                    // Save button
                    Button {
                        progressManager.updateProgress(seconds: heldSeconds)
                        dismiss()
                    } label: {
                        Text("Save Progress")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle("Update Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
