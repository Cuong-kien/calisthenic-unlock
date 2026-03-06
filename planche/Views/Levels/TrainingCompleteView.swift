import SwiftUI

struct TrainingCompleteView: View {
    let level: Level
    @EnvironmentObject private var navigationState: NavigationState

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.blue)

            Text("Training Complete!")
                .font(.title).fontWeight(.bold)
                .padding(.top, 24)

            Text("Great job! You've completed a \(level.displayName) training session.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 12)

            Spacer()

            Button {
                navigationState.popToRoot = true
            } label: {
                Text("Done")
                    .font(.headline).foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}
