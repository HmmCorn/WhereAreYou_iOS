//
//  AppleSignInProvider.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-06.
//

import Foundation
import AuthenticationServices
import CryptoKit

/// SignInService의 Apple Sign In 구현체 — nonce 관리 및 Apple 인증 흐름 처리
final class AppleSignInProvider: NSObject, SignInService {

    private let windowProvider: () -> ASPresentationAnchor?
    private var currentNonce: String?
    private var continuation: CheckedContinuation<SignInCredential, Error>?
    private var authController: ASAuthorizationController?

    init(windowProvider: @escaping () -> ASPresentationAnchor?) {
        self.windowProvider = windowProvider
    }

    // MARK: - SignInService

    func signIn() async throws -> SignInCredential {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let nonce = Self.randomNonceString()
            self.currentNonce = nonce

            DispatchQueue.main.async { [self] in
                let request = ASAuthorizationAppleIDProvider().createRequest()
                request.requestedScopes = [.fullName]
                request.nonce = Self.sha256(nonce)

                let controller = ASAuthorizationController(authorizationRequests: [request])
                controller.delegate = self
                controller.presentationContextProvider = self
                self.authController = controller
                controller.performRequests()
            }
        }
    }

}

// MARK: - ASAuthorizationControllerDelegate

extension AppleSignInProvider: ASAuthorizationControllerDelegate {

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let idTokenData = appleCredential.identityToken,
              let idToken = String(data: idTokenData, encoding: .utf8),
              let nonce = currentNonce else {
            consumeContinuation { $0.resume(throwing: AppError.notAuthenticated) }
            return
        }

        let nickname = [appleCredential.fullName?.familyName, appleCredential.fullName?.givenName]
            .compactMap { $0 }
            .joined()

        let credential = SignInCredential(
            idToken: idToken,
            nonce: nonce,
            nickname: nickname.isEmpty ? nil : nickname
        )
        consumeContinuation { $0.resume(returning: credential) }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        let code = (error as NSError).code
        if code == ASAuthorizationError.canceled.rawValue {
            consumeContinuation { $0.resume(throwing: SignInError.cancelled) }
        } else {
            consumeContinuation { $0.resume(throwing: AppError.unknown(error)) }
        }
    }

    /// continuation을 nil로 교체한 뒤 resume — 비정상적 이중 콜백 시 중복 resume 방지
    private func consumeContinuation(
        _ body: (CheckedContinuation<SignInCredential, Error>) -> Void
    ) {
        guard let captured = continuation else { return }
        continuation = nil
        authController = nil
        body(captured)
    }

}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleSignInProvider: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = windowProvider() else {
            preconditionFailure("로그인 시점에 window가 존재해야 합니다")
        }
        return window
    }

}

// MARK: - Nonce 생성

private extension AppleSignInProvider {

    static func randomNonceString(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let maxValue = (256 / charset.count) * charset.count

        var result = [Character]()
        result.reserveCapacity(length)

        while result.count < length {
            var randomBytes = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
            precondition(status == errSecSuccess)

            for byte in randomBytes where result.count < length {
                if Int(byte) < maxValue {
                    result.append(charset[Int(byte) % charset.count])
                }
            }
        }

        return String(result)
    }

    static func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

}
