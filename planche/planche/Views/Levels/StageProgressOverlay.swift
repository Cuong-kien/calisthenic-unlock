import SwiftUI
import SwiftData

struct StageProgressOverlay: View {
    let exerciseName: String
    let skillID: String
    let stageIndex: Int
    let stageName: String
    let isTimedStage: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allStageProgress: [StageProgress]
    @State private var currentValue: Int = 0
    @State private var didLoad = false

    private var existingRecord: StageProgress? {
        allStageProgress.first { p in
            p.exerciseName == exerciseName
            && p.skillID == skillID
            && p.stageIndex == stageIndex
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Close button row
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(.secondaryLabel))
                        .frame(width: 36, height: 36)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            Spacer()

            // Stage name
            Text(stageName)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.primary)

            Spacer()

            // Stepper
            HStack(spacing: 20) {
                Button {
                    if currentValue > 0 { currentValue -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 30, height: 30)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(Circle())
                }

                Text("\(currentValue)")
                    .font(.headline).fontWeight(.bold)
                    .monospacedDigit()
                    .frame(minWidth: 40)

                Button {
                    currentValue += 1
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 30, height: 30)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(Circle())
                }
            }

            Spacer()

            // Save button
            Button {
                saveProgress()
                dismiss()
            } label: {
                Text("Save")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
        .onAppear {
            if !didLoad {
                currentValue = existingRecord?.currentValue ?? 0
                didLoad = true
            }
        }
    }

    private func saveProgress() {
        if let existing = existingRecord {
            existing.currentValue = currentValue
            existing.updatedAt = Date()
        } else {
            let newRecord = StageProgress(
                exerciseName: exerciseName,
                skillID: skillID,
                stageIndex: stageIndex,
                currentValue: currentValue
            )
            modelContext.insert(newRecord)
        }
    }
}
