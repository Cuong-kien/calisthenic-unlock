import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            TrainingSession.self,
            UserProgress.self,
            ExerciseCustomization.self
        ], inMemory: true)
}
