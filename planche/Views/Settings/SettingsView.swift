import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                Section("Progress") {
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Label("Reset All Progress", systemImage: "arrow.counterclockwise")
                    }
                }

                Section("About") {
                    HStack {
                        Text("App")
                        Spacer()
                        Text("Planche Fitness")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Levels")
                        Spacer()
                        Text("\(Level.allCases.count)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Exercises per Level")
                        Spacer()
                        Text("10")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Progress", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetProgress()
                }
            } message: {
                Text("This will delete all training sessions and reset your progress. This cannot be undone.")
            }
        }
    }

    private func resetProgress() {
        let manager = ProgressManager(modelContext: modelContext)
        manager.resetProgress()
    }
}
