import SwiftUI
import SwiftData

struct SkillPreviewOverlay: View {
    let skill: Skill
    let onSelect: (Skill) -> Void
    let onDismiss: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var showSwitchAlert = false

    private var progressManager: ProgressManager {
        ProgressManager(modelContext: modelContext)
    }

    private var previousNotRecommended: Bool {
        !progressManager.isSkillRecommended(skill.id)
    }

    /// Whether there's already an active program for a DIFFERENT skill
    private var hasActiveOtherProgram: Bool {
        guard let current = progressManager.activeProgram() else { return false }
        return current.skillID != skill.id && !current.isCompleted
    }

    private var currentActiveSkillName: String {
        progressManager.activeProgram()?.skill?.displayName ?? ""
    }

    private func selectSkill(_ selectedSkill: Skill) {
        if hasActiveOtherProgram && selectedSkill.id == skill.id {
            showSwitchAlert = true
        } else {
            ProgressManager(modelContext: modelContext).setActiveProgram(skill: selectedSkill)
            onSelect(selectedSkill)
        }
    }

    private func confirmSwitch() {
        ProgressManager(modelContext: modelContext).setActiveProgram(skill: skill)
        onSelect(skill)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Spacer().frame(height: 56)

                    // Hero image
                    heroImage

                    // Title
                    Text(skill.displayName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)

                    // Description
                    Text(skill.description)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)

                    // Difficulty stars
                    HStack(spacing: 4) {
                        Text("Difficulty:")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                        starsView(for: skill.difficultyStars)
                    }

                    // Requirements
                    if !skill.skillPrerequisites.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Base requirement")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.secondary)

                            ForEach(skill.skillPrerequisites, id: \.self) { req in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "checkmark.circle")
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color.trainingBlue)
                                        .padding(.top, 1)
                                    Text(req)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.secondary)
                                }
                            }
                        }
                    }

                    Spacer().frame(height: 160)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Close button
            Button { onDismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 16)
            .padding(.trailing, 20)

            // Bottom buttons
            VStack(spacing: 12) {
                Spacer()

                if previousNotRecommended {
                    Button {
                        selectSkill(skill)
                    } label: {
                        Text("Keep Select")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    if let prevID = skill.recommendedPreviousSkillID,
                       let prevSkill = SkillCatalog.shared.skill(for: prevID) {
                        Button {
                            onSelect(prevSkill)
                        } label: {
                            Text("Try \(prevSkill.displayName) first")
                                .font(.headline)
                                .foregroundStyle(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(.systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                } else {
                    Button {
                        selectSkill(skill)
                    } label: {
                        Text("Select Skill")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .background(
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemBackground).opacity(0)],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 120)
                .allowsHitTesting(false),
                alignment: .bottom
            )
        }
        .alert("Switch Program?", isPresented: $showSwitchAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Switch", role: .destructive) {
                confirmSwitch()
            }
        } message: {
            Text("You're currently training \(currentActiveSkillName). You can only have one active program at a time. Switch to \(skill.displayName)?")
        }
    }

    // MARK: - Hero Image

    private static let skillPreviewImages: [String: String] = [
        "foundation": "planche-lean",
        "foundation2": "frog-stand",
        "tuckPlanche": "tuck-parallettes",
        "advTuckPlanche": "preview-adv-tuck-planche",
        "straddlePlanche": "straddle-planche-hold",
    ]

    private var heroImage: some View {
        Group {
            if let imageName = Self.skillPreviewImages[skill.id] {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 800)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.trainingBlue.opacity(0.15))
                    .aspectRatio(114.0/86.0, contentMode: .fill)
                    .overlay(
                        Image(systemName: skill.iconName)
                            .font(.system(size: 60))
                            .foregroundStyle(Color.trainingBlue)
                    )
            }
        }
    }

    // MARK: - Stars

    private func starsView(for value: Double) -> some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { i in
                let d = Double(i)
                Image(systemName: value >= d ? "star.fill"
                               : value >= d - 0.5 ? "star.leadinghalf.filled"
                               : "star")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.yellow)
            }
        }
    }
}
