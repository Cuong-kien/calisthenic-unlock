import UIKit

/// Helper to retrieve the root UIViewController for presenting interstitial ads from SwiftUI.
enum InterstitialAdPresenter {
    static func rootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return nil }
        return window.rootViewController
    }
}
