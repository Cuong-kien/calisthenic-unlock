import Foundation
import Combine
import SwiftData
import AuthenticationServices

final class AuthManager: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var signInError: String? = nil

    private let userIDKey = "appleUserID"
    private let displayNameKey = "appleDisplayName"
    private let emailKey = "appleEmail"
    private let guestModeKey = "guestMode"

    var displayName: String {
        UserDefaults.standard.string(forKey: displayNameKey) ?? "Username"
    }

    var email: String? {
        UserDefaults.standard.string(forKey: emailKey)
    }

    /// The Apple user ID stored from Sign in with Apple
    var userID: String? {
        UserDefaults.standard.string(forKey: userIDKey)
    }

    var isAppleSignedIn: Bool {
        isSignedIn && !UserDefaults.standard.bool(forKey: guestModeKey)
    }

    var isGuest: Bool {
        UserDefaults.standard.bool(forKey: guestModeKey)
    }

    var authProvider: String {
        if isAppleSignedIn { return "apple" }
        if isGuest { return "guest" }
        return ""
    }

    // Called on app launch to restore session
    func checkOnLaunch() {
        // Guest mode — no Apple ID required
        if UserDefaults.standard.bool(forKey: guestModeKey) {
            isSignedIn = true
            return
        }
        // Check Apple session
        guard let savedID = UserDefaults.standard.string(forKey: userIDKey) else {
            isSignedIn = false
            return
        }
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: savedID) { [weak self] state, _ in
            DispatchQueue.main.async {
                self?.isSignedIn = (state == .authorized)
            }
        }
    }

    func continueAsGuest() {
        UserDefaults.standard.set(true, forKey: guestModeKey)
        isSignedIn = true
    }

    // Called by SignInView after Apple returns a result
    func handleSignIn(_ result: Result<ASAuthorization, Error>) {
        signInError = nil
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else {
                DispatchQueue.main.async { self.signInError = "Sign-in failed. Try again." }
                return
            }
            UserDefaults.standard.set(credential.user, forKey: userIDKey)
            if let email = credential.email {
                UserDefaults.standard.set(email, forKey: emailKey)
            }
            if let name = credential.fullName {
                let full = [name.givenName, name.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                if !full.isEmpty {
                    UserDefaults.standard.set(full, forKey: displayNameKey)
                }
            }
            // Clear guest mode when signing in with Apple
            UserDefaults.standard.removeObject(forKey: guestModeKey)
            DispatchQueue.main.async { self.isSignedIn = true }
        case .failure(let error):
            // User cancel (ASAuthorizationError.canceled) is not shown as error
            if (error as? ASAuthorizationError)?.code == .canceled {
                return
            }
            DispatchQueue.main.async {
                self.signInError = "Sign-in failed. Try again."
            }
        }
    }

    /// Sync auth identity into UserProfile (SwiftData/CloudKit).
    /// Call after sign-in and on each app launch to keep profile in sync.
    func syncToUserProfile(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<UserProfile>()
        let profiles = (try? modelContext.fetch(descriptor)) ?? []
        let profile = profiles.first ?? {
            let p = UserProfile()
            modelContext.insert(p)
            return p
        }()

        // Write auth identity into the profile
        if isAppleSignedIn, let uid = userID {
            profile.authUserID = uid
            profile.authProvider = "apple"
            // Only update name if profile name is empty (user may have edited nickname)
            if profile.name.isEmpty {
                profile.name = displayName
            }
            // Only write email if we have it and profile doesn't yet
            if profile.email.isEmpty, let email = email {
                profile.email = email
            }
        } else if isGuest {
            profile.authProvider = "guest"
        }

        try? modelContext.save()
    }

    func signOut(modelContext: ModelContext) {
        // Clear auth identity from SwiftData profile (privacy)
        let descriptor = FetchDescriptor<UserProfile>()
        if let profile = (try? modelContext.fetch(descriptor))?.first {
            profile.authUserID = ""
            profile.authProvider = ""
            profile.email = ""
            try? modelContext.save()
        }
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: userIDKey)
        UserDefaults.standard.removeObject(forKey: displayNameKey)
        UserDefaults.standard.removeObject(forKey: emailKey)
        UserDefaults.standard.removeObject(forKey: guestModeKey)
        isSignedIn = false
    }
}
