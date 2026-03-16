import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var storeManager: StoreManager
    @Environment(\.modelContext) private var modelContext

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else if authManager.isSignedIn {
                MainTabView()
            } else {
                SignInView()
            }
        }
        .task {
            authManager.checkOnLaunch()
        }
        .onChange(of: authManager.isSignedIn) { _, signedIn in
            if signedIn {
                authManager.syncToUserProfile(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
        .environmentObject(StoreManager())
        .environmentObject(AdManager())
        .modelContainer(for: [
            TrainingSession.self,
            UserProgress.self,
            ExerciseCustomization.self,
            ActiveProgram.self,
            UserProfile.self,
            StageProgress.self
        ], inMemory: true)
}
