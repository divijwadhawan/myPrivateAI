import Foundation
import GoogleSignIn
import UIKit

/// Read-only Gmail integration. OAuth tokens are managed by Google's SDK.
@MainActor
final class GmailPlugin: AppPlugin {
    let id = "gmail"
    let title = "Gmail"
    let description = "Search your mail and summarize one message locally."

    private let scope = "https://www.googleapis.com/auth/gmail.readonly"

    var isConfigured: Bool {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
            return false
        }
        guard !clientID.isEmpty, !clientID.contains("REPLACE_WITH"),
              let suffix = clientID.range(of: ".apps.googleusercontent.com", options: .backwards),
              suffix.upperBound == clientID.endIndex,
              let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]] else {
            return false
        }
        let reversed = "com.googleusercontent.apps." + String(clientID[..<suffix.lowerBound])
        return urlTypes.contains { type in
            (type["CFBundleURLSchemes"] as? [String])?.contains(reversed) == true
        }
    }

    var isConnected: Bool {
        GIDSignIn.sharedInstance.currentUser?.grantedScopes?.contains(scope) == true
    }

    func connect() async throws {
        guard isConfigured else {
            throw PluginError.configuration("Add your iOS OAuth client ID and reversed URL scheme to QwenChat/Info.plist first.")
        }
        guard let presenter = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })?
            .windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            throw PluginError.configuration("Could not present Google sign-in. Try again while the app is open.")
        }

        if let user = GIDSignIn.sharedInstance.currentUser {
            if user.grantedScopes?.contains(scope) == true { return }
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                user.addScopes([scope], presenting: presenter) { result, error in
                    if let error { continuation.resume(throwing: error) }
                    else if result != nil { continuation.resume() }
                    else { continuation.resume(throwing: PluginError.authentication) }
                }
            }
        } else {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                GIDSignIn.sharedInstance.signIn(
                    withPresenting: presenter, hint: nil, additionalScopes: [scope]
                ) { result, error in
                    if let error { continuation.resume(throwing: error) }
                    else if result != nil { continuation.resume() }
                    else { continuation.resume(throwing: PluginError.authentication) }
                }
            }
        }
    }

    func disconnect() {
        GIDSignIn.sharedInstance.signOut()
    }

    func search(_ query: String) async throws -> [PluginItem] {
        guard isConnected, let user = GIDSignIn.sharedInstance.currentUser else {
            throw PluginError.authentication
        }
        let token = try await refreshedToken(for: user)
        var components = URLComponents(string: "https://gmail.googleapis.com/gmail/v1/users/me/messages")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "maxResults", value: "10"),
        ]
        let list: GmailMessageList = try await request(components.url!, token: token)
        var items: [PluginItem] = []
        for entry in list.messages ?? [] {
            guard let safeID = entry.id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { continue }
            let url = URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/messages/\(safeID)?format=full")!
            let message: GmailMessage = try await request(url, token: token)
            let subject = message.header("Subject") ?? "(No subject)"
            let from = message.header("From") ?? "Unknown sender"
            let date = message.header("Date") ?? ""
            let body = message.payload?.plainText ?? message.snippet ?? "No readable text body"
            items.append(PluginItem(
                id: entry.id,
                title: subject,
                subtitle: from,
                content: "From: \(from)\nDate: \(date)\nSubject: \(subject)\n\n\(String(body.prefix(4_000)))"
            ))
        }
        return items
    }

    private func refreshedToken(for user: GIDGoogleUser) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            user.refreshTokensIfNeeded { refreshed, error in
                if let error { continuation.resume(throwing: error) }
                else if let refreshed { continuation.resume(returning: refreshed.accessToken.tokenString) }
                else { continuation.resume(throwing: PluginError.authentication) }
            }
        }
    }

    private func request<T: Decodable>(_ url: URL, token: String) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 20
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw PluginError.http(0) }
        guard (200...299).contains(response.statusCode) else { throw PluginError.http(response.statusCode) }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

private struct GmailMessageList: Decodable {
    let messages: [Entry]?
    struct Entry: Decodable { let id: String }
}

private struct GmailMessage: Decodable {
    let snippet: String?
    let payload: Part?

    func header(_ name: String) -> String? {
        payload?.headers?.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame })?.value
    }

    struct Part: Decodable {
        let mimeType: String?
        let headers: [Header]?
        let body: Body?
        let parts: [Part]?

        var plainText: String? {
            if mimeType == "text/plain", let encoded = body?.data {
                let base64 = encoded.replacingOccurrences(of: "-", with: "+")
                    .replacingOccurrences(of: "_", with: "/")
                let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
                if let data = Data(base64Encoded: padded), let text = String(data: data, encoding: .utf8) {
                    return text
                }
            }
            return parts?.compactMap(\.plainText).first
        }
    }

    struct Header: Decodable { let name: String; let value: String }
    struct Body: Decodable { let data: String? }
}
