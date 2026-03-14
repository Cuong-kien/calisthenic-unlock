import SwiftUI
import SwiftData

struct TrainingCompleteView: View {
    let skill: Skill
    let trainingDuration: TimeInterval
    @EnvironmentObject private var navigationState: NavigationState
    @Environment(\.modelContext) private var modelContext

    @Query private var activePrograms: [ActiveProgram]
    @State private var showUpdateProgress = false

    // Animation states
    @State private var badgeScale: CGFloat = 0.5
    @State private var badgeOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var cardsOffset: CGFloat = 30
    @State private var cardsOpacity: Double = 0
    @State private var buttonsOpacity: Double = 0
    @State private var sparkleOpacity: Double = 0

    private var currentActiveProgram: ActiveProgram? {
        activePrograms.first { $0.skillID == skill.id }
    }

    private var formattedDuration: String {
        let minutes = Int(trainingDuration) / 60
        let seconds = Int(trainingDuration) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Badge with glow rings + sparkles
            ZStack {
                // Outer glow ring
                Circle()
                    .fill(Color.blue.opacity(0.08))
                    .frame(width: 180, height: 180)

                // Inner glow ring
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 140, height: 140)

                // Checkmark badge
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.blue)

                // Sparkle dots
                sparkleDots
                    .opacity(sparkleOpacity)
            }
            .scaleEffect(badgeScale)
            .opacity(badgeOpacity)

            // Title
            Text("CONGRATULATIONS!")
                .font(.system(size: 20, weight: .heavy))
                .tracking(1)
                .foregroundStyle(.primary)
                .padding(.top, 24)
                .opacity(titleOpacity)

            // Subtitle
            Text("You've completed your training session")
                .font(.system(size: 15))
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 8)
                .opacity(titleOpacity)

            // Stat cards (vertical)
            VStack(spacing: 12) {
                statCard(label: "Skill", value: skill.displayName, icon: "dumbbell.fill")
                statCard(label: "Duration", value: formattedDuration, icon: "clock.fill")
            }
            .padding(.horizontal, 20)
            .padding(.top, 32)
            .offset(y: cardsOffset)
            .opacity(cardsOpacity)

            Spacer()

            // Separator
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 1)
                .padding(.horizontal, 20)
                .opacity(buttonsOpacity)

            // Buttons
            VStack(spacing: 12) {
                // Update process button
                if currentActiveProgram != nil {
                    Button {
                        showUpdateProgress = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil")
                                .font(.body)
                            Text("Update process")
                                .font(.headline)
                        }
                        .foregroundStyle(Color(.secondaryLabel))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }

                // Back to Home button
                Button {
                    navigationState.popToRoot = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "house.fill")
                            .font(.body)
                        Text("Back to Home")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
            .opacity(buttonsOpacity)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            animateEntrance()
        }
        .sheet(isPresented: $showUpdateProgress) {
            if let program = currentActiveProgram {
                NavigationStack {
                    UpdateProgressModal(activeProgram: program)
                }
            }
        }
    }

    // MARK: - Stat Card

    private func statCard(label: String, value: String, icon: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(.secondaryLabel))
                Text(value)
                    .font(.system(size: 20, weight: .semibold))
                    .tracking(-0.45)
                    .foregroundStyle(.primary)
            }
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color(.secondaryLabel))
        }
        .padding(16)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Sparkle Dots

    private var sparkleDots: some View {
        ZStack {
            // Gold sparkles
            Circle().fill(Color(hex: "FFD700")).frame(width: 6, height: 6)
                .offset(x: -70, y: -50)
            Circle().fill(Color(hex: "FFD700")).frame(width: 4, height: 4)
                .offset(x: 60, y: -65)
            Circle().fill(Color(hex: "FFD700")).frame(width: 5, height: 5)
                .offset(x: 75, y: 30)

            // Blue sparkles
            Circle().fill(Color.blue).frame(width: 5, height: 5)
                .offset(x: -60, y: 55)
            Circle().fill(Color.blue).frame(width: 4, height: 4)
                .offset(x: 80, y: -20)

            // Light blue sparkles
            Circle().fill(Color.blue.opacity(0.6)).frame(width: 5, height: 5)
                .offset(x: -80, y: 10)
            Circle().fill(Color.blue.opacity(0.6)).frame(width: 4, height: 4)
                .offset(x: 50, y: 60)
            Circle().fill(Color.blue.opacity(0.6)).frame(width: 6, height: 6)
                .offset(x: -40, y: -70)
        }
    }

    // MARK: - Animations

    private func animateEntrance() {
        // Badge scale + fade in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            badgeScale = 1.0
            badgeOpacity = 1.0
        }

        // Title fade in
        withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
            titleOpacity = 1.0
        }

        // Cards slide up
        withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
            cardsOffset = 0
            cardsOpacity = 1.0
        }

        // Buttons fade in
        withAnimation(.easeOut(duration: 0.4).delay(0.7)) {
            buttonsOpacity = 1.0
        }

        // Sparkles pulse
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(0.4)) {
            sparkleOpacity = 1.0
        }
    }
}
