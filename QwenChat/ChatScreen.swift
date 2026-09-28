import SwiftUI
import ExyteChat

struct ChatScreen: View {
    @State private var messages: [Message] = []
    private let assistant = DemoAssistant()
    private let user = User(id: "me", name: "You", avatarURL: nil, isCurrentUser: true)
    private let bot = User(id: "assistant", name: "Qwen", avatarURL: nil, isCurrentUser: false)

    var body: some View {
        NavigationStack {
            ChatView(messages: messages) { draft in
                send(draft.text)
            }
            .navigationTitle("Qwen Chat")
        }
    }

    private func send(_ text: String) {
        let prompt = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }
        messages.append(Message(id: UUID().uuidString, user: user, status: .sent,
                                createdAt: Date(), text: prompt))
        Task {
            let response = await assistant.reply(to: prompt)
            messages.append(Message(id: UUID().uuidString, user: bot, status: .sent,
                                    createdAt: Date(), text: response))
        }
    }
}
