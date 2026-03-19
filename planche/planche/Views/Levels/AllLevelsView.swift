import SwiftUI
import SwiftData

struct AllLevelsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var storeManager: StoreManager
    @EnvironmentObject private var navigationState: NavigationState
    @Query private var activePrograms: [ActiveProgram]
    @State private var showPaywall = false
    @State private var previewSkill: Skill? = nil

    private var progressManager: ProgressManager {
        ProgressManager(modelContext: modelContext)
    }

    private var activeSkillID: String? {
        // Prefer the non-completed program (the one the user is currently working on)
        (activePrograms.first(where: { !$0.isCompleted }) ?? activePrograms.last)?.skillID
    }

    private var completedSkillIDs: Set<String> {
        Set(activePrograms.filter { $0.isCompleted }.map { $0.skillID })
    }

    /// Skills sorted with the active (starred) skill pinned to the top
    private var sortedSkills: [Skill] {
        let all = SkillCatalog.shared.allSkills()
        guard let activeID = activeSkillID else { return all }
        var sorted = all.filter { $0.id != activeID }
        if let active = all.first(where: { $0.id == activeID }) {
            sorted.insert(active, at: 0)
        }
        return sorted
    }

    private var hasIncompleteActiveProgram: Bool {
        activePrograms.contains(where: { !$0.isCompleted })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("Skill")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 4)

                VStack(spacing: 16) {
                    ForEach(sortedSkills) { skill in
                        let isPremiumLocked = skill.requiresSubscription && !storeManager.isSubscribed
                        let isActive = skill.id == activeSkillID

                        let isCompleted = completedSkillIDs.contains(skill.id)

                        if isPremiumLocked {
                            Button {
                                previewSkill = skill
                            } label: {
                                SkillRow(skill: skill, isPremiumLocked: true, isActive: false, isCompleted: false)
                            }
                            .buttonStyle(.plain)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            Button {
                                handleSkillTap(skill: skill)
                            } label: {
                                SkillRow(skill: skill, isPremiumLocked: false, isActive: isActive, isCompleted: isCompleted)
                            }
                            .buttonStyle(.plain)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 100)
        }
        .background(Color(.systemBackground))
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(storeManager)
        }
        .fullScreenCover(item: $previewSkill) { skill in
            SkillPreviewOverlay(
                skill: skill,
                onSelect: { selectedSkill in
                    previewSkill = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if selectedSkill.requiresSubscription && !storeManager.isSubscribed {
                            showPaywall = true
                        } else {
                            navigationState.processRoute = .skillDetail(selectedSkill)
                        }
                    }
                },
                onTryPrevious: { prevSkill in
                    previewSkill = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        previewSkill = prevSkill
                    }
                },
                onDismiss: {
                    previewSkill = nil
                }
            )
        }
    }

    private func handleSkillTap(skill: Skill) {
        if hasIncompleteActiveProgram && skill.id == activeSkillID {
            navigationState.processRoute = .skillDetail(skill)
        } else {
            previewSkill = skill
        }
    }
}

private struct SkillRow: View {
    let skill: Skill
    let isPremiumLocked: Bool
    let isActive: Bool
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 16) {
            SkillIcon(skill: skill, isActive: !isPremiumLocked)

            VStack(alignment: .leading, spacing: 3) {
                Text(skill.categoryLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .tracking(0.5)

                Text(skill.displayName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(isPremiumLocked ? .secondary : .primary)
            }

            Spacer()

            if isPremiumLocked {
                Image(systemName: "crown.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.yellow)
            } else if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.blue)
            } else if isActive {
                Image(systemName: "star.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.yellow)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

private struct SkillIcon: View {
    let skill: Skill
    let isActive: Bool

    private static let skillPreviewImages: [String: String] = [
        "foundation2": "frog-stand",
        "tuckPlanche": "tuck-parallettes",
        "advTuckPlanche": "preview-adv-tuck-planche",
        "straddlePlanche": "straddle-planche-hold",
        "fullPlanche": "full-planche"
    ]

    var body: some View {
        Group {
            if let previewImage = Self.skillPreviewImages[skill.id] {
                Image(previewImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .grayscale(isActive ? 0 : 1)
                    .opacity(isActive ? 1 : 0.6)
            } else {
                ZStack {
                    Image(systemName: "hexagon.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(isActive ? Color.trainingBlue : Color(.systemGray4))
                        .frame(width: 72, height: 72)

                    Image(systemName: skill.iconName)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}
