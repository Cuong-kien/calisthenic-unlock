import SwiftUI
import SwiftData
import Combine

// MARK: - Navigation State

final class NavigationState: ObservableObject {
    @Published var popToRoot = false
    @Published var processRoute: AppRoute? = nil
    @Published var switchToProcessTab = false
}

// MARK: - App Route

enum AppRoute: Hashable {
    case skillDetail(Skill)
    case training(Skill)
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
            .tabItem { Label("Skill", systemImage: "chart.bar") }
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
        .onChange(of: navigationState.processRoute) { _, route in
            guard let route else { return }
            selectedTab = 1
            processPath.append(route)
            navigationState.processRoute = nil
        }
        .onChange(of: navigationState.switchToProcessTab) { _, newValue in
            if newValue {
                selectedTab = 1
                navigationState.switchToProcessTab = false
            }
        }
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .skillDetail(let skill):
            LevelDetailView(skill: skill)
        case .training(let skill):
            TrainingView(skill: skill)
        }
    }
}
