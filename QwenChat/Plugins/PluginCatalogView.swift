import SwiftUI

struct PluginCatalogView: View {
    let registry: PluginRegistry
    let onUse: (PluginItem) -> Void

    var body: some View {
        NavigationStack {
            List(registry.plugins, id: \.id) { plugin in
                NavigationLink {
                    PluginSearchView(plugin: plugin, onUse: onUse)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plugin.title).font(.headline)
                        Text(plugin.description).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Plugins")
        }
    }
}

private struct PluginSearchView: View {
    let plugin: any AppPlugin
    let onUse: (PluginItem) -> Void

    @State private var query = ""
    @State private var items: [PluginItem] = []
    @State private var isWorking = false
    @State private var connected = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section(plugin.title) {
                if !plugin.isConfigured {
                    Text("This plugin needs setup in Xcode before it can connect.")
                        .foregroundStyle(.secondary)
                } else if connected {
                    HStack {
                        Label("Connected", systemImage: "checkmark.circle.fill")
                        Spacer()
                        Button("Disconnect") {
                            plugin.disconnect()
                            connected = false
                            items = []
                        }
                    }
                } else {
                    Button("Connect \(plugin.title)") {
                        Task { await connect() }
                    }
                    .disabled(isWorking)
                }
            }

            if connected {
                Section("Search") {
                    TextField("Search query", text: $query)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onSubmit { Task { await search() } }
                    Button("Search") { Task { await search() } }
                        .disabled(isWorking || query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                Section("Results") {
                    ForEach(items) { item in
                        Button {
                            onUse(item)
                        } label: {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.title).foregroundStyle(.primary)
                                Text(item.subtitle).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityHint("Summarize this item with the local model")
                    }
                    if items.isEmpty && !isWorking {
                        Text("Search for messages, then tap one to summarize it locally.")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if isWorking { ProgressView() }
            if let errorMessage {
                Section { Text(errorMessage).foregroundStyle(.red) }
            }
        }
        .navigationTitle(plugin.title)
        .task { connected = plugin.isConnected }
    }

    private func connect() async {
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }
        do {
            try await plugin.connect()
            connected = plugin.isConnected
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func search() async {
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }
        do {
            items = try await plugin.search(query.trimmingCharacters(in: .whitespacesAndNewlines))
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
