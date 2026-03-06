import SwiftUI
import SwiftData
import Combine

// MARK: - Navigation State

final class NavigationState: ObservableObject {
    @Published var popToRoot = false
}

// MARK: - App Route

enum AppRoute: Hashable {
    case levelDetail(Level, isUnlocked: Bool)
    case training(Level, difficulty: Difficulty?)
}

// MARK: - Main Tab View

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var navigationState = NavigationState()
    @State private var selectedTab: Int = 0
    @State private var homePath = NavigationPath()
    @State private var processPath = NavigationPath()

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homePath) {
                HomeView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationView(for: route)
                    }
            }
            .toolbar(homePath.isEmpty ? .visible : .hidden, for: .tabBar)
            .tabItem { Label("Home", systemImage: "house") }
            .tag(0)

            NavigationStack(path: $processPath) {
                AllLevelsView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationView(for: route)
                    }
            }
            .toolbar(processPath.isEmpty ? .visible : .hidden, for: .tabBar)
            .tabItem { Label("Process", systemImage: "chart.bar") }
            .tag(1)

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gearshape") }
            .tag(2)
        }
        .tint(Color(hex: "#5EABF7"))
        .environmentObject(navigationState)
        .onChange(of: navigationState.popToRoot) { _, value in
            guard value else { return }
            homePath = NavigationPath()
            processPath = NavigationPath()
            navigationState.popToRoot = false
        }
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .levelDetail(let level, let isUnlocked):
            LevelDetailView(level: level, isUnlocked: isUnlocked)
        case .training(let level, let difficulty):
            TrainingView(level: level, difficulty: difficulty)
        }
    }
}
