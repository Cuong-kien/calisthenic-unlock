import SwiftUI
import GoogleMobileAds
import UserMessagingPlatform

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let params = RequestParameters()

        ConsentInformation.shared.requestConsentInfoUpdate(with: params) { error in
            if let error {
                print("UMP: consent info error: \(error.localizedDescription)")
            }

            ConsentForm.loadAndPresentIfRequired(from: nil) { loadAndPresentError in
                if let loadAndPresentError {
                    print("UMP: form error: \(loadAndPresentError.localizedDescription)")
                }

                if ConsentInformation.shared.canRequestAds {
                    DispatchQueue.main.async {
                        MobileAds.shared.start(completionHandler: nil)
                    }
                }
            }
        }

        // Start ads immediately if consent was already granted in a previous session
        if ConsentInformation.shared.canRequestAds {
            MobileAds.shared.start(completionHandler: nil)
        }

        return true
    }
}
