import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: exercise.imageName)
                    .font(.system(size: 80))
                    .foregroundStyle(exercise.level.color)
                    .padding(.top, 40)

                Text(exercise.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(exercise.level.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(exercise.level.color)
                    .clipShape(Capsule())

                Text(exercise.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()
            }
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
