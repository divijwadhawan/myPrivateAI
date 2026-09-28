import Foundation

/// A small, explicit interface for external services. Plugins fetch data; the local model
/// receives only the item the user chooses to summarize.
struct PluginItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let content: String
}

@MainActor
protocol AppPlugin: AnyObject {
    var id: String { get }
    var title: String { get }
    var description: String { get }
    var isConfigured: Bool { get }
    var isConnected: Bool { get }

    func connect() async throws
    func disconnect()
    func search(_ query: String) async throws -> [PluginItem]
}

@MainActor
final class PluginRegistry {
    let plugins: [any AppPlugin] = [GmailPlugin()]
}

enum PluginError: LocalizedError {
    case configuration(String)
    case authentication
    case http(Int)

    var errorDescription: String? {
        switch self {
        case .configuration(let message): message
        case .authentication: "Connect Gmail before searching."
        case .http(let code): "Gmail request failed (HTTP \(code)). Check your account and API access."
        }
    }
}
