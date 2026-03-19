import Combine
import SwiftUI
import GoogleMobileAds
import UserMessagingPlatform

@MainActor
final class AdManager: ObservableObject {
    // Test ad unit IDs — replace with real IDs before App Store submission
    static let bannerAdUnitID = "ca-app-pub-3940256099942544/2435281174"
    static let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"

    let objectWillChange = Combine.ObservableObjectPublisher()

    private(set) var interstitialReady = false {
        willSet { objectWillChange.send() }
    }

    private var interstitialAd: InterstitialAd?

    // MARK: - Interstitial

    func preloadInterstitial() {
        guard interstitialAd == nil else { return }
        guard ConsentInformation.shared.canRequestAds else { return }
        InterstitialAd.load(
            with: AdManager.interstitialAdUnitID
        ) { [weak self] ad, error in
            let capturedSelf = self
            Task { @MainActor in
                guard let capturedSelf else { return }
                if let error {
                    print("AdManager: interstitial load failed: \(error.localizedDescription)")
                    capturedSelf.interstitialReady = false
                    return
                }
                capturedSelf.interstitialAd = ad
                capturedSelf.interstitialReady = true
            }
        }
    }

    /// Presents a skippable interstitial ad, then calls completion after the ad is dismissed.
    /// If no ad is loaded, calls completion immediately (graceful degradation).
    func showInterstitial(completion: @escaping () -> Void) {
        guard let ad = interstitialAd else {
            completion()
            preloadInterstitial()
            return
        }
        guard let rootVC = rootViewController() else {
            completion()
            return
        }

        let delegate = InterstitialDelegate(completion: completion)
        ad.fullScreenContentDelegate = delegate
        _activeDelegate = delegate

        ad.present(from: rootVC)
        interstitialAd = nil
        interstitialReady = false
        preloadInterstitial()
    }

    private var _activeDelegate: InterstitialDelegate?

    private func rootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return nil }
        return window.rootViewController
    }
}

// MARK: - Interstitial Delegate

private class InterstitialDelegate: NSObject, FullScreenContentDelegate {
    let completion: () -> Void

    init(completion: @escaping () -> Void) {
        self.completion = completion
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in
            completion()
        }
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("AdManager: interstitial failed to present: \(error.localizedDescription)")
        Task { @MainActor in
            completion()
        }
    }
}
