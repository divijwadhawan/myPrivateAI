struct DemoAssistant {
    func reply(to prompt: String) async -> String {
        "Chat interface ready. You wrote: \(prompt)\n\nLocal Qwen inference will be connected here next."
    }
}
