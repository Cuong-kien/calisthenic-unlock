import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // App identity
            VStack(spacing: 12) {
                Image(systemName: "figure.gymnastics")
                    .font(.system(size: 64))
                    .foregroundStyle(.primary)

                Text("Planche")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.primary)

                Text("Train smarter. Track everything.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(.secondaryLabel))
            }

            Spacer()

            // Sign in buttons
            VStack(spacing: 12) {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    authManager.handleSignIn(result)
                }
                .signInWithAppleButtonStyle(.white)
                .frame(height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Button {
                    authManager.continueAsGuest()
                } label: {
                    Text("Continue without account")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(.secondaryLabel))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }


                if let error = authManager.signInError {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundStyle(.red)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}
